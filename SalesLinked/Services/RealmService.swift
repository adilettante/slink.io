//
//  RealmService.swift
//  Prodocom
//
//  Created by STDev's iMac on 9/4/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import Alamofire
import RxAlamofire
import SDWebImage
import RxOptional

class RealmService {
    private let disposeBag = DisposeBag()

    // MARK: Singleton instance
    static let shared = RealmService()

    // MARK: Prtivate vars
    public let realmScheduler = MainScheduler.instance

    // MARK: Public vars
    var realm: Realm {
        do {
            return try Realm()
        } catch(let error) {
            fatalError(error.localizedDescription)
        }
    }

    var businessCards: Observable<([BusinessCardInfo], RealmChangeset?)> {
        let businessCards = self.realm.objects(BusinessCardInfo.self)
            .filter("deleted == %@", NSNumber(value: false))
            .sorted(byKeyPath: "createdDate", ascending: false)
        return Observable.arrayWithChangeset(from: businessCards).subscribeOn(realmScheduler)
    }

    var businessCardsWithDeleteds: Observable<([BusinessCardInfo], RealmChangeset?)> {
        let businessCards = self.realm.objects(BusinessCardInfo.self)
        return Observable.arrayWithChangeset(from: businessCards).subscribeOn(realmScheduler)
    }

    var deletedBusinessCards: Observable<([BusinessCardInfo], RealmChangeset?)> {
        let businessCards = self.realm.objects(BusinessCardInfo.self)
            .filter("deleted == %@", NSNumber(value: true))
        return Observable.arrayWithChangeset(from: businessCards).subscribeOn(realmScheduler)
    }

    // MARK: - Init
    init() {
        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName)!
        let realmPath = directory.appendingPathComponent("db.realm")
        let config = Realm.Configuration(
            fileURL: realmPath,
            schemaVersion: 2,
            migrationBlock: { _, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion < 1 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        }
        )
        print(realmPath)
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

    }

    // MARK: - Truncate
    func truncate() {
        try? realm .write {
            realm.deleteAll()
        }
    }

    // MARK: - Write functionality
    func addBusinessCard(_ card: BusinessCardInfo) {
        try? realm.write {
            realm.add(card)
        }
    }

    func addNote(_ note: String, toCard id: String, withDate date: Date = Date()) {
        let object = BusinessCardNote(contactId: id, note: note, date: date)
        try? realm.write {
            realm.add(object)
        }
    }

    func addNote(_ note: BusinessCardNote) {
        try? realm.write {
            realm.add(note)
        }
    }

    // MARK: - Update functionality
    func updateCards(_ cards: [BusinessCardInfo], idIsBackends: Bool = false) {
        cards.forEach { card in
            self.updateCard(
                name: card.name ,
                email: card.email,
                phone: card.phoneNumber,
                company: card.company,
                updatedDate: card.updatedDate,
                in: idIsBackends ? card.backendItemId ?? "" : card.id,
                idIsBackends: idIsBackends
            )
        }
    }

    func updateCard(
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        company: String? = nil,
        updatedDate: Date = Date(),
        in id: String,
        idIsBackends: Bool = false) {
        let key = idIsBackends ? "backendItemId" : "id"
        try? realm.write {
            guard let item = realm.objects(BusinessCardInfo.self).filter("\(key) == %@", id).first else { return }
            if let name = name {
                item.name = name
            }
            if let email = email {
                item.email = email
            }
            if let phone = phone {
                item.phoneNumber = phone
            }
            if let company = company {
                item.company = company
            }
            item.updatedDate = updatedDate
        }
    }

    func update(imageServerPath: String?, id: String, backendId: String?) {
        try? realm.write {
            guard let item = realm.objects(BusinessCardInfo.self).filter("id == %@", id).first else { return }
            item.backendItemId = backendId
            item.urlToUpload = imageServerPath
        }
    }

    func setSavedImage(image: String, thumbnail: String?, inCard id: String) {
        try? realm.write {
            guard let item = realm.objects(BusinessCardInfo.self).filter("id == %@", id).first else { return }
            item.image = image
            item.thumbnail = thumbnail
            item.imgUrl = nil
        }
    }

    func imageUploaded(from id: String) {
        try? realm.write {
            guard let item = realm.objects(BusinessCardInfo.self).filter("id == %@", id).first else { return }
            item.urlToUpload = nil
        }
    }

    // MARK: - Delete functionality
    func deleteContact(by id: String, withFlag: Bool, idIsBackends: Bool = false) {
        let key = idIsBackends ? "backendItemId" : "id"
        try? realm.write {
            if let card = realm.objects(BusinessCardInfo.self).filter("\(key) == %@", id).first {
                if withFlag {
                    card.deleted = true
                } else {
                    let notes = realm.objects(BusinessCardNote.self)
                        .filter("contactId == %@", card.id)
                    realm.delete(notes)
                    let imgPath = card.image
                    let thumbPath = card.thumbnail
                    realm.delete(card)
                    if let url = URL(string: imgPath) {
                        try? FileManager.default.removeItem(at: url)
                    }
                    if let thumbPath = thumbPath, let thumbUrl = URL(string: thumbPath) {
                        try? FileManager.default.removeItem(at: thumbUrl)
                    }
                }
            }
        }
    }

    func deleteContactsBy(ids: [String], withFlag: Bool, idIsBackends: Bool = false) {
        ids.forEach { id in
            self.deleteContact(by: id, withFlag: withFlag, idIsBackends: idIsBackends)
        }
    }

    // MARK: - Read functionality
    func getCards() -> [BusinessCardInfo] {
        return self.realm.objects(BusinessCardInfo.self)
            .filter("deleted == %@", NSNumber(value: false))
            .sorted(byKeyPath: "createdDate", ascending: false)
            .toArray()
    }

    func getCard(by id: String, idIsBackends: Bool = false) -> BusinessCardInfo? {
        let key = idIsBackends ? "backendItemId" : "id"
        return realm.objects(BusinessCardInfo.self)
            .filter("\(key) == %@", id)
            .first
    }

    func notesForContact(by id: String) -> Observable<[BusinessCardNote]> {
        let objects = realm.objects(BusinessCardNote.self)
            .filter("contactId == %@", id)
            .sorted(byKeyPath: "date", ascending: false)
        return Observable.array(from: objects).subscribeOn(realmScheduler)
    }

    func arrayOfNotes(byContact id: String) -> [BusinessCardNote] {
        let objects = realm.objects(BusinessCardNote.self)
            .filter("contactId == %@", id)
            .sorted(byKeyPath: "date", ascending: false)
            .toArray()
        return objects
    }

    func cardUpdated(_ card: BusinessCardInfo) -> (remotly: Bool, locally: Bool) {
        guard let localCard = realm.objects(BusinessCardInfo.self)
            .filter("backendItemId == %@", card.backendItemId ?? "")
            .first else { return (false, false) }
        return (
            card.updatedDate.timeIntervalSince1970 > localCard.updatedDate.timeIntervalSince1970,
            card.updatedDate.timeIntervalSince1970 < localCard.updatedDate.timeIntervalSince1970
        )
    }
}

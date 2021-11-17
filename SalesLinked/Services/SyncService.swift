//
//  SyncService.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 3/26/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import SDWebImage
import RxOptional

class SyncService {

    enum CommentSyncType {
        case pull
        case push
    }

    // MARK: - Singleton variable
    public static let shared = SyncService(service: SyncServiceComponents())

    // MARK: - Dependencies
    let disposeBag = DisposeBag()

    public let remainingImagesCount = PublishSubject<UInt>()

    // MARK: Prtivate vars
    private let imageDownloader = SDWebImageDownloader()
    private let service: SyncServiceComponentsProtocol
    private let backgroundQueue = SerialDispatchQueueScheduler(qos: .default)

    private var contacts = PublishSubject<[ContactResponseSingleModel]>()
    private let refreshTrigger = PublishSubject<Void>()
    private let refreshCommentsTrigger = PublishSubject<String>()

    init(service: SyncServiceComponentsProtocol) {
        self.service = service
        self.remotlyAddedContacts()
        self.remotlyDeletedContacts()
        self.locallyDeletedContacts()
        self.remotlyUpdatedContacts()
        self.locallyUpdatedContacts()
        self.locallyAddedContacts()
        self.locallyAddedImages()
        self.doImageDownloading()
        self.commentsObserving()

        imageDownloader.maxConcurrentDownloads = 5

        refreshTrigger
            .flatMap { service.getAllContacts() }
            .map { $0.data }
            .filterNil()
            .bind(to: contacts)
            .disposed(by: disposeBag)

    }

    // MARK: - Sync Contacts Functionality
    func refreshContacts() {
        refreshTrigger.onNext(())
    }

    // MARK: Sync New Contacts
    func remotlyAddedContacts() {
        let syncedContactIds = RealmService.shared
            .businessCardsWithDeleteds
            .map { $0.0.compactMap { $0.backendItemId } }

        contacts
            .asObservable()
            .filterEmpty()
            .withLatestFrom(syncedContactIds) { ($0, $1) }
            .map { array, ids in
                return array.filter { !ids.contains($0.id) }
            }
            .filterEmpty()
            .map {
                $0.map {
                    return BusinessCardInfo(
                        id: $0.id,
                        name: $0.name,
                        email: $0.email,
                        company: $0.company,
                        phone: $0.phone,
                        url: $0.url,
                        createdOn: $0.createdOn,
                        modifiedOn: $0.modifiedOn
                    )
                }
            }
            .observeOn(RealmService.shared.realmScheduler)
            .subscribe(RealmService.shared.realm.rx.add())
            .disposed(by: disposeBag)
    }

    private func doImageDownloading() {
        RealmService.shared
            .businessCards
            .map { args -> [BusinessCardInfo] in
                let (cards, update) = args
                return update?.inserted
                    .compactMap { cards[$0] } ?? []
            }
            .startWith(RealmService.shared.getCards())
            .map { $0.filter { $0.image.isEmpty && $0.imgUrl != nil } }
            .filterEmpty()
            .flatMap { Observable.from($0) }
            .flatMap { [imageDownloader, remainingImagesCount] card -> Observable<(Data?, String)> in
                guard let urlString = card.imgUrl, let url = URL(string: urlString) else { return Observable.empty() }
                let id = card.id
                return Observable.create {  observer in
                    imageDownloader.downloadImage(
                        with: url, options: .continueInBackground, progress: nil,
                        completed: { (_, data, _, finished) in
                            if finished {
                                observer.onNext((data, id))
                                observer.onCompleted()
                            }
                            remainingImagesCount.onNext(imageDownloader.currentDownloadCount)
                            print("Remaining Images Count --> \(imageDownloader.currentDownloadCount)")
                    })
                    return Disposables.create()
                }
            }
            .filter { $0.0 != nil }
            .observeOn(SerialDispatchQueueScheduler(qos: .default))
            .map { args -> ((original: URL, thumbnail: URL?)?, String) in
                let (data, id) = args
                let paths = data?.saveDataAsImage(resizeImage: true, folderName: imagesFolderName)
                return (paths, id)
            }
            .subscribe(onNext: { args in
                let (paths, id) = args
                RealmService.shared.setSavedImage(
                    image: paths?.original.absoluteString ?? "",
                    thumbnail: paths?.thumbnail?.absoluteString,
                    inCard: id
                )
            })
            .disposed(by: disposeBag)
    }

    func locallyAddedContacts() {

        let retry = refreshTrigger
            .map { _ in
                RealmService.shared.getCards().filter { $0.backendItemId == nil }
            }

        let inserted = RealmService.shared
            .businessCards
            .map { args -> [BusinessCardInfo] in
                let (cards, update) = args
                return update?.inserted
                    .compactMap { cards[$0] }
                    .filter { $0.backendItemId == nil } ?? []
            }

        Observable.merge(inserted, retry)
            .distinctUntilChanged()
            .filterEmpty()
            .flatMap { [service] contacts -> Observable<MultipleUploadState> in
                return service.multipleUpload(with: UploadRequestModel(contacts: contacts))
            }
            .map { $0.data?.contactContainers }
            .filterNil()
            .subscribe(onNext: { containers in
                containers.forEach {
                    RealmService.shared.update(
                        imageServerPath: $0.url,
                        id: $0.deviceContactId ?? "",
                        backendId: $0.id
                    )
                }
            })
            .disposed(by: disposeBag)
    }

    func locallyAddedImages() {
        RealmService.shared
            .businessCards
            .map { args -> [BusinessCardInfo] in
                let (cards, update) = args
                return update?.updated
                    .compactMap { cards[$0] } ?? []
            }
            .startWith(RealmService.shared.getCards())
            .map { $0.filter { $0.urlToUpload != nil } }
            .filterEmpty()
            .distinctUntilChanged()
            .flatMapLatest { Observable.from($0) }
            .flatMap { card -> Observable<(Bool, String)> in
                guard let url = URL(string: card.image) else { return Observable.just((false, "")) }
                let id = card.id
                return self.service.upload(imagePath: url, to: card.urlToUpload ?? "")
                    .map { ($0, id) }
            }
            .subscribe(onNext: { success, id in
                if success {
                    RealmService.shared.imageUploaded(from: id)
                }
            })
            .disposed(by: disposeBag)
    }

    // MARK: Sync Updated Contacts

    func remotlyUpdatedContacts() {
        let syncedContactIds = RealmService.shared
            .businessCardsWithDeleteds
            .map { $0.0.compactMap { $0.backendItemId } }

        contacts
            .asObservable()
            .filterEmpty()
            .withLatestFrom(syncedContactIds) { ($0, $1) }
            .map { array, ids in
                return array.filter { ids.contains($0.id) }
            }
            .map {
                $0.map {
                    return BusinessCardInfo(
                        id: $0.id,
                        name: $0.name,
                        email: $0.email,
                        company: $0.company,
                        phone: $0.phone,
                        url: $0.url,
                        createdOn: $0.createdOn,
                        modifiedOn: $0.modifiedOn
                    )
                }
            }
            .map { $0.filter { RealmService.shared.cardUpdated($0).remotly } }
            .filterEmpty()
            .subscribe(onNext: { updatedContacts in
                RealmService.shared.updateCards(updatedContacts, idIsBackends: true)
            })
            .disposed(by: disposeBag)
    }

    func locallyUpdatedContacts() {
        let syncedContactIds = RealmService.shared
            .businessCardsWithDeleteds
            .map { $0.0.compactMap { $0.backendItemId } }

        contacts
            .asObservable()
            .filterEmpty()
            .withLatestFrom(syncedContactIds) { ($0, $1) }
            .map { array, ids in
                return array.filter { ids.contains($0.id) }
            }
            .map {
                $0.map {
                    return BusinessCardInfo(
                        id: $0.id,
                        name: $0.name,
                        email: $0.email,
                        company: $0.company,
                        phone: $0.phone,
                        url: $0.url,
                        createdOn: $0.createdOn,
                        modifiedOn: $0.modifiedOn
                    )
                }
            }
            .map { $0.filter { RealmService.shared.cardUpdated($0).locally } }
            .map { $0.compactMap { $0.backendItemId }.compactMap { RealmService.shared.getCard(by: $0, idIsBackends: true) } }
            .filterEmpty()
            .flatMap { Observable.from($0) }
            .flatMap { card -> Observable<ContactStateSingle> in
                return self.service.updateContact(
                    contact: ContactRequest(
                        name: card.name,
                        email: card.email,
                        phone: card.phoneNumber,
                        company: card.company
                    ),
                    id: card.backendItemId ?? "")
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    // MARK: Sync Deleteds

    func remotlyDeletedContacts() {
        let syncedContactIds = RealmService.shared
            .businessCardsWithDeleteds
            .map { $0.0
                .filter { $0.urlToUpload == nil }
                .compactMap { $0.backendItemId }
        }

        service.getAllContacts()
            .map { $0.data }
            .filterNil()
            .map { $0.compactMap { $0.id } }
            .withLatestFrom(syncedContactIds) { ($0, $1) }
            .map { remote, locals in
                return locals.filter { !remote.contains($0) }
            }
            .filterEmpty()
            .subscribe(onNext: { deletedIds in
                RealmService.shared.deleteContactsBy(ids: deletedIds, withFlag: false, idIsBackends: true)
            })
            .disposed(by: disposeBag)
    }

    func locallyDeletedContacts() {

        RealmService.shared
            .businessCardsWithDeleteds
            .map { args -> [String] in
                let (cards, update) = args
                return update?.updated
                    .compactMap { cards[$0] }
                    .filter { $0.deleted }
                    .compactMap { $0.backendItemId } ?? []
            }
            .filterEmpty()
            .distinctUntilChanged()
            .flatMap { [service] ids -> Observable<[String]> in
                return service.deleteContact(contact: DeleteContactRequest(contactIds: ids))
                    .filter { $0.deleted }
                    .map { _ in ids }
            }
            .subscribe(onNext: { ids in
                RealmService.shared.deleteContactsBy(ids: ids, withFlag: false, idIsBackends: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Sync Comments Functionality
    func refreshComments(for id: String) {
        guard let backendId = RealmService.shared.getCard(by: id)?.backendItemId else { return }
        refreshCommentsTrigger.onNext(backendId)
    }

    func commentsObserving() {
        let remoteNotes = refreshCommentsTrigger
            .flatMap { id in
                return self.service
                    .getContact(contact: id)
                    .map { ($0.data?.contactNotes ?? [], id) }
            }
            .map { notes, backendId -> [BusinessCardNote] in
                guard let id = RealmService.shared.getCard(by: backendId, idIsBackends: true)?.id else { return [] }
                return notes
                    .map {
                        BusinessCardNote(
                            contactId: id,
                            note: $0.description,
                            date: $0.date ?? Date()
                        )
                }
            }
            .map { $0.sorted(by: { $0.date.compare($1.date) == .orderedDescending }) }

        let localNotes = refreshCommentsTrigger
            .map { backendId -> [BusinessCardNote] in
                guard let id = RealmService.shared.getCard(by: backendId, idIsBackends: true)?.id else { return [] }
                return RealmService.shared.arrayOfNotes(byContact: id)
            }
            .map { $0.sorted(by: { $0.date.compare($1.date) == .orderedDescending }) }

        let getUpdates = remoteNotes
            .withLatestFrom(localNotes) { ($0, $1) }
            .filter { $0.0.count != $0.1.count }
            .observeOn(MainScheduler.instance)
            .map { args -> ([BusinessCardNote], CommentSyncType) in
                let (remote, local) = args
                let lastDate = remote.count > local.count ? local.first?.date : remote.first?.date
                let data = remote.count > local.count ? remote : local
                let type: CommentSyncType = remote.count > local.count ? .pull : .push
                return (
                    data.filter { $0.date.timeIntervalSince1970 > lastDate?.timeIntervalSince1970 ?? 0 },
                    type
                )
            }
            .share(replay: 1, scope: .whileConnected)

        getUpdates
            .filter { $0.1 == .pull }
            .map { $0.0 }
            .observeOn(MainScheduler.instance)
            .subscribe(RealmService.shared.realm.rx.add())
            .disposed(by: disposeBag)

        getUpdates
            .filter { $0.1 == .push }
            .map { $0.0 }
            .flatMap { Observable.from($0) }
            .flatMap { note -> Observable<ContactNoteState> in
                guard let id = RealmService.shared.getCard(by: note.contactId)?.backendItemId else {
                    return Observable.just(ContactNoteState.empty)
                }
                return self.service.addNote(note:
                    ContactNoteRequest(
                        description: note.note,
                        contactId: id,
                        date: note.date
                    )
                )
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

}

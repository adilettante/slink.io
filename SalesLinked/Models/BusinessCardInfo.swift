//
//  CardInfo.swift
//  SalesLinked
//
//  Created by STDev Mac on 6/2/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import RealmSwift

class BusinessCardInfo: Object {

    @objc dynamic var id: String = UUID().uuidString.lowercased()
    @objc dynamic var backendItemId: String?

    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var company: String = ""
    @objc dynamic var phoneNumber: String = ""

    @objc dynamic var image: String = ""
    @objc dynamic var thumbnail: String?
    @objc dynamic var imgUrl: String?
    @objc dynamic var urlToUpload: String?

    @objc dynamic var note: String?

    @objc dynamic var deleted: Bool = false

    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var updatedDate: Date = Date()

    convenience init(image: String, thumbnail: String?, note: String? = nil) {
        self.init()
        self.image = image
        self.note = note
        self.thumbnail = thumbnail
    }

    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(
        id: String!,
        name: String?,
        email: String?,
        company: String?,
        phone: String?,
        url: String?,
        createdOn: Date?,
        modifiedOn: Date?
        ) {
        self.init()
        self.backendItemId = id
        self.name = name ?? ""
        self.email = email ?? ""
        self.company = company ?? ""
        self.phoneNumber = phone ?? ""
        self.imgUrl = url
        self.createdDate = createdOn ?? Date()
        self.updatedDate = modifiedOn ?? createdOn ?? Date()

    }
}

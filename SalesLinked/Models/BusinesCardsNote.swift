//
//  BusinesCardsNote.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 3/23/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import Foundation
import RealmSwift

class BusinessCardNote: Object {

    @objc dynamic var id: String = UUID().uuidString.lowercased()

    @objc dynamic var contactId: String = ""

    @objc dynamic var note: String = ""
    @objc dynamic var date: Date = Date()

    convenience init(contactId: String, note: String, date: Date = Date()) {
        self.init()
        self.contactId = contactId
        self.note = note
        self.date = date
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}

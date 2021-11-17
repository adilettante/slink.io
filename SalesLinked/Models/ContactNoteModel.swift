//
//  ContactNote.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/9/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import ObjectMapper

class ContactNote: Mappable {
    var date: Date?
    var description: String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        date <- (
            map["date"],
            DateFormatterTransform(dateFormatter: DateFormattingHelper.formatterForParse(.long))
        )
        description <- map["description"]
    }
}

class ContactNoteRequest: Mappable {
    var contactId: String!
    var description: String!
    var date: String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        contactId <- map["contactId"]
        description <- map["description"]
        date <- map["date"]
    }

    init(description: String, contactId: String, date: Date? = Date()) {
        self.contactId = contactId
        self.description = description
        self.date = DateFormattingHelper.string(from: date, format: .long)
    }
}

enum ContactNoteResponse {
    case updated
    case base(response: BaseResponse)

}

struct ContactNoteState {
    let base: BaseState
    var updated = false

    init() {
        self.updated = true
        self.base = BaseState.empty
    }

    init(base: BaseState) {
        self.updated = false
        self.base = base
    }

    static let empty = ContactNoteState()
}

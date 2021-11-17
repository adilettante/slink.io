//
//  ContactModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/30/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import ObjectMapper

class ContactRequest: Mappable {
    var name: String?
    var email: String?
    var phone: String?
    var company: String?
    var note: String?
    var deviceContactId: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        name <- map["name"]
        email <- map["email"]
        phone <- map["phone"]
        company <- map["company"]
        note <- map["note"]
        deviceContactId <- map["deviceContactId"]
    }

    init() { }

    init(
        deviceContactId: String? = nil,
        name: String? = nil,
        email: String? = nil,
        phone: String? = nil,
        company: String? = nil,
        note: String? = nil
        ) {
        self.deviceContactId = deviceContactId
        self.name = name
        self.email = email
        self.phone = phone
        self.company = company
        self.note = note
    }
}

class ContactResponseSingleModel: Mappable {
    var id: String!
    var url: String?
    var email: String?
    var name: String?
    var phone: String?
    var company: String?
    var createdOn: Date?
    var modifiedOn: Date?
    var contactNotes: [ContactNote] = []

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        id <- map["id"]
        url <- map["url"]
        email <- map["email"]
        name <- map["name"]
        phone <- map["phone"]
        company <- map["company"]
        createdOn <- (
            map["createdOn"],
            DateFormatterTransform(dateFormatter: DateFormattingHelper.formatterForParse(.long))
        )
        modifiedOn <- (
            map["modifiedOn"],
            DateFormatterTransform(dateFormatter: DateFormattingHelper.formatterForParse(.long))
        )
        contactNotes <- map["contactNotes"]
    }
}

class ContactResponseModel: Mappable {
    var contacts: [ContactResponseSingleModel] = []

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        contacts <- map["contacts"]
    }
}

enum ContactResponse {

    case created(data: [ContactResponseSingleModel] )
    case base(response: BaseResponse)

}

struct ContactState {
    var data: [ContactResponseSingleModel]?
    let base: BaseState

    init() {
        self.data = []
        self.base = BaseState.empty
    }

    init(data: [ContactResponseSingleModel] = []) {
        self.data = data
        self.base = BaseState.online
    }

    init(base: BaseState) {
        self.data = nil
        self.base = base
    }

    static let empty = ContactState()
}

enum ContactResponseSingle {

    case created(data: ContactResponseSingleModel)
    case updated
    case base(response: BaseResponse)

}

struct ContactStateSingle {
    var data: ContactResponseSingleModel?
    let base: BaseState
    var updated = false

    init() {
        self.data = nil
        self.updated = true
        self.base = BaseState.empty
    }

    init(data: ContactResponseSingleModel) {
        self.data = data
        self.updated = false
        self.base = BaseState.online
    }

    init(base: BaseState) {
        self.data = nil
        self.updated = false
        self.base = base
    }

    static let empty = ContactStateSingle()
}

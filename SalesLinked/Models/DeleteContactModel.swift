//
//  DeleteContactModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 11/14/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import ObjectMapper

class DeleteContactRequest: Mappable {
    var contactIds: [String] = []

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        contactIds <- map["contactIds"]
    }

    init(contactIds: [String]) {
        self.contactIds = contactIds
    }

    init(contactId: String) {
        contactIds.append(contactId)
    }

    func append(contactId: String) {
        contactIds.append(contactId)
    }
}

enum DeleteContactResponse {
    case deleted
    case base(response: BaseResponse)

}

struct DeleteContactState {
    let base: BaseState
    var deleted = false

    init() {
        self.deleted = true
        self.base = BaseState.empty
    }

    init(base: BaseState) {
        self.deleted = false
        self.base = base
    }

    static let empty = DeleteContactState()
}

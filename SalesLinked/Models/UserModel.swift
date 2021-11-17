//
//  UserModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/1/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import ObjectMapper

class LinkedInUser: Mappable {
    var id: String?
    var firstName: String?
    var lastName: String?

    required init?(map: Map) {

    }

    init(id: String, firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }

    func mapping(map: Map) {
        id <- map["id"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
    }
}

class UserRequest: Mappable {
    var linkedInId: String?
    var firstName: String?
    var lastName: String?

    required init?(map: Map) {

    }

    init(linkedInId: String?, firstName: String?, lastName: String?) {
        self.linkedInId = linkedInId
        self.firstName = firstName
        self.lastName = lastName
    }

    func mapping(map: Map) {
        linkedInId <- map["linkedInId"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
    }
}

class UserResponseModel: Mappable {
    required init?(map: Map) {

    }

    func mapping(map: Map) {

    }
}

enum UserResponse {
    case created(data: TokenResponseModel)
    case base(response: BaseResponse)
}

struct UserState {

    let data: TokenResponseModel?
    let base: BaseState

    init() {
        self.data = nil
        self.base = BaseState.empty
    }

    init(base: BaseState) {
        self.data = nil
        self.base = base
    }

    init(data: TokenResponseModel) {
        self.data = data
        self.base = BaseState.online
    }

    static let empty = UserState()
}

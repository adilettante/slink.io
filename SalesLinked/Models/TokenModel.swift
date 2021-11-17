//
//  TokenModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import ObjectMapper

class TokenRequest: Mappable {
    var key: String?

    required init?(map: Map) {

    }

    init(key: String) {
        self.key = key
    }

    func mapping(map: Map) {
        key <- map["key"]
    }
}

class TokenResponseModel: Mappable {
    var token: String!

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        token <- map["token"]
    }
}

enum TokenResponse {
    case alreadyExist()
    case created(data: TokenResponseModel)
    case base(response: BaseResponse)

}

struct TokenState {

    let data: TokenResponseModel?
    let base: BaseState
    let alreadyExist: Bool!

    init() {
        self.data = nil
        self.base = BaseState.empty
        self.alreadyExist = true
    }

    init(data: TokenResponseModel) {
        self.data = data
        self.base = BaseState.online
        self.alreadyExist = false
    }

    init(base: BaseState) {
        self.data = nil
        self.base = base
        self.alreadyExist = false
    }

    static let empty = TokenState()
}

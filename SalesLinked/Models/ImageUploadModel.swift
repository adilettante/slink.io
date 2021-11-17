//
//  ImageUploadModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/2/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import ObjectMapper

class UploadRequestModel: Mappable {
    var contacts: [ContactRequest] = []

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        contacts <- map["contactRequests"]
    }

    init(contacts: [ContactRequest]) {
        self.contacts = contacts
    }

    init(contacts: [BusinessCardInfo]) {
        self.contacts = contacts.map {
            ContactRequest(
                deviceContactId: $0.id,
                name: $0.name,
                email: $0.email,
                phone: $0.phoneNumber,
                company: $0.company,
                note: $0.note
            )
        }
    }
}

class UploadUrlResponseModel: Mappable {
    var url: String!
    var urls: [String] = []

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        url <- map["url"]
        urls <- map["urls"]
    }
}

enum UploadUrlResponse {

    case created(data: UploadUrlResponseModel)
    case base(response: BaseResponse)

}

struct UploadUrlState {

    let data: UploadUrlResponseModel?
    let base: BaseState
    let imageUploaded: Bool

    init() {
        self.data = nil
        self.base = BaseState.empty
        imageUploaded = true
    }

    init(data: UploadUrlResponseModel) {
        self.data = data
        self.base = BaseState.online
        imageUploaded = false
    }

    init(base: BaseState) {
        self.data = nil
        self.base = base
        imageUploaded = false
    }

    static let empty = UploadUrlState()
}

class MultipleUploadResponseData: Mappable {
    var contactContainers: [ContactContainer] = []

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        contactContainers <- map["contactContainers"]
    }
}

class ContactContainer: Mappable {
    var id: String?
    var deviceContactId: String?
    var url: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        id <- map["id"]
        deviceContactId <- map["deviceContactId"]
        url <- map["url"]
    }
}

enum MultipleUploadResponse {

    case created(data: MultipleUploadResponseData)
    case base(response: BaseResponse)

}

struct MultipleUploadState {

    let data: MultipleUploadResponseData?
    let base: BaseState

    init() {
        self.data = nil
        self.base = BaseState.empty
    }

    init(data: MultipleUploadResponseData) {
        self.data = data
        self.base = BaseState.online
    }

    init(base: BaseState) {
        self.data = nil
        self.base = base
    }

    static let empty = MultipleUploadState()
}

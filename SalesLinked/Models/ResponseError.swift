//
//  ResponseError.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import ObjectMapper

class ResponseError: Mappable {
    var type: String = ""
    var title: String = ""
    var detail: String = ""
    var invalidParams: [InvalidParam] = []

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        type <- map["type"]
        title <- map["title"]
        detail <- map["detail"]
        invalidParams <- map["invalidParams"]
    }

}

class InvalidParam: Mappable {
    var param: String?
    var code: String?
    var reason: String?

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        param <- map["param"]
        code <- map["code"]
        reason <- map["reason"]
    }
}

class ResponseUnexpectedError: Mappable {
    var timestamp: String = ""
    var status: Int = 0
    var error: String = ""
    var exception: String = ""
    var message: String = ""

    required init?(map: Map) {

    }

    func mapping(map: Map) {
        timestamp <- map["timestamp"]
        status <- map["status"]
        error <- map["error"]
        exception <- map["exception"]
        message <- map["message"]
    }

    init(status: Int, error: String, exception: String, message: String) {
        timestamp = DateFormattingHelper.stringFrom(date: Date(), format: DateFormat.LongDate)
        self.status = status
        self.error = error
        self.exception = exception
        self.message = message
    }

    static let mappingFailed = ResponseUnexpectedError(
        status: 4003,
        error: "Failed to Map",
        exception: "Mapping",
        message: "Unable to map response data to LoginResponseData"
    )

    static let badRequest = ResponseUnexpectedError(
        status: 4001,
        error: "Failed to request",
        exception: "InvalidRequest",
        message: "Something wrong was done in my end"
    )
}

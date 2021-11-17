//
//  BaseState.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation

struct BaseState {

    /*
     Current network state.
     */
    var serviceState: ServiceState?

    var badRequest: Bool?

    var unauthorized: Bool?

    var notFound: Bool?

    var validationProblem: ResponseError?

    var unexpectedError: ResponseUnexpectedError?

    init() {
        serviceState = nil
        badRequest = nil
        unauthorized = nil
        notFound = nil
        validationProblem = nil
        unexpectedError = nil
    }

    init(badRequest: Bool) {
        self = BaseState(serviceState: .online)
        self.badRequest = badRequest
    }

    init(unauthorized: Bool) {
        self = BaseState(serviceState: .online)
        self.unauthorized = unauthorized
    }

    init(notFound: Bool) {
        self = BaseState(serviceState: .online)
        self.notFound = notFound
    }

    init(serviceState: ServiceState) {
        self = BaseState()
        self.serviceState = serviceState
    }

    init(validationProblem: ResponseError) {
        self = BaseState(serviceState: .online)
        self.validationProblem = validationProblem
    }

    init(unexpectedError: ResponseUnexpectedError) {
        self = BaseState(serviceState: .online)
        self.unexpectedError = unexpectedError
    }

    static let empty = BaseState()

    static let badRequestState = BaseState(badRequest: true)

    static let unauthorizedState = BaseState(unauthorized: true)

    static let notFoundState = BaseState(notFound: true)

    static let offline = BaseState(serviceState: .offline)

    static let online = BaseState(serviceState: .online)
}

extension BaseState: Equatable {
    static func == (lhs: BaseState, rhs: BaseState) -> Bool {
        return lhs.serviceState == rhs.serviceState
            && lhs.badRequest == rhs.badRequest
            && lhs.unauthorized == rhs.unauthorized
            && lhs.notFound == rhs.notFound
            && lhs.validationProblem?.toJSONString() == rhs.validationProblem?.toJSONString()
            && lhs.unexpectedError?.toJSONString() == rhs.unexpectedError?.toJSONString()
    }
}

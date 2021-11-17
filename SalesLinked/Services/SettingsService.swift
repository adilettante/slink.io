//
//  SettingsService.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation

import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import ObjectMapper

protocol SettingsServiceProtocol {

    func update(user request: UserRequest) -> Observable<UserState>

    func logOut(token request: TokenRequest) -> Observable<TokenState>
}

class SettingsService: SettingsServiceProtocol {
    func update(user request: UserRequest) -> Observable<UserState> {
        return BaseService.shared.patch(endpoint: "/users", object: request.toJSON())
            .map { (httpResponse, string) -> UserResponse in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 200:
                    if let data = TokenResponseModel(JSONString: string) {
                        return .created(data: data)
                    }
                    return .base(response: .unexpectedError(error: ResponseUnexpectedError.mappingFailed))
                default:
                    return .base(response: .badRequest)
                }
            }
            .retryOnBecomesReachable(
                .base(response: .serviceOffline),
                reachabilityService: BaseService.shared.reachabilityService
            )
            .flatMap { response -> Observable<UserState> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(UserState(base: state))
                case let .created(data: data):
                    return Observable.just(UserState(data: data))
                }
        }
    }

    func logOut(token request: TokenRequest) -> Observable<TokenState> {
        return BaseService.shared.post(endpoint: "/users", object: request.toJSON())
            .map { (httpResponse, string) -> TokenResponse in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 200:
                    if let data = TokenResponseModel(JSONString: string) {
                        return .created(data: data)
                    }
                    return .base(response: .unexpectedError(error: ResponseUnexpectedError.mappingFailed))
                case 409:
                    return .alreadyExist()
                default:
                    return .base(response: .badRequest)
                }
            }
            .retryOnBecomesReachable(
                .base(response: .serviceOffline),
                reachabilityService: BaseService.shared.reachabilityService
            )
            .flatMap { response -> Observable<TokenState> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(TokenState(base: state))
                case let .created(data: data):
                    return Observable.just(TokenState(data: data))
                case .alreadyExist:
                    return Observable.just(TokenState())
                }
        }
    }
}

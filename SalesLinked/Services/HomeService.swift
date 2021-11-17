//
//  HomeService.swift
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

protocol HomeServiceProtocol {

    func create(token request: TokenRequest) -> Observable<TokenState>

    func getContacts(loadNextPageTrigger: Observable<Void>) -> Observable<ContactState>

    func upload(upload request: UploadRequestModel) -> Observable<UploadUrlState>

    func upload(imagePath: URL, to url: String) -> Observable<Bool>
}

class HomeService: HomeServiceProtocol {

    func upload(upload request: UploadRequestModel) -> Observable<UploadUrlState> {
        return BaseService.shared.post(endpoint: "/contacts/multiple", object: request.toJSON())
            .map { (httpResponse, string) -> UploadUrlResponse in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 200:
                    if let data = UploadUrlResponseModel(JSONString: string) {
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
            .flatMap { response -> Observable<UploadUrlState> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(UploadUrlState(base: state))
                case let .created(data: data):
                    return Observable.just(UploadUrlState(data: data))
                }
        }
    }

    func create(token request: TokenRequest) -> Observable<TokenState> {
        return BaseService.shared.post(endpoint: "/tokens", object: request.toJSON())
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

    func getContacts(loadNextPageTrigger: Observable<Void>) -> Observable<ContactState> {
        return recursivelyGetContatcs([], loadNextRequest: 0, loadNextPageTrigger: loadNextPageTrigger)

    }

    private func recursivelyGetContatcs(
        _ loadedSoFar: [ContactResponseSingleModel],
        loadNextRequest: Int,
        loadNextPageTrigger: Observable<Void>
        ) -> Observable<ContactState> {
        return loadContacts(page: loadNextRequest)
            .flatMap { response -> Observable<ContactState> in
            switch response {

            case let .base(response: base):
                let state = BaseService.shared.checkBaseState(response: base)
                return Observable.just(ContactState(base: state))

            case let .created(data: data):
                if data.isEmpty {
                    return Observable.just(ContactState(data: loadedSoFar))
                }

                var loadedContacts = loadedSoFar
                loadedContacts.append(contentsOf: data)

                let appendedContacts = ContactState(data: loadedContacts)

                return Observable.concat([
                    // return loaded immediately
                    Observable.just(appendedContacts),
                    // wait until next page can be loaded
                    Observable.never().takeUntil(loadNextPageTrigger),
                    // load next page
                    self.recursivelyGetContatcs(
                        loadedContacts,
                        loadNextRequest: loadNextRequest + 1,
                        loadNextPageTrigger: loadNextPageTrigger
                    )
                    ])
            }
        }
    }

    private func loadContacts(page: Int) -> Observable<ContactResponse> {
        return BaseService.shared.get(endpoint: String(format: "%@%d", "/contacts/", page), parameters: [:])
            .map { (httpResponse, string) -> ContactResponse in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 200:
                    if let data = ContactResponseModel(JSONString: string) {
                        return .created(data: data.contacts)
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
    }

    func upload(imagePath: URL, to url: String) -> Observable<Bool> {
        guard let url = URL(string: url) else {
            return Observable<Bool>.just(false)
        }

        return rxUpload(imagePath, to: url, method: .put)
            .flatMap { (request: UploadRequest) -> Observable<Bool> in
                return request.rx.responseString()
                    .map { (httpResponse, _) -> Bool in
                        return httpResponse.statusCode == 201
                }
            }
            .retry(3)
    }
}

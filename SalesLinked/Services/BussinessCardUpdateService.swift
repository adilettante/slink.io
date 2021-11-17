//
//  BussinessCardUpdateService.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/6/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import ObjectMapper

protocol BussinesCardUpdateServiceProtocol {

    func getContact(contact id: String) -> Observable<ContactStateSingle>

    func updateContact(contact request: ContactRequest, id: String) -> Observable<ContactStateSingle>

    func addNote(note request: ContactNoteRequest) -> Observable<ContactNoteState>

    func deleteContact(contact request: DeleteContactRequest) -> Observable<DeleteContactState>
}

class BussinesCardUpdateService: BussinesCardUpdateServiceProtocol {

    func addNote(note request: ContactNoteRequest) -> Observable<ContactNoteState> {
        return BaseService.shared.post(endpoint: "/contacts/notes", object: request.toJSON())
            .map { (httpResponse, string) -> ContactNoteResponse in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 204:
                    return .updated
                default:
                    return .base(response: .badRequest)
                }
            }
            .retryOnBecomesReachable(
                .base(response: .serviceOffline),
                reachabilityService: BaseService.shared.reachabilityService
            )
            .flatMap { response -> Observable<ContactNoteState> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(ContactNoteState(base: state))
                case .updated:
                    return Observable.just(ContactNoteState())
                }
        }
    }

    func updateContact(contact request: ContactRequest, id: String) -> Observable<ContactStateSingle> {
        return BaseService.shared.patch(endpoint: String(format: "/contacts/%@", id), object: request.toJSON())
            .map { (httpResponse, string) -> ContactResponseSingle in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 204:
                    return .updated
                default:
                    return .base(response: .badRequest)
                }
            }
            .retryOnBecomesReachable(
                .base(response: .serviceOffline),
                reachabilityService: BaseService.shared.reachabilityService
            )
            .flatMap { response -> Observable<ContactStateSingle> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(ContactStateSingle(base: state))
                case .updated:
                    return Observable.just(ContactStateSingle())
                case .created(let data):
                    return Observable.just(ContactStateSingle(data: data))
                }
        }
    }

    func getContact(contact id: String) -> Observable<ContactStateSingle> {
        return BaseService.shared.get(endpoint: String(format: "/contacts/single/%@", id), parameters: [:])
            .map { (httpResponse, string) -> ContactResponseSingle in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 200:
                    if let data = ContactResponseSingleModel(JSONString: string) {
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
            .flatMap { response -> Observable<ContactStateSingle> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(ContactStateSingle(base: state))
                case let .created(data: data):
                    return Observable.just(ContactStateSingle(data: data))
                case .updated:
                    return Observable.just(ContactStateSingle())
                }
        }
    }

    func deleteContact(contact request: DeleteContactRequest) -> Observable<DeleteContactState> {
        return BaseService.shared.delete(endpoint: "/contacts", object: request.toJSON())
            .map { (httpResponse, string) -> DeleteContactResponse in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 204:
                    return .deleted
                default:
                    return .base(response: .badRequest)
                }
            }
            .retryOnBecomesReachable(
                .base(response: .serviceOffline),
                reachabilityService: BaseService.shared.reachabilityService
            )
            .flatMap { response -> Observable<DeleteContactState> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(DeleteContactState(base: state))
                case .deleted:
                    return Observable.just(DeleteContactState())
                }
            }
    }
}

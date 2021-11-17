//
//  SyncServiceComponents.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 3/26/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import ObjectMapper

protocol SyncServiceComponentsProtocol {
    func getAllContacts() -> Observable<ContactState>
    func deleteContact(contact request: DeleteContactRequest) -> Observable<DeleteContactState>
    func multipleUpload(with request: UploadRequestModel) -> Observable<MultipleUploadState>
    func upload(imagePath: URL, to url: String) -> Observable<Bool>
    func updateContact(contact request: ContactRequest, id: String) -> Observable<ContactStateSingle>
    func addNote(note request: ContactNoteRequest) -> Observable<ContactNoteState>
    func getContact(contact id: String) -> Observable<ContactStateSingle>
}

class SyncServiceComponents: SyncServiceComponentsProtocol {

    func getAllContacts() -> Observable<ContactState> {
        return BaseService.shared.get(endpoint: "/contacts/-1", parameters: [:])
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
            .flatMap { response -> Observable<ContactState> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(ContactState(base: state))
                case let .created(data: data):
                    return Observable.just(ContactState(data: data))
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

    func multipleUpload(with request: UploadRequestModel) -> Observable<MultipleUploadState> {
        return BaseService.shared.post(endpoint: "/contacts/multiple", object: request.toJSON())
            .map { (httpResponse, string) -> MultipleUploadResponse in
                if let response = BaseService.shared.checkBaseResponse(httpResponse, string) {
                    return .base(response: response)
                }
                switch httpResponse.statusCode {
                case 200:
                    if let data = MultipleUploadResponseData(JSONString: string) {
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
            .flatMap { response -> Observable<MultipleUploadState> in
                switch response {
                case let .base(response: base):
                    let state = BaseService.shared.checkBaseState(response: base)
                    return Observable.just(MultipleUploadState(base: state))
                case let .created(data: data):
                    return Observable.just(MultipleUploadState(data: data))
                }
        }
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

}

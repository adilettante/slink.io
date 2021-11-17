//
//  BussinessCardImportService.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/2/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import ObjectMapper

protocol BussinesCardImportServiceProtocol {

    func create(contact request: ContactRequest) -> Observable<UploadUrlState>

    func upload(imagePath: URL, to url: String) -> Observable<Bool>
}

class BussinesCardImportService: BussinesCardImportServiceProtocol {

    func create(contact request: ContactRequest) -> Observable<UploadUrlState> {
        return BaseService.shared.post(endpoint: "/contacts", object: request.toJSON())
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
    }
}

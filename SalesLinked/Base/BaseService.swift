//
//  BaseServiceState.swift
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

/*
 ServiceState state.
 */
enum ServiceState {
    case online
    case offline
}

enum RequestType {
    case secure
    case unsecure
}

class BaseService {

    public static let shared = BaseService()

    public var operationQueue: OperationQueue
    public var backgroundWorkScheduler: OperationQueueScheduler
    // swiftlint:disable force_try
    public let reachabilityService: ReachabilityService = try! DefaultReachabilityService()
    // swiftlint:enable force_try

    private let retryCount = 3

    init() {
        operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        #if !RX_NO_MODULE
            operationQueue.qualityOfService = QualityOfService.userInitiated
        #endif
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
    }

    let accept: String = {
        return "application/vnd.sales-linked." + Config.API_VERSION + "+" + Config.API_FORMAT + ";charset=UTF-8"
    }()

    public func getHeaders(for: RequestType) -> [String: String] {
        switch `for` {
        case .secure:
            return [
                "Authorization": "Bearer " + (UserDefaultsHelper.getString(for: .AuthToken) ?? ""),
                "Accept": accept,
                "Content-Type": "application/json"
            ]
        case .unsecure:
            return [
                "ApiToken": Config.API_TOKEN,
                "Accept": accept,
                "Content-Type": "application/json"
            ]
        }
    }

    // MARK: - POST requests
    func post(
        endpoint: String,
        array: [String],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {
        return request(
            .post,
            Config.BASE_URL + endpoint,
            parameters: [:],
            encoding: JSONStringArrayEncoding(array),
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    func post(
        endpoint: String,
        object: [String: Any],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {
        return request(
            .post,
            Config.BASE_URL + endpoint,
            parameters: object,
            encoding: JSONEncoding.default,
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    // MARK: - PATCH requests
    func patch(
        endpoint: String,
        object: [String: Any],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {
        return request(
            .patch,
            Config.BASE_URL + endpoint,
            parameters: object,
            encoding: JSONEncoding.default,
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    // MARK: - PUT requests
    func put(
        endpoint: String,
        array: [String],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {
        return request(
            .put,
            Config.BASE_URL + endpoint,
            parameters: [:],
            encoding: JSONStringArrayEncoding(array),
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    func put(
        endpoint: String,
        object: [String: Any],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {
        return request(
            .put,
            Config.BASE_URL + endpoint,
            parameters: object,
            encoding: JSONEncoding.default,
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    func put(
        endpoint: String,
        objectArray: [[String: Any]],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {
        return request(
            .put,
            Config.BASE_URL + endpoint,
            parameters: [:],
            encoding: JSONObjectArrayEncoding(objectArray),
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    // MARK: - DELETE Requests
    func delete(
        endpoint: String,
        object: [String: Any],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {
        return request(
            .delete,
            Config.BASE_URL + endpoint,
            parameters: object,
            encoding: JSONEncoding.default,
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    // MARK: - GET Requests
    func get(
        endpoint: String,
        parameters: [String: Any],
        for type: RequestType = .secure
        ) -> Observable<(HTTPURLResponse, String)> {

        return request(
            .get,
            Config.BASE_URL + endpoint,
            parameters: parameters,
            headers: getHeaders(for: type)
            )
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
            }
            .retry(retryCount)
            .observeOn(self.backgroundWorkScheduler)
    }

    // MARK: - Upload Requests
    func uploadFormData(
        files urls: [String: URL],
        to url: String,
        for type: RequestType = .secure) -> Observable<(HTTPURLResponse, String)> {
        return rxUpload(
            multipartFormData: { formData in
                _ = urls.map { key, value in
                    formData.append(value, withName: key)
                }
        },
            to: Config.BASE_URL + url,
            method: .post,
            headers: getHeaders(for: type)
            )
            .map { $0.0 }
            .flatMap { request -> Observable<(HTTPURLResponse, String)> in
                if Config.DEBUG {
                    print(request.debugDescription, #function, #line)
                }
                return request.rx.responseString()
        }
    }

    // MARK: - Checking base response cases
    func checkBaseResponse(_ httpResponse: HTTPURLResponse, _ string: String) -> BaseResponse? {
        switch httpResponse.statusCode {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 422:
            guard let error = Mapper<ResponseError>().map(JSONString: string) else {
                return .unexpectedError(error: ResponseUnexpectedError.mappingFailed)
            }
            return .validationProblem(error: error)
        case 500..<600:
            guard let error = Mapper<ResponseUnexpectedError>().map(JSONString: string) else {
                return .unexpectedError(error: ResponseUnexpectedError.mappingFailed)
            }
            return .unexpectedError(error: error)
        default:
            return nil
        }
    }

    // MARK: - Checking base state cases
    func checkBaseState(response: BaseResponse) -> BaseState {
        switch response {
        case .serviceOffline:
            return BaseState.offline
        case .badRequest:
            return BaseState.badRequestState
        case .unauthorized:
            return BaseState.unauthorizedState
        case .notFound:
            return BaseState.notFoundState
        case let .validationProblem(error: error):
            return BaseState(validationProblem: error)
        case let .unexpectedError(error: error):
            return BaseState(unexpectedError: error)
        }
    }
}

struct JSONStringArrayEncoding: ParameterEncoding {
    private let array: [String]

    init(_ array: [String]) {
        self.array = array
    }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest!

        let data = try JSONSerialization.data(withJSONObject: array, options: [])

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        urlRequest.httpBody = data

        return urlRequest
    }
}

struct JSONObjectArrayEncoding: ParameterEncoding {
    private let array: [[String: Any]]

    init(_ array: [[String: Any]]) {
        self.array = array
    }

    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = urlRequest.urlRequest!

        let data = try JSONSerialization.data(withJSONObject: array, options: [])

        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        urlRequest.httpBody = data

        return urlRequest
    }
}

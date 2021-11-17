//
//  HomeViewModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class HomeViewModel {
    let disposeBag = DisposeBag()
    var businessCardInfo = Variable([BusinessCardInfo]())
    var tokenCreated = PublishSubject<Void>()

    init(
        loadNextPageTrigger: Observable<Void>,
        refreshTrigger: Driver<Void>,
        tokenRequest: TokenRequest,
        service: HomeServiceProtocol,
        showLoadingVariable: Variable<Bool>,
        realmService: RealmService
    ) {

        service.create(token: tokenRequest)
            .asDriver(onErrorJustReturn: TokenState.empty)
            .do( onNext: {
                if let token = $0.data?.token {
                    UserDefaultsHelper.set(alias: .AuthToken, value: token)
                }
            })
            .map { _ in () }
            .drive(tokenCreated)
            .disposed(by: disposeBag)
    }

}

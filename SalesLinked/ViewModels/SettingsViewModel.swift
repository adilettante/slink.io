//
//  SettingsViewModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class SettingsViewModel {
    var updateState: Driver<UserState>
    var logOutState: Driver<TokenState>

    init(
        service: SettingsServiceProtocol,
        loginDriver: Driver<UserRequest>,
        logOutDriver: Driver<String>
        ) {
        updateState = loginDriver.flatMap {
            service.update(user: $0)
                .asDriver(onErrorJustReturn: UserState.empty)
        }

        logOutState = logOutDriver.flatMap { token in
            service.logOut(token: TokenRequest(key: token))
                .asDriver(onErrorJustReturn: TokenState.empty)
        }
    }
}

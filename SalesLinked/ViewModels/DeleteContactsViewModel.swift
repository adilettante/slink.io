//
//  DeleteContactsViewModel.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 11/15/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class DeleteContactsViewModel {
    private var loadNextPageTrigger: Driver<Void>
    private var refreshTrigger: Driver<Void>
    private var deleteTrigger: Driver<[String]>
    private var homeService: HomeServiceProtocol
    private var bussinesCardService: BussinesCardUpdateServiceProtocol
    public var getState: Driver<ContactState>!
    public var deleteState: Driver<DeleteContactState>!

    init(
        loadNextPageTrigger: Driver<Void>,
        deleteTrigger: Driver<[String]>,
        refreshTrigger: Driver<Void>,
        homeService: HomeServiceProtocol,
        bussinesCardService: BussinesCardUpdateServiceProtocol
        ) {
        self.deleteTrigger = deleteTrigger
        self.loadNextPageTrigger = loadNextPageTrigger
        self.refreshTrigger = refreshTrigger
        self.homeService = homeService
        self.bussinesCardService = bussinesCardService

        self.getContatcs()
        self.delete()
    }

    private func getContatcs() {
        getState = refreshTrigger
                    .flatMap { [weak self] _ in
                        guard let strongSelf = self else { return Driver.just(ContactState.empty) }
                        return strongSelf.homeService
                            .getContacts(loadNextPageTrigger: strongSelf.loadNextPageTrigger.asObservable())
                            .asDriver(onErrorJustReturn: ContactState.empty)
                    }
    }

    private func delete() {
        deleteState = deleteTrigger
                        .flatMap { [weak self] data in
                            guard let strongSelf = self else { return Driver.just(DeleteContactState.empty) }
                            return strongSelf.bussinesCardService.deleteContact(contact: DeleteContactRequest(contactIds: data))
                                .asDriver(onErrorJustReturn: DeleteContactState.empty)
                        }
    }
}

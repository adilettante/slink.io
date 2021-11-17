//
//  BusinessCardImportSaveViewModel.swift
//  SalesLinked
//
//  Created by STDev Mac on 8/10/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxOptional

enum BCIButtons: String {

    private static let tags: [Int: BCIButtons] = [
        0: .name,
        1: .email,
        2: .phone,
        3: .company
    ]

	case name
	case email
	case phone
	case company

	init(tag: Int) {
        self = BCIButtons.tags[tag] ?? .name
	}

    var title: String {
        return self.rawValue.capitalized
    }
}

class BusinessCardImportViewModel {
    let disposeBag = DisposeBag()

//    var createState: Driver<UploadUrlState>
    var imageUploadState = PublishSubject<Bool>()

    public let request = Variable(ContactRequest())
    init(
        input: (
            nameTextField: Driver<String>,
            emailTextField: Driver<String>,
            phoneTextField: Driver<String>,
            companyTextField: Driver<String>,
            noteTextField: Driver<String>,
            saveTrigger: Driver<Void>,
            tag: Driver<BCIButtons>,
            image: UIImage,
            bag: DisposeBag
        ),
        service: BussinesCardImportServiceProtocol
    ) {
        input.saveTrigger
            .map { _ in
                UIImageJPEGRepresentation(input.image, 0.7)?
                    .saveDataAsImage(resizeImage: true, folderName: imagesFolderName)
            }
            .filterNil()
            .withLatestFrom(request.asDriver()) { ($0, $1) }
            .map { (imgUrls, request) in
                let card = BusinessCardInfo(
                    image: imgUrls.original.absoluteString,
                    thumbnail: imgUrls.thumbnail?.absoluteString
                )
                card.name = request.name ?? ""
                card.email = request.email ?? ""
                card.phoneNumber = request.phone ?? ""
                card.company = request.company ?? ""
                card.note = request.note?.isNotEmpty ?? true ? request.note : nil // Ignore empty string
                RealmService.shared.addBusinessCard(card)
            }
            .map { _ in true }
            .drive(imageUploadState)
            .disposed(by: disposeBag)

        input.noteTextField
            .drive(onNext: {
                self.request.value.note = $0
            })
            .disposed(by: input.bag)

        input.nameTextField
            .drive(onNext: {
                self.request.value.name = $0
            })
            .disposed(by: input.bag)

        input.emailTextField
            .drive(onNext: {
                self.request.value.email = $0
            })
            .disposed(by: input.bag)

        input.phoneTextField
            .drive(onNext: {
                self.request.value.phone = $0
            })
            .disposed(by: input.bag)

        input.companyTextField
            .drive(onNext: {
                self.request.value.company = $0
            })
            .disposed(by: input.bag)
    }
}

class BusinessCardUpdateViewModel {
    var updateState: Driver<ContactStateSingle>
    var getState: Driver<ContactStateSingle>
    var addState: Driver<ContactNoteState>
    var deleteState: Driver<DeleteContactState>

    init(
        input: (
            deleteTrigger: Driver<Void>,
            nameTextFieldEndEditing: Driver<Void>,
            emailTextFieldEndEditing: Driver<Void>,
            phoneTextFieldEndEditing: Driver<Void>,
            companyTextFieldEndEditing: Driver<Void>,
            noteTextFieldEndEditing: Driver<Void>,
            nameTextField: Driver<String>,
            emailTextField: Driver<String>,
            phoneTextField: Driver<String>,
            companyTextField: Driver<String>,
            noteTextField: Driver<String>,
            tag: Driver<BCIButtons>,
            bag: DisposeBag,
            subject: Driver<Void>,
            idVariable: Variable<String>,
            swipeSubject: Driver<Void>
        ),
        service: BussinesCardUpdateServiceProtocol
        ) {

        deleteState = input.deleteTrigger
            .flatMap { _ in
                return service.deleteContact(contact: DeleteContactRequest(contactId: input.idVariable.value))
                    .asDriver(onErrorJustReturn: DeleteContactState.empty)
        }

        let request = Variable(ContactRequest())
        updateState = Driver.merge(input.nameTextFieldEndEditing, input.emailTextFieldEndEditing,
                                   input.phoneTextFieldEndEditing, input.companyTextFieldEndEditing)
            .withLatestFrom(request.asDriver())
            .flatMap {
                service.updateContact(contact: $0, id: input.idVariable.value)
                    .asDriver(onErrorJustReturn: ContactStateSingle.empty)
        }

        let addSubject = PublishSubject<Void>()

        addState = input.noteTextFieldEndEditing
            .map { request.value.note }
            .filterNil()
            .filterEmpty()
            .filter { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 }
            .flatMap {
                service.addNote(note: ContactNoteRequest(description: $0, contactId: input.idVariable.value))
                    .do(onNext: {_ in
                        addSubject.onNext(())
                    })
                    .asDriver(onErrorJustReturn: ContactNoteState.empty)
        }

        let driver = addSubject.asDriver(onErrorJustReturn: ())

        getState = Driver.merge(input.subject, driver, input.swipeSubject)
            .flatMap {
                service.getContact(contact: input.idVariable.value)
                    .do(onNext: {
                        request.value.company = $0.data?.company
                        request.value.name = $0.data?.name
                        request.value.email = $0.data?.email
                        request.value.phone = $0.data?.phone
                    })
                    .asDriver(onErrorJustReturn: ContactStateSingle.empty)
            }

        input.noteTextField
            .drive(onNext: {
                request.value.note = $0
            })
            .disposed(by: input.bag)

        input.nameTextField
            .drive(onNext: {
                request.value.name = $0
            })
            .disposed(by: input.bag)

        input.emailTextField
            .drive(onNext: {
                request.value.email = $0
            })
            .disposed(by: input.bag)

        input.phoneTextField
            .drive(onNext: {
                request.value.phone = $0
            })
            .disposed(by: input.bag)

        input.companyTextField
            .drive(onNext: {
                request.value.company = $0
            })
            .disposed(by: input.bag)
    }
}

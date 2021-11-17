//
//  DeleteContactsViewController.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 11/15/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxOptional

protocol DeleteContactsViewControllerDelegate: class {
    func itemSelected(id: String, selected: Bool)
}

class DeleteContactsViewController: BaseViewController, DeleteContactsViewControllerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    private var deleteButton: UIButton!
    private var viewModel: DeleteContactsViewModel!
    private let refreshTrigger = PublishSubject<Void>()
    private let deleteTrigger = PublishSubject<[String]>()
    private var contacts = Variable([BusinessCardInfo]())
    private var selectedContacts = Variable([String]())

    private let deleteCell = "DeleteCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        initBarButton()
        initViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTrigger.onNext(())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func deleteAction() {
        deleteButton.isEnabled = false
        showYesNoAlert(message: deleteMessage, yesBtnMessage: "YES", noBtnMessage: "NO",
                       yesAction: { [weak self] _ in
                        guard let strongSelf = self else { return }
                        RealmService.shared.deleteContactsBy(ids: strongSelf.selectedContacts.value, withFlag: true)
            },
                       noAction: { [weak self] _ in self?.deleteButton.isEnabled = true })
    }

    private func initBarButton() {
        deleteButton = UIButton(type: .custom)
        deleteButton.frame = CGRect(x: 0.0, y: 40.0, width: 25.0, height: 25.0)
        deleteButton.setBackgroundImage(#imageLiteral(resourceName: "ic_delete"), for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: deleteButton)
    }

    // MARK: ViewModel initialization
    func initViewModel() {
        let loadNextPageTrigger = self.collectionView.rx.contentOffset
            .map { [weak self] _ -> Bool in
                guard let strongSelf = self else { return false }
                return strongSelf.collectionView.isNearBottomEdge(edgeOffset: 20)
            }
            .filter { $0 }
            .map { _ in () }

        viewModel = DeleteContactsViewModel(
            loadNextPageTrigger: loadNextPageTrigger.asDriver(onErrorJustReturn: ()),
            deleteTrigger: deleteTrigger.asDriver(onErrorJustReturn: []),
            refreshTrigger: refreshTrigger.asDriver(onErrorJustReturn: ()),
            homeService: HomeService(),
            bussinesCardService: BussinesCardUpdateService()
        )

        getDataDrive()
        driveView()
        driveDeleting()
    }

    // MARK: driving
    private func getDataDrive() {
        RealmService.shared.businessCards
            .map { $0.0 }
            .subscribe(onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.contacts.value = data
            })
            .disposed(by: disposeBag)
    }

    private func driveDeleting() {
        viewModel.deleteState
            .map { $0.deleted }
            .filter { $0 }
            .drive(onNext: { [weak self] _ in
                self?.goToLoginPage()
            })
            .disposed(by: disposeBag)
    }

    private func driveView() {
        deleteButton.rx.tap.asDriver()
            .drive(onNext: { [weak self] _ in
                self?.deleteAction()
            })
            .disposed(by: disposeBag)

        contacts.asDriver()
            .drive(collectionView.rx
                .items(
                    cellIdentifier: deleteCell,
                    cellType: DeleteCell.self)
            ) { [weak self] _, element, cell in
                guard let strongSelf = self else { return }
                cell.deleteImage.image = element.image.toUIImage
                cell.pickButton.isSelected = strongSelf.selectedContacts.value.contains(element.id)
                cell.id = element.id
                cell.delegate = strongSelf
            }
            .disposed(by: disposeBag)

        selectedContacts.asDriver()
            .drive( onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.deleteButton.isEnabled = data.isNotEmpty
            })
            .disposed(by: disposeBag)
    }

    // MARK: DeleteContactsViewControllerDelegate
    func itemSelected(id: String, selected: Bool) {
        var selectedContacts = self.selectedContacts.value
        if selected {
            selectedContacts.append(id)
        } else {
            if let index = selectedContacts.index(of: id) {
                selectedContacts.remove(at: index)
            }
        }
        self.selectedContacts.value = selectedContacts
    }

    // MARK: navigation
    private func goToLoginPage() {
        guard let viewControllers: [UIViewController] = self.navigationController?.viewControllers else { return }
        self.navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
}

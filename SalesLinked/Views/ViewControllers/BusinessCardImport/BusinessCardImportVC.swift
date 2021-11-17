//
//  BusinessCardImportVC.swift
//  SalesLinked
//
//  Created by STDev Mac on 8/9/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import KMPlaceholderTextView
import RxSwift
import RxCocoa
import RxOptional
import AlamofireImage
import NVActivityIndicatorView

class BusinessCardImportVC: BaseViewController {

	// MARK: - Outlets
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var save: UIBarButtonItem!
    @IBOutlet weak var cardImageView: UIImageView!
	@IBOutlet weak var textFieldViewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var universalTextFieldNameLabel: UILabel!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var nameButton: BaseCustomButton!
	@IBOutlet weak var emailButton: BaseCustomButton!
	@IBOutlet weak var phoneButton: BaseCustomButton!
	@IBOutlet weak var companyButton: BaseCustomButton!
	@IBOutlet weak var borderVIewHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var commentViewheightConstarint: NSLayoutConstraint!
	@IBOutlet weak var commentTextView: KMPlaceholderTextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var companyTextField: UITextField!
    @IBOutlet weak var nameHeight: NSLayoutConstraint!
    @IBOutlet weak var phoneHeight: NSLayoutConstraint!
    @IBOutlet weak var emailHeight: NSLayoutConstraint!
    @IBOutlet weak var companyHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: BaseCustomButton!
    @IBOutlet weak var buttonsContainerWidth: NSLayoutConstraint!

    // MARK: - Variables
    let textFieldHeight = CGFloat(30)
    var viewModel: BusinessCardImportViewModel?
//    var viewModelEditing: BusinessCardUpdateViewModel?

    private let deleteTrigger = PublishSubject<Void>()
    weak var parentVC: BusinessCardPageController?

    var contactModel: BusinessCardInfo?

	var buttonTag = Variable(BCIButtons(tag: -1))
    var idVariable = Variable(String())
    var swipeSubject = PublishSubject<Void>()
	var selectedButton = [BaseCustomButton]()
	var importedImage = UIImage()
	var businessCardDict = BusinessCardInfo()
    var isUpdating = false
    var contacts: [ContactResponseSingleModel] = []
    let noteIdentifier = "noteCell"
    var notesCount = 0
    let subject = PublishSubject<Void>()
    var previusTag = -1
    var itemPosition = -1

	 // MARK: - Lifecycle
	override func viewDidLoad() {
        super.viewDidLoad()
		cardImageView.image = importedImage
		selectedButton.append(contentsOf: [nameButton, emailButton, phoneButton, companyButton, deleteButton])
		initUI()
		initTapGesture()
        initViewModel()
        showBusinessCardOnboard()
    }

    override func viewDidAppear(_ animated: Bool) {
        subject.onNext(())
    }

    func initViewModel() {
        if !isUpdating {
            deleteButton.isHidden = true
            buttonsContainerWidth.constant -= 65
            viewModel = BusinessCardImportViewModel(
                input: (
                    nameTextField.rx.text.orEmpty.asDriver(),
                    emailTextField.rx.text.orEmpty.asDriver(),
                    phoneTextField.rx.text.orEmpty.asDriver(),
                    companyTextField.rx.text.orEmpty.asDriver(),
                    commentTextView.rx.text.orEmpty.asDriver(),
                    save.rx.tap.asDriver(),
                    buttonTag.asDriver(),
                    importedImage,
                    disposeBag
                ),
                service: BussinesCardImportService()
            )
            doDriving()
        } else {
            setNavigationItems()
            if let card = contactModel {
                setView(model: card)
                updateDoDriving()
            }
        }
    }

    func setNavigationItems() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
    }

    func showBusinessCardOnboard() {
        guard !AppDelegate.bcOnboardsSkipped && UserDefaultsHelper.isNil(.BusinessCardOnboardShowed) else { return }
        guard let vc = SegueHelper.get(BCPagingParentVC.self,
                                       viewController: "BCPagingParentVC", in: .BCOnboarding) else {
                                        return
        }
        self.present(vc, animated: true, completion: nil)
    }

    func doDriving() {
        viewModel?.imageUploadState
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.dismissViewController()
            })
            .disposed(by: disposeBag)
    }

    func updateDoDriving() {
        guard let id = contactModel?.id else { return }

        RealmService.shared.notesForContact(by: id)
            .asDriver(onErrorJustReturn: [])
            .map { $0.filter { $0.note.isNotEmpty } }
            .do(onNext: { [tableView] data in
                tableView?.tableFooterView?.alpha = data.isEmpty ? 0 : 1
            })
            .drive(tableView.rx.items(
                    cellIdentifier: noteIdentifier,
                    cellType: NoteTableViewCell.self
                )
            ) { _, element, cell in
                cell.note.text = element.note
                cell.date.text = DateFormattingHelper.stringFrom(date: element.date, format: .StandartDate)
            }
            .disposed(by: disposeBag)

        nameTextField.rx
            .controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self,
                    strongSelf.nameTextField.text != strongSelf.contactModel?.name,
                    let id = strongSelf.contactModel?.id else { return }
                RealmService.shared.updateCard(name: strongSelf.nameTextField.text ?? "", in: id)
            })
            .disposed(by: disposeBag)

        emailTextField.rx
            .controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self,
                    strongSelf.emailTextField.text != strongSelf.contactModel?.email,
                    let id = strongSelf.contactModel?.id else { return }
                RealmService.shared.updateCard(email: strongSelf.emailTextField.text ?? "", in: id)
            })
            .disposed(by: disposeBag)

        phoneTextField.rx
            .controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self,
                    strongSelf.phoneTextField.text != strongSelf.contactModel?.phoneNumber,
                    let id = strongSelf.contactModel?.id else { return }
                RealmService.shared.updateCard(phone: strongSelf.phoneTextField.text ?? "", in: id)
            })
            .disposed(by: disposeBag)

        companyTextField.rx
            .controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self,
                    strongSelf.companyTextField.text != strongSelf.contactModel?.company,
                    let id = strongSelf.contactModel?.id else { return }
                RealmService.shared.updateCard(company: strongSelf.companyTextField.text ?? "", in: id)
            })
            .disposed(by: disposeBag)

        commentTextView.rx
            .didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let strongSelf = self,
                    !strongSelf.commentTextView.text.isEmpty,
                    let id = strongSelf.contactModel?.id  else { return }
                RealmService.shared.addNote(strongSelf.commentTextView.text, toCard: id)
                strongSelf.commentTextView.text = ""
                SyncService.shared.refreshComments(for: id)
            })
            .disposed(by: disposeBag)

    }

    func dismissViewController() {
        self.save.isEnabled = true
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        self.dismiss(animated: true, completion: nil)
    }

    func setView(model: BusinessCardInfo) {
        SyncService.shared.refreshComments(for: model.id)
        self.title = model.name
        self.cardImageView.image = model.image.toUIImage
        self.nameTextField.text = model.name
        self.emailTextField.text = model.email
        self.phoneTextField.text = model.phoneNumber
        self.companyTextField.text = model.company
    }

	// MARK: - init UI
	func initUI() {
        selectedButton.forEach { button in
            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.2
            button.layer.shadowRadius = 10
        }
	}

	// MARK: - textField wil Hide
	func textFieldWilHide() {
		UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
			strongSelf.textFieldViewHeightConstraint.constant = 0
			strongSelf.borderVIewHeightConstraint.constant = 0
			strongSelf.view.layoutIfNeeded()
		}
	}

	// MARK: - install TapGesture
	func initTapGesture() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
		                                                         action: #selector(BusinessCardImportVC.dismissKeyboard))
		view.addGestureRecognizer(tap)
	}

	// MARK: - UITapGestureRecognizer Action
	@objc func dismissKeyboard() {
		textFieldWilHide()
		self.view.endEditing(true)
	}

	// MARK: - Actions
	@IBAction func getSelectedButtonTag(_ sender: Any) {
        if self.previusTag == (sender as AnyObject).tag {
            self.callOrSend()
        } else {
            self.getKeyboard(tag: (sender as AnyObject).tag)
        }
	}

    func callOrSend() {
        let bciBtn = BCIButtons(tag: self.previusTag)
        if bciBtn == .email {
            send()
        }
        if bciBtn == .phone {
            call()
        }
    }

    func call() {
        guard let phone = self.phoneTextField.text, !phone.isEmpty else { return }
        if let url = URL(string: String(format: "tel://%@", phone)),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    func send() {
        guard let email = self.emailTextField.text, email.isNotEmpty else { return }
        if let url = URL(string: String(format: "mailto://%@", email)) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }

    @IBAction func deleteButtonAction(_ sender: Any) {
        self.deleteButton.isEnabled = false
        showYesNoAlert(
            message: deleteMessage,
            yesBtnMessage: "YES",
            noBtnMessage: "NO",
            yesAction: deleteContact,
            noAction: { [weak self] _ in
                self?.deleteButton.isEnabled = true
        })
    }

    func deleteContact(_ action: UIAlertAction?) {
        guard let id = contactModel?.id else { return }
        RealmService.shared.deleteContact(by: id, withFlag: true)
        parentVC?.dismiss()
    }

	@IBAction func dimissViewController(_ sender: Any) {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - get keyboard
	func getKeyboard(tag: Int) {
        self.previusTag = tag
		self.commentTextView.resignFirstResponder()
		buttonTag.value = BCIButtons(tag: tag)
		UIView.animate(withDuration: 0.3) { [weak self] in
            guard let strongSelf = self else { return }
			strongSelf.textFieldViewHeightConstraint.constant = 60
			strongSelf.borderVIewHeightConstraint.constant = 2
            strongSelf.setConstraints()
            strongSelf.universalTextFieldNameLabel.text = strongSelf.buttonTag.value.title
			strongSelf.view.layoutIfNeeded()
		}
	}

    func setConstraints() {
        self.nameHeight.constant = self.buttonTag.value == .name ? self.textFieldHeight : 0
        self.emailHeight.constant = self.buttonTag.value == .email ? self.textFieldHeight : 0
        self.phoneHeight.constant = self.buttonTag.value == .phone ? self.textFieldHeight : 0
        self.companyHeight.constant = self.buttonTag.value == .company ? self.textFieldHeight : 0
    }

}

extension BusinessCardImportVC: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		textFieldWilHide()
		commentTextView.isScrollEnabled = true
	}
}

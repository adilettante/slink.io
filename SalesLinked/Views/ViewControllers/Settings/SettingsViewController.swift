//
//  SettingsViewController.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/28/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ObjectMapper
import RxOptional
import NVActivityIndicatorView

class SettingsViewController: BaseViewController, NVActivityIndicatorViewable, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableVIew: UITableView!

    private var settingsViewModel: SettingsViewModel!
    private var loginSubject = PublishSubject<UserRequest>()
    private var logOutSubject = PublishSubject<String>()
    private var newId = ""

    private let toTerms = "toTerms"
    private let toPolicy = "toPolicy"
    private let toCommingSoon = "toCommingSoon"
    private let toDeleteContacts = "toDeleteContacts"
    private let settings = ["Delete Contacts",
                            "Change Password",
                            "Help Center",
                            "Terms of Use",
                            "Privacy Policy",
                            "Close Account",
                            "Log In Via LinkedIn"]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewModel()
        self.doDriving()
    }

    func initViewModel() {
        settingsViewModel = SettingsViewModel(
            service: SettingsService(),
            loginDriver: loginSubject.asDriver(onErrorJustReturn: UserRequest(
                linkedInId: "",
                firstName: "",
                lastName: "")
            ),
            logOutDriver: logOutSubject.asDriver(onErrorJustReturn: "")
        )
    }

    // MARK: - linkedIn
    func createSession() -> Observable<Void> {
        return Observable.create { observer in
            LISDKSessionManager.createSession(
                withAuth: [LISDK_BASIC_PROFILE_PERMISSION, LISDK_W_SHARE_PERMISSION],
                state: "2Nmc8X7k9B686a2pU3Ax",
                showGoToAppStoreDialog: true,
                successBlock: { _ in observer.onNext(()) }) { error in
                if let error = error {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    func logOut() {
        startAnimating()
        newId = UUID().uuidString
        logOutSubject.onNext(newId)
    }

    func login() {

        #if targetEnvironment(simulator)
            // This is for debug purposes
            loginSubject.onNext(
                UserRequest(
                    linkedInId: "rS_A0UwFQP",
                    firstName: "Nda",
                    lastName: "Ndan"
                )
            )

        #else

            createSession()
                .subscribe(onNext: {
                        LISDKAPIHelper.sharedInstance().getRequest("https:api.linkedin.com/v1/people/~", success: { [weak self] response in
                            guard let strongSelf = self,
                                let jsonString = response?.data,
                                let data = LinkedInUser(JSONString: jsonString) else { return }
                                DispatchQueue.main.async {
                                    strongSelf.loginSubject.onNext(
                                        UserRequest(
                                            linkedInId: data.id,
                                            firstName: data.firstName,
                                            lastName: data.lastName
                                        )
                                    )
                                }
                        }, error: { error in
                            print("Encounter error: \(error?.localizedDescription ?? "nil")")
                        })
                },
                    onError: { error in
                        print("Encounter error: \(error.localizedDescription)")
                }
                ).disposed(by: disposeBag)

        #endif
    }

    func doDriving() {
        settingsViewModel.updateState
            .map { $0.data }
            .filterNil()
            .drive(onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                UserDefaultsHelper.set(alias: .IsLinkedInLogin, value: "1")
                UserDefaultsHelper.set(alias: .AuthToken, value: data.token)
                strongSelf.tableVIew.reloadData()
            })
            .disposed(by: disposeBag)

        settingsViewModel.logOutState
            .do(onNext: { [weak self] _ in
                self?.stopAnimating()
            })
            .map { $0.data }
            .filterNil()
            .drive(onNext: { [weak self, newId] data in
                UserDefaultsHelper.remove(alias: .IsLinkedInLogin)
                UserDefaultsHelper.set(alias: .AuthToken, value: data.token)
                UserDefaultsHelper.set(alias: .UniqueId, value: newId)
                RealmService.shared.truncate()

                if let folderURL = FileManager.default
                    .containerURL(forSecurityApplicationGroupIdentifier: groupName)?
                    .appendingPathComponent(imagesFolderName, isDirectory: true) {
                    try? FileManager.default.removeItem(at: folderURL)
                }

                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return tableView.dequeueReusableCell(withIdentifier: "settingsExport", for: indexPath)
        case 2:
            return tableView.dequeueReusableCell(withIdentifier: "settingsAccount", for: indexPath)
        case 4:
            return tableView.dequeueReusableCell(withIdentifier: "settingsNotification", for: indexPath)
        default:
            if indexPath.row == 9 && UserDefaultsHelper.get(alias: .IsLinkedInLogin) != nil {
                return tableView.dequeueReusableCell(withIdentifier: "settingsSignOut", for: indexPath)
            }
            return generateStandardCell(tableView: tableView, indexPath: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 1:
            performSegue(withIdentifier: toDeleteContacts, sender: self)
        case 2:
            break
        case 6:
            performSegue(withIdentifier: toTerms, sender: self)
        case 7:
            performSegue(withIdentifier: toPolicy, sender: self)
        case 9:
            if UserDefaultsHelper.get(alias: .IsLinkedInLogin) == nil {
                login()
            } else {
                logOut()
            }
        default:
            performSegue(withIdentifier: toCommingSoon, sender: self)
        }
    }

    func generateStandardCell(tableView: UITableView, indexPath: IndexPath) -> SettingsStandardTableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "settingsStandard", for: indexPath)
            as? SettingsStandardTableViewCell else {
                return SettingsStandardTableViewCell()
        }
        switch indexPath.row {
        case 1:
            cell.label?.text = settings[0]
        case 3:
            cell.label?.text = settings[1]
        case 5, 6, 7, 8:
            cell.label?.text = settings[indexPath.row - 3]
        default:
            cell.label?.text = settings[6]
            cell.cellHeight.constant = 49
            cell.cellMargin.constant = 0
        }
        return cell
    }
}

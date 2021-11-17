//
//  ViewController.swift
//  SalesLinked
//
//  Created by STDev Mac on 6/5/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import CoreData
import RxOptional
import RxSwift
import RxCocoa
import AlamofireImage
import NVActivityIndicatorView

private let reuseIdentifier = "HomeCell"

class HomeVC: BaseViewController, NVActivityIndicatorViewable {

    // MARK: - Outlets
    @IBOutlet weak var homeCollectionView: UICollectionView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!

    var homeViewModel: HomeViewModel!

    static let openSettings = PublishSubject<Void>()
    var remainingView: UIView?
    var remainingCountLabel = UILabel()

    // MARK: - Variables
    var showLoadingVariable = Variable(false)
    var contacts: [BusinessCardInfo] = []
    var selectedImage = UIImage()
    var counter = 0
    private let refreshTrigger = PublishSubject<Void>()
    let toCardDetail = "toCardDetail"
    let openSettingsSegue = "openSettingsSegue"
    var selectedPosition = -1

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitleImage()
        initViewModel()
        doDriving()
        setNotification()
        openHomeOnboards()
    }

    func loaderView() {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.frame = self.tabBarController?.view.frame ?? self.view.frame
        let indicator = UIActivityIndicatorView()
        indicator.center = view.center
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.startAnimating()
        let title = UILabel(frame: CGRect(x: 0, y: view.center.y - 80, width: view.frame.size.width, height: 50))
        title.textAlignment = .center
        title.textColor = .white
        title.text = "Synchronizing..."
        remainingCountLabel.frame = CGRect(
            x: 0,
            y: view.center.y + 30,
            width: view.frame.size.width,
            height: 50
        )
        remainingCountLabel.textAlignment = .center
        remainingCountLabel.textColor = .white
        view.addSubview(remainingCountLabel)
        view.addSubview(indicator)
        view.addSubview(title)
        remainingView = view
        self.tabBarController?.view.addSubview(view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshTrigger.onNext(())
        SyncService.shared.refreshContacts()
    }

    func initViewModel() {
        let key = UserDefaultsHelper.getString(for: .UniqueId) ?? {
            let newKey = UUID().uuidString
            UserDefaultsHelper.set(alias: .UniqueId, value: newKey)
            return newKey
        }()

        let loadNextPageTrigger = self.homeCollectionView.rx.contentOffset
            .map { [weak self] _ -> Bool in
                guard let strongSelf = self else { return false }
                return strongSelf.homeCollectionView.isNearBottomEdge(edgeOffset: 20)
            }
            .filter { $0 }
            .map { _ in () }

        homeViewModel = HomeViewModel(
            loadNextPageTrigger: loadNextPageTrigger,
            refreshTrigger: refreshTrigger.asDriver(onErrorJustReturn: ()),
            tokenRequest: TokenRequest(key: key),
            service: HomeService(),
            showLoadingVariable: showLoadingVariable,
            realmService: RealmService.shared
        )
    }

    func openHomeOnboards() {
        guard !AppDelegate.homeOnboardsSkipped && UserDefaultsHelper.isNil(.HomeOnboardShowed) else { return }
        guard let vc = SegueHelper.get(HomePagingParentVC.self,
                                       viewController: "HomePagingParentVC", in: .HomeOnboarding) else {
                                        return
        }
        self.present(vc, animated: true, completion: nil)
    }

    func openSettingsOnboards() {
        guard !AppDelegate.settingsOnboardsSkipped && UserDefaultsHelper.isNil(.SettingsOnboardShowed) else {
            self.performSegue(withIdentifier: self.openSettingsSegue, sender: nil)
            return
        }
        guard let vc = SegueHelper.get(SettingsPagingParentVC.self,
                                       viewController: "SettingsPagingParentVC", in: .SettingsOnboarding) else {
                                        self.performSegue(withIdentifier: self.openSettingsSegue, sender: nil)
                                        return
        }
        self.present(vc, animated: true, completion: nil)
    }

    func doDriving() {
        homeViewModel.tokenCreated
            .subscribe(onNext: {_ in
                SyncService.shared.refreshContacts()
            })
            .disposed(by: disposeBag)

        settingsButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.openSettingsOnboards()
            })
            .disposed(by: disposeBag)

        HomeVC.openSettings
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                strongSelf.performSegue(withIdentifier: strongSelf.openSettingsSegue, sender: nil)
            })
            .disposed(by: disposeBag)

        showLoadingVariable
            .asDriver()
            .filter { $0 }
            .drive(onNext: { [weak self] _ in
                self?.startAnimating()
            })
            .disposed(by: disposeBag)

        showLoadingVariable
            .asDriver()
            .filter { !$0 }
            .drive(onNext: { [weak self] _ in
                self?.stopAnimating()
            })
            .disposed(by: disposeBag)

        homeCollectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let strongSelf = self else { return }
                guard let vc = SegueHelper.get(
                    BusinessCardPageController.self,
                    viewController: "BusinessCardPageController",
                    in: .BusinessCardImport) else { return }
                vc.selectedItem = indexPath.row
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)

        RealmService.shared.businessCards
            .map { $0.0 }
            .do(onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.contacts = data
            })
            .map { $0.map { $0.thumbnail?.toUIImage ?? #imageLiteral(resourceName: "ic_image_placeholder_") } }
            .bind(to: homeCollectionView
                .rx.items(
                    cellIdentifier: reuseIdentifier,
                    cellType: HomeCell.self)) { _, element, cell in
                        cell.selectedImage.image = element
            }
            .disposed(by: disposeBag)

        SyncService.shared
            .remainingImagesCount
            .distinctUntilChanged()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] count in
                self?.changeCount(to: count)
            })
            .disposed(by: disposeBag)
    }

    func setNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(goForeground),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
    }

    func changeCount(to count: UInt) {
        guard count > 1 else {
            remainingView?.removeFromSuperview()
            remainingView = nil
            return
        }
        if remainingView == nil {
            loaderView()
        }
        remainingCountLabel.text = "Remaining \(count)"
    }

    @objc func goForeground() {
        SyncService.shared.refreshContacts()
    }

    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: nil)
    }
}

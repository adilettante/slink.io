//
//  SettingsPagingParentVC.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 1/22/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsPagingParentVC: UIViewController {

    let disposeBag = DisposeBag()

    let SettingsPageingSegue = "SettingsPageingSegue"

    let skipButtonAttributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.foregroundColor: UIColor(red: 253/255, green: 204/255, blue: 116/255, alpha: 1.0),
        NSAttributedStringKey.font: UIFont(name: "Lato-Black", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    ]

    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var dontShowButton: UIButton!
    @IBOutlet weak var handImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    func initView() {
        skipButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                AppDelegate.settingsOnboardsSkipped = strongSelf.pageControl.currentPage < strongSelf.pageControl.numberOfPages-1
                strongSelf.dismiss(animated: true) {
                    HomeVC.openSettings.onNext(())
                }
            })
            .disposed(by: disposeBag)

        dontShowButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                UserDefaultsHelper.set(alias: .SettingsOnboardShowed, value: true)
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true) {
                    HomeVC.openSettings.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SettingsPagingVC,
            segue.identifier == SettingsPageingSegue {
            vc.parentDelegate = self
        }
    }
}

extension SettingsPagingParentVC: OnboardPagingDelegate {
    func pageChanged(newPage: Int) {
        self.pageControl.currentPage = newPage - 1
        if newPage == 2 {
            self.skipButton.setAttributedTitle(NSAttributedString(string: "DONE",
                                                                  attributes: skipButtonAttributes), for: UIControlState.normal)
            UIView.animate(withDuration: 0.5, animations: {
                self.handImageView.alpha = 0.0
            })
        } else {
            self.skipButton.setAttributedTitle(NSAttributedString(string: "SKIP",
                                                                  attributes: skipButtonAttributes), for: UIControlState.normal)
            UIView.animate(withDuration: 0.5, animations: {
                self.handImageView.alpha = 1
            })
        }
        self.pageLabel.text = "\(newPage)"
    }
}

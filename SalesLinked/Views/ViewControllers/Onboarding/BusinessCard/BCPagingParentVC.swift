//
//  BCPagingParentVC.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 1/19/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BCPagingParentVC: UIViewController {

    let disposeBag = DisposeBag()

    let BCPageingSegue = "BCPageingSegue"

    let skipButtonAttributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.foregroundColor: UIColor(red: 253/255, green: 204/255, blue: 116/255, alpha: 1.0),
        NSAttributedStringKey.font: UIFont(name: "Lato-Black", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    ]

    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var dontShowButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    func initView() {
        skipButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                AppDelegate.bcOnboardsSkipped = strongSelf.pageControl.currentPage < strongSelf.pageControl.numberOfPages-1
                strongSelf.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        dontShowButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                UserDefaultsHelper.set(alias: .BusinessCardOnboardShowed, value: true)
                guard let strongSelf = self else { return }
                strongSelf.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? BCPagingVC,
            segue.identifier == BCPageingSegue {
            vc.parentDelegate = self
        }
    }
}

extension BCPagingParentVC: OnboardPagingDelegate {
    func pageChanged(newPage: Int) {
        self.pageControl.currentPage = newPage - 1
        if newPage == 5 {
            self.skipButton.setAttributedTitle(NSAttributedString(string: "DONE",
                                                                  attributes: skipButtonAttributes), for: UIControlState.normal)
        } else {
            self.skipButton.setAttributedTitle(NSAttributedString(string: "SKIP",
                                                                  attributes: skipButtonAttributes), for: UIControlState.normal)
        }
        self.pageLabel.text = "\(newPage)"
    }
}

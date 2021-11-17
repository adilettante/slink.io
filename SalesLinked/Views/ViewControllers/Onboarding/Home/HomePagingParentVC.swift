//
//  HomePagingParentVC.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 1/22/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

class HomePagingParentVC: UIViewController {

    let disposeBag = DisposeBag()

    let HomePageingSegue = "HomePageingSegue"

    let skipButtonAttributes: [NSAttributedStringKey: Any] = [
        NSAttributedStringKey.foregroundColor: UIColor(red: 253/255, green: 204/255, blue: 116/255, alpha: 1.0),
        NSAttributedStringKey.font: UIFont(name: "Lato-Black", size: 14) ?? UIFont.boldSystemFont(ofSize: 14)
    ]

    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var circlesImgView: UIImageView!
    @IBOutlet weak var clicedCaptureImgView: UIImageView!
    @IBOutlet weak var handVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var handHorisontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var handImageView: UIImageView!
    @IBOutlet weak var dontShowTitle: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        self.animateHand()
    }

    func initView() {
        clicedCaptureImgView.transform = CGAffineTransform(
            scaleX: -clicedCaptureImgView.transform.a,
            y: clicedCaptureImgView.transform.d
        )
        handImageView.transform = CGAffineTransform(
            scaleX: -handImageView.transform.a,
            y: handImageView.transform.d
        )
        skipButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                AppDelegate.homeOnboardsSkipped = strongSelf.pageControl.currentPage < strongSelf.pageControl.numberOfPages-1
                strongSelf.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)

        dontShowTitle.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let strongSelf = self else { return }
                UserDefaultsHelper.set(alias: .HomeOnboardShowed, value: true)
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
        if let vc = segue.destination as? HomePagingVC,
            segue.identifier == HomePageingSegue {
            vc.parentDelegate = self
        }
    }

    func animateHand() {
        UIView.animate(withDuration: 0.5, animations: { [handVerticalConstraint, handHorisontalConstraint, view] in
            handVerticalConstraint?.constant += 10
            handHorisontalConstraint?.constant += 10
            view?.layoutIfNeeded()
        }) { [handVerticalConstraint, handHorisontalConstraint, view] _ in
            UIView.animate(withDuration: 0.5, animations: {
                handVerticalConstraint?.constant -= 10
                handHorisontalConstraint?.constant -= 10
                view?.layoutIfNeeded()
            }) { [weak self] _ in
                self?.animateHand()
            }
        }
    }
    deinit {
        print("Deinit --- VC: \(self.restorationIdentifier ?? "-")")
    }
}
// swiftlint:disable line_lenght
extension HomePagingParentVC: OnboardPagingDelegate {
    func pageChanged(newPage: Int) {
        self.pageControl.currentPage = newPage - 1
        if newPage == 2 {
            self.skipButton.setAttributedTitle(NSAttributedString(string: "DONE",
                                                                  attributes: skipButtonAttributes), for: UIControlState.normal)
            UIView.animate(withDuration: 0.5, animations: { [circlesImgView] in
                circlesImgView?.alpha = 1.0
            })
        } else {
            self.skipButton.setAttributedTitle(NSAttributedString(string: "SKIP",
                                                                  attributes: skipButtonAttributes), for: UIControlState.normal)
            UIView.animate(withDuration: 0.5, animations: { [circlesImgView] in
                circlesImgView?.alpha = 0.0
            })
        }
        self.pageLabel.text = "\(newPage)"
    }
}

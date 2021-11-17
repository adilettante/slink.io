//
//  BCPagingVC.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 1/19/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum BCOnboardPages: Int {
    case NameEmailVC
    case PhoneCompanyVC
    case SendEmailVC
    case PhoneCallVC
    case AddCommentVC

    var pageNumber: Int {
        return self.rawValue + 1
    }

    var identifier: String {
        switch self {
        case .NameEmailVC:
            return "NameEmailVC"
        case .PhoneCompanyVC:
            return "PhoneCompanyVC"
        case .SendEmailVC:
            return "SendEmailVC"
        case .PhoneCallVC:
            return "PhoneCallVC"
        case .AddCommentVC:
            return "AddCommentVC"
        }
    }
}

protocol OnboardPagingDelegate: class {
    func pageChanged(newPage: Int)
}

class BCPagingVC: UIPageViewController {

    let disposeBag = DisposeBag()

    private(set) var orderedViewControllers = [BCOnboardPages: UIViewController?]()
    var initialPage: BCOnboardPages = .NameEmailVC

    weak var parentDelegate: OnboardPagingDelegate?
    var pageIndex: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        orderedViewControllers = getViewControllers()

        changePage(to: initialPage, direction: .forward, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.parentDelegate?.pageChanged(newPage: strongSelf.initialPage.pageNumber)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func changePage(to: BCOnboardPages,
                    direction: UIPageViewControllerNavigationDirection,
                    completion: ((Bool) -> Void)?) {
        if let vc = orderedViewControllers[to], let goToVC = vc {
            setViewControllers([goToVC],
                               direction: direction,
                               animated: true,
                               completion: completion)
        }
    }

    func getViewControllers() -> [BCOnboardPages: UIViewController?] {

        let nameEmailVC: UIViewController? = SegueHelper.get(UIViewController.self,
                                                            viewController: "NameEmailVC",
                                                            in: .BCOnboarding)

        let phoneCompanyVC: UIViewController? = SegueHelper.get(UIViewController.self,
                                                             viewController: "PhoneCompanyVC",
                                                             in: .BCOnboarding)

        let sendEmailVC: UIViewController? = SegueHelper.get(UIViewController.self,
                                                             viewController: "SendEmailVC",
                                                             in: .BCOnboarding)

        let phoneCallVC: UIViewController? = SegueHelper.get(UIViewController.self,
                                                             viewController: "PhoneCallVC",
                                                             in: .BCOnboarding)

        let addCommentVC: UIViewController? = SegueHelper.get(UIViewController.self,
                                                             viewController: "AddCommentVC",
                                                             in: .BCOnboarding)

        return [
            BCOnboardPages.NameEmailVC: nameEmailVC,
            BCOnboardPages.PhoneCompanyVC: phoneCompanyVC,
            BCOnboardPages.SendEmailVC: sendEmailVC,
            BCOnboardPages.PhoneCallVC: phoneCallVC,
            BCOnboardPages.AddCommentVC: addCommentVC
        ]
    }

    deinit {
        print("Deinit --- VC: \(self.restorationIdentifier ?? "-")")
    }

}

// MARK: - UIPageViewControllerDataSource

extension BCPagingVC: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        var viewControllerIndex = 0
        orderedViewControllers.forEach { (key, value) in
            if value == viewController {
                viewControllerIndex = key.rawValue
            }
        }

        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        guard let page = BCOnboardPages(rawValue: nextIndex) else {
            return nil
        }
        guard let vc = orderedViewControllers[page] else {
            return nil
        }
        return vc
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        var viewControllerIndex = 0
        orderedViewControllers.forEach { (key, value) in
            if value == viewController {
                viewControllerIndex = key.rawValue
            }
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        guard let page = BCOnboardPages(rawValue: previousIndex) else {
            return nil
        }
        guard let vc = orderedViewControllers[page] else {
            return nil
        }
        return vc
    }
}

extension BCPagingVC: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let vc = pendingViewControllers.first,
            let page = orderedViewControllers.first(where: {_, value in value == vc })?.key else {
                return
        }
        self.parentDelegate?.pageChanged(newPage: page.pageNumber)
    }
}

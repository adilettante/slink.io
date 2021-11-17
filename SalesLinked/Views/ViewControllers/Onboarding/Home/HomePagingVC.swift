//
//  HomePagingVC.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 1/22/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum HomeOnboardPages: Int {
    case HomeFirstVC
    case HomeSecondVC

    var pageNumber: Int {
        return self.rawValue + 1
    }

    var identifier: String {
        switch self {
        case .HomeFirstVC:
            return "HomeFirstVC"
        case .HomeSecondVC:
            return "HomeSecondVC"
        }
    }
}

class HomePagingVC: UIPageViewController {

    let disposeBag = DisposeBag()

    private(set) var orderedViewControllers = [HomeOnboardPages: UIViewController?]()
    var initialPage: HomeOnboardPages = .HomeFirstVC

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

    func changePage(to: HomeOnboardPages,
                    direction: UIPageViewControllerNavigationDirection,
                    completion: ((Bool) -> Void)?) {
        if let vc = orderedViewControllers[to], let goToVC = vc {
            setViewControllers([goToVC],
                               direction: direction,
                               animated: true,
                               completion: completion)
        }
    }

    func getViewControllers() -> [HomeOnboardPages: UIViewController?] {

        let homeFirstVC: UIViewController? = SegueHelper.get(UIViewController.self,
                                                                 viewController: "HomeFirstVC",
                                                                 in: .HomeOnboarding)

        let homeSecondVC: UIViewController? = SegueHelper.get(UIViewController.self,
                                                                  viewController: "HomeSecondVC",
                                                                  in: .HomeOnboarding)

        return [
            HomeOnboardPages.HomeFirstVC: homeFirstVC,
            HomeOnboardPages.HomeSecondVC: homeSecondVC
        ]
    }

    deinit {
        print("Deinit --- VC: \(self.restorationIdentifier ?? "-")")
    }

}

// MARK: - UIPageViewControllerDataSource

extension HomePagingVC: UIPageViewControllerDataSource {
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
        guard let page = HomeOnboardPages(rawValue: nextIndex) else {
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
        guard let page = HomeOnboardPages(rawValue: previousIndex) else {
            return nil
        }
        guard let vc = orderedViewControllers[page] else {
            return nil
        }
        return vc
    }
}

extension HomePagingVC: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed else { return }
        guard let vc = previousViewControllers.first,
            let prevPage = orderedViewControllers.first(where: {_, value in value == vc })?.key else {
                return
        }
        let currentPage: HomeOnboardPages = prevPage == .HomeFirstVC ? .HomeSecondVC : .HomeFirstVC
        self.parentDelegate?.pageChanged(newPage: currentPage.pageNumber)

    }
}

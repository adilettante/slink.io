//
//  BusinessCardPageController.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 3/23/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BusinessCardPageController: UIPageViewController {
    let disposeBag = DisposeBag()

    var orderedViewControllers = [UIViewController]()

    var selectedItem: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        setViewControllers()
        view.backgroundColor = .white
        guard self.selectedItem < orderedViewControllers.count else { return }
        let initial = orderedViewControllers[selectedItem]
        self.setViewControllers([initial],
                                      direction: .forward,
                                      animated: false,
                                      completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setViewControllers() {
        orderedViewControllers = RealmService.shared
            .getCards()
            .compactMap { [weak self] card -> BusinessCardImportVC? in
                    guard let vc = SegueHelper.get(
                        BusinessCardImportVC.self,
                        viewController: "BusinessCardImportVC",
                        in: .BusinessCardImport) else { return nil }
                    vc.parentVC = self
                    vc.contactModel = card
                    vc.isUpdating = true
                    return vc
                }
    }

    func dismiss() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    deinit {
        print("Deinit --- VC: \(self.restorationIdentifier ?? "-")")
    }

}

extension BusinessCardPageController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }

        let nextIndex = viewControllerIndex + 1

        let orderedViewControllersCount = orderedViewControllers.count

        guard orderedViewControllersCount != nextIndex && orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else { return nil }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 && orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
}

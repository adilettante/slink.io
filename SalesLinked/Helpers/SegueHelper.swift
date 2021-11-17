//
//  SegueHelper.swift
//  SalesLinked
//
//  Created by Yervand Saribekyan on 1/19/18.
//  Copyright © 2018 STDev. All rights reserved.
//

import Foundation
import UIKit

enum StoryboardName: String {
    case Main
    case BusinessCardImport

    case BCOnboarding
    case SettingsOnboarding
    case HomeOnboarding
}

class SegueHelper {

    static func get(viewController: String,
                    inStoryboard: StoryboardName) -> UIViewController {

        let storyBoard: UIStoryboard = UIStoryboard(name: inStoryboard.rawValue, bundle: nil)
        let newViewController = storyBoard.instantiateViewController(withIdentifier: viewController)
        return newViewController

    }

    static func get<T: UIViewController>(_ type: T.Type, viewController name: String, in storyboard: StoryboardName) -> T? {
        return SegueHelper.get(viewController: name, inStoryboard: storyboard) as? T
    }

    static func popBack<T: UIViewController>(toControllerType: T.Type, from: UIViewController) {
        if var viewControllers: [UIViewController] = from.navigationController?.viewControllers {
            viewControllers = viewControllers.reversed()
            for currentViewController in viewControllers where currentViewController.isKind(of: toControllerType) {
                    _ = from.navigationController?.popToViewController(currentViewController, animated: true)
            }
        }
    }

}

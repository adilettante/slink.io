//
//  AppDelegate.swift
//  SalesLinked
//
//  Created by STDev Mac on 5/31/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import AlamofireNetworkActivityIndicator
import NVActivityIndicatorView
import AlamofireImage
import SDWebImage
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    static var homeOnboardsSkipped = false
    static var settingsOnboardsSkipped = false
    static var bcOnboardsSkipped = false

    var window: UIWindow?

	// MARK: - Application lifecycle
    func application(_ application: UIApplication,
                          didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        NetworkActivityIndicatorManager.shared.isEnabled = true
		navBarBackButtonConfig()
		IQKeyboardManager.shared.enable = true
        SDWebImageManager.shared().cacheKeyFilter = { url in
            return url?.path
        }

        // MARK: - Realm migration configurations
        _ = RealmService.shared

        setVersions()

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        if LISDKCallbackHandler.shouldHandle(url) {
            LISDKCallbackHandler.application(
                app,
                open: url,
                sourceApplication: options[.sourceApplication] as? String,
                annotation: options
            )
        }
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

	// MARK: - Navigation bar back button configureion
	func navBarBackButtonConfig() {
		UIBarButtonItem.appearance().setTitleTextAttributes(nil, for: .normal)
		UINavigationBar.appearance().barTintColor = UIColor(red: 245, green: 244, blue: 240, alpha: 1.0)
	}

    private func setVersions() {
        UserDefaultsHelper.set(alias: .ApiVersion, value: Config.API_VERSION)
        if let releaseVersionNumber = Bundle.main.releaseVersionNumber,
            let buildVersionNumber = Bundle.main.buildVersionNumber {
            UserDefaultsHelper.set(alias: .AppVersion, value: releaseVersionNumber + " (" + buildVersionNumber + ")")
        }

    }

}

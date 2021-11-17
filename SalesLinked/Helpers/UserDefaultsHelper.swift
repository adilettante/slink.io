//
//  UserDefaultsHelperSwift.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation

enum UDAliases: String {
    case AuthToken = "auth_token"
    case UniqueId = "unique_id"
    case IsLinkedInLogin = "is_linked_in_login"
    case HomeOnboardShowed = "home_onboard_showed"
    case SettingsOnboardShowed = "settings_onboard_showed"
    case BusinessCardOnboardShowed = "businessCard_onboard_showed"
    case DontShowAnyOnboard = "dont_show_any_onboard"
    case AppVersion = "app_version_preference"
    case ApiVersion = "api_version_preference"
}

class UserDefaultsHelper {

    static func isNil(_ alias: UDAliases) -> Bool {
        return self.get(alias: alias) == nil
    }

    static func getString(for alias: UDAliases) -> String? {
        return UserDefaults.standard.string(forKey: alias.rawValue)
    }

    static func get(alias: UDAliases) -> Any? {
        return UserDefaults.standard.string(forKey: alias.rawValue)
    }

    static func set(alias: UDAliases, value: String) {
        UserDefaults.standard.set(value, forKey: alias.rawValue)
    }

    static func set(alias: UDAliases, value: Any?) {
        UserDefaults.standard.set(value, forKey: alias.rawValue)
    }

    static func remove(alias: UDAliases) {
        UserDefaults.standard.removeObject(forKey: alias.rawValue)
    }

    static func remove(aliases: UDAliases...) {
        aliases.forEach { (alias) in
            UserDefaults.standard.removeObject(forKey: alias.rawValue)
        }
    }

}

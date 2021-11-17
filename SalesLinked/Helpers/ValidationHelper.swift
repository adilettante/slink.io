//
//  ValidationHelper.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 10/9/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation

struct LengthConstants {
    static let MinimalNamesLength = 3
    static let MinimalUserIdLength = 3
    static let MinimalPasswordLength = 8
    static let MinimalActivationCodeLength = 6
}

enum RegExType: String {
    case EmailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
    case PhoneRegEx = "[0-9-()+]{3,20}"
    case UserIdRegEx = "[A-Z0-9a-z._%+-]+"
}

class Validation {

    static func validate(userId: String) -> Bool {
        return self.validate(string: userId, regEx: RegExType.UserIdRegEx.rawValue)
    }

    static func validate(email: String) -> Bool {
        return self.validate(string: email, regEx: RegExType.EmailRegEx.rawValue)
    }

    static func validate(phone: String) -> Bool {
        return self.validate(string: phone, regEx: RegExType.PhoneRegEx.rawValue)
    }

    static func validate(string: String, regEx: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", regEx)
        return test.evaluate(with: string)
    }

}

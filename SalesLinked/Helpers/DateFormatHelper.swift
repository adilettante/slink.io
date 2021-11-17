//
//  DateFormatHelper.swift
//  SalesLinked
//
//  Created by STDev's Mac Mini 4 on 9/29/17.
//  Copyright © 2017 STDev. All rights reserved.
//

import Foundation

enum DateFormat: String {
    case ShortDate = "MM/dd/yy"
    case BackDate = "dd/MM/yy"
    case StandartDate = "MM-dd-yyyy"
    case LongDate = "MMMM dd, yyyy"
}

enum DateFormatterFormats: String {
    case long = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    case short = "yyyy-MM-dd"
    case noteDate = "dd/MM/yy"
}

class DateFormattingHelper {

    static private let formatter = DateFormatter()

    static let formatterForParse = { (_ format: DateFormatterFormats ) -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        return dateFormatter
    }

    static func stringFrom(date: Date?, format: DateFormat) -> String {
        guard let date = date else {
            return ""
        }
        formatter.dateFormat = format.rawValue
        return formatter.string(from: date)
    }

    static func string(from date: Date?, format: DateFormatterFormats) -> String {
        guard let date = date else {
            return ""
        }
        formatter.dateFormat = format.rawValue
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter.string(from: date)
    }

    static func dateFrom(string: String, format: DateFormat) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format.rawValue
        let date = dateFormatter.date(from: string)
        return date
    }

    static func format(stringDate: String, from: DateFormat, to: DateFormat) -> String {
        return DateFormattingHelper.stringFrom(date: DateFormattingHelper.dateFrom(string: stringDate, format: from), format: to)
    }

}

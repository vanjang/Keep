//
//  Date+Extension.swift
//  Keep
//
//  Created by myung hoon on 28/03/2024.
//

import Foundation
//https://stackoverflow.com/questions/43663622/is-a-date-in-same-week-month-year-of-another-date-in-swift
extension Date {
    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}

extension Date {
    static func getDate(from timeInterval: TimeInterval) -> Date { .init(timeIntervalSince1970: timeInterval / 1000) }
}

extension Date {
    var timeIntervalSince1970Ms: TimeInterval {
        Date().timeIntervalSince1970 * 1000
    }
}

extension Date {
    func toISOString(with options: ISO8601DateFormatter.Options = [.withInternetDateTime]) -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = options
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: self)
    }
}

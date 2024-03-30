//
//  DateFormatter+Extension.swift
//  Keep
//
//  Created by myung hoon on 28/03/2024.
//

import Foundation

// dateformatter is very expensive so use singleton
extension DateFormatter {
    private static let formatter = DateFormatter()
    
    enum TimeFormat: String {
        case time, yesterday, dateAndMonth, dateMonthAndYear, dateAndTime
        
        var toString: String {
            switch self {
            case .dateAndTime: return "yyyy. M. d. HH:mm"
            case .time: return "HH:mm"
            case .yesterday: return "Yesterday"
            case .dateAndMonth: return isKorea ? "M. d." : "MMMd"
            case .dateMonthAndYear: return isKorea ? "yyyy. M. d." : "YYYYMMMd"
            }
        }
    }
    
    private static var isKorea: Bool { Locale.getPreferredLocale.identifier.prefix(2) == "ko" }
    
    /**
     <Display Logic>
     - 당일 : 시간/분으로 표시(24시간) 15:08
     - 하루전 : Yesterday
     - 이틀전부터 날짜 표시 : 1월2일 > 1.2
     - 해가 바뀌경우 년도 + 날짜 표시 : 2021. 12. 30.
     
     <Locale logic>
     Priortising device's perferred language. If there is no preferred language, use Locale.current(= iphone language in Lanugage & Region setting)
     
     <References>
     Locale identifiers https://gist.github.com/jacobbubu/1836273
     id breakdown https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html#//apple_ref/doc/uid/10000171i-CH15-SW9
     template https://stackoverflow.com/questions/55091213/what-are-the-format-specifiers-allowed-in-ios-dateformatter-dateformat-fromtempl/55093100#55093100
     */
    static func getDiplayTimeString(timeInterval: TimeInterval, preferredFormat: TimeFormat? = nil) -> String {
        let chatDate = Date.getDate(from: timeInterval)
        var format = ""
        
        if let preferred = preferredFormat {
            format = preferred.toString
        } else if chatDate.isInYesterday {
            return TimeFormat.yesterday.toString
        } else if chatDate.isInToday {
            format = TimeFormat.time.toString
        } else if chatDate.isInThisYear {
            format = TimeFormat.dateAndMonth.toString
        } else {
            format = TimeFormat.dateMonthAndYear.toString
        }
        
        if isKorea {
            formatter.dateFormat = format
        } else {
            formatter.setLocalizedDateFormatFromTemplate(format)
        }
        
        return formatter.string(from: chatDate).replacingOccurrences(of: ",", with: ".")
    }
}

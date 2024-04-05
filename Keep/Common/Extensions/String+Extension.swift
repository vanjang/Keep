//
//  String+Extension.swift
//  Keep
//
//  Created by myung hoon on 05/04/2024.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: self)
    }
}

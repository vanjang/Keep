//
//  Locale+Extension.swift
//  Keep
//
//  Created by myung hoon on 28/03/2024.
//

import Foundation

extension Locale {
    static var getPreferredLocale: Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
        
    }
}

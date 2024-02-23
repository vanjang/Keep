//
//  BounceBehavior.swift
//  Keep
//
//  Created by myung hoon on 23/02/2024.
//

import Foundation
import SwiftUI

enum BounceBehavior {
    case basedOnSize
    case always
    case automatic
}

extension BounceBehavior {
    @available(iOS 16.4, *)
    func toScrollBounceBehavior() -> ScrollBounceBehavior {
        switch self {
        case .basedOnSize:
            return .basedOnSize
        case .always:
            return .always
        case .automatic:
            return .automatic
        }
    }
}

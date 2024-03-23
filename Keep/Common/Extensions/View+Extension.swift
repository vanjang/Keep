//
//  View+Extension.swift
//  Keep
//
//  Created by myung hoon on 23/03/2024.
//

import SwiftUI

extension View {
    func manualPopBack() -> some View {
        ManualPopBackModifier(content: self)
    }
}

//
//  View+Extension.swift
//  Keep
//
//  Created by myung hoon on 23/03/2024.
//

import SwiftUI

extension View {
    func adjustOffsetbyKeyboardHeight() -> some View {
        OffsetAdjustableModifier(content: self)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)?) -> some View {
        if let view = transform(self), !(view is EmptyView) {
            view
        } else {
            self
        }
    }
}

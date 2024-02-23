//
//  ListBackgroundModifier.swift
//  Keep
//
//  Created by myung hoon on 23/02/2024.
//

import SwiftUI

struct ListBackgroundModifier: ViewModifier {
    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

//
//  ScrollView+Extension.swift
//  Keep
//
//  Created by myung hoon on 23/02/2024.
//

import SwiftUI

extension ScrollView {
    @ViewBuilder
    func bounceBehaviourForScrollView(_ behavior: BounceBehavior, axes: Axis.Set) -> some View {
        if #available(iOS 16.4, *) {
            self.scrollBounceBehavior(behavior.toScrollBounceBehavior())
        } else {
            self
        }
    }
    
    enum ScrollDismissesKeyboardModeConverter {
        case automatic, immediately, interactively, never
    }
    
    @ViewBuilder
    func scrollToDismissKeyboard(mode: ScrollDismissesKeyboardModeConverter) -> some View {
        if #available(iOS 16.0, *) {
            switch mode {
            case .automatic: scrollDismissesKeyboard(.automatic)
            case .immediately: scrollDismissesKeyboard(.immediately)
            case .interactively: scrollDismissesKeyboard(.interactively)
            case .never: scrollDismissesKeyboard(.never)
            }
        } else {
            self.gesture(
                DragGesture().onChanged { gesture in
                    if gesture.translation.height > 0 {
                        UIApplication.shared.endEditing()
                    }
                }
            )
        }
    }
}

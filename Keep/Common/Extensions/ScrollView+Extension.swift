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
}

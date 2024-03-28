//
//  OffsetAdjustableModifier.swift
//  Keep
//
//  Created by myung hoon on 27/03/2024.
//

import SwiftUI
import Combine

struct OffsetAdjustableModifier<Content: View>: View {
    @State private var offset: CGFloat = 0
    let content: Content
    
    var body: some View {
        content
            .offset(y: -offset)
            .animation(.easeOut(duration: 0.16), value: offset)
            .onReceive(Publishers.keyboardHeight) { height in
                let isUp = height > 1
                let setUpOffset = {
                    let keyboardTop = UIScreen.main.bounds.height - height
                    let focusedTextInputBottom = (UIResponder.currentFirstResponder()?.globalFrame?.maxY ?? 0) + 45//20
                    self.offset = max(0, focusedTextInputBottom - keyboardTop)
                }
                
                if isUp {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.16, execute: setUpOffset)
                } else {
                    setUpOffset()
                }
            }
    }
    
}


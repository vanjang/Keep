//
//  ManualPopBackModifier.swift
//  Keep
//
//  Created by myung hoon on 23/03/2024.
//

import SwiftUI

struct ManualPopBackModifier<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let content: Content
    
    var body: some View {
        content
            .gesture(DragGesture().onChanged { _ in
                self.presentationMode.wrappedValue.dismiss()
            })
    }
}

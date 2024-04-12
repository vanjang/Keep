//
//  BottomSheetView.swift
//  Keep
//
//  Created by myung hoon on 29/03/2024.
//

import SwiftUI

struct BottomSheetView<Content: View>: View {
    let content: Content
    @Binding var isShowing: Bool
    
    init(isShowing: Binding<Bool>, @ViewBuilder content: () -> Content) {
         self.content = content()
         _isShowing = isShowing
     }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if isShowing {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isShowing = false
                        }
                    }
                
                VStack {
                    content
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 250)
                .background(.white)
                .cornerRadius(16, corners: .topLeft)
                .cornerRadius(16, corners: .topRight)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.easeInOut, value: isShowing)
    }
}

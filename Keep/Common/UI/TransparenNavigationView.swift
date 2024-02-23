//
//  TransparenNavigationView.swift
//  Keep
//
//  Created by myung hoon on 21/02/2024.
//

import SwiftUI

struct TransparenNavigationView<Content: View>: View {
    let content: Content
     
     init(@ViewBuilder content: () -> Content) {
         self.content = content()
         
         let appearance = UINavigationBarAppearance()
         appearance.configureWithTransparentBackground()
         appearance.backgroundColor = .mainGray
         
         UINavigationBar.appearance().isTranslucent = false
         UINavigationBar.appearance().tintColor = .clear
         UINavigationBar.appearance().standardAppearance = appearance
         UINavigationBar.appearance().compactAppearance = appearance
         UINavigationBar.appearance().scrollEdgeAppearance = appearance
         UINavigationBar.appearance().barStyle = .default
     }
     
     var body: some View {
         NavigationView {
             content
         }
     }
}

struct TransparenNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TransparenNavigationView {
            Text("Hello, World!")
        }
        
    }
}

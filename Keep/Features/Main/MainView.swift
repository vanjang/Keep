//
//  MainView.swift
//  Keep
//
//  Created by myung hoon on 29/02/2024.
//

import SwiftUI


@main
struct MainApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AuthView().opacity(authManager.isAuthenticated ? 1: 0)
                MainListView().opacity(authManager.isAuthenticated ? 0 : 1)
            }
            .preferredColorScheme(.light)
            .environmentObject(authManager)
        }
    }
}

//
//  AuthButton.swift
//  Keep
//
//  Created by myung hoon on 13/03/2024.
//

import SwiftUI

struct AuthButton: View {
    @EnvironmentObject var authManager: AuthManager

    var body: some View {
        Button(action: {
            self.authManager.isAuthenticated.toggle()
        }) {
            Text("Unlock!")
        }
    }
}
struct AuthButton_Previews: PreviewProvider {
    static var previews: some View {
        AuthButton()
    }
}

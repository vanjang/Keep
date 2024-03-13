//
//  AuthView.swift
//  Keep
//
//  Created by myung hoon on 29/02/2024.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        AuthButton()
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}

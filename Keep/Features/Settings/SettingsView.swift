//
//  SettingsView.swift
//  Keep
//
//  Created by myung hoon on 22/02/2024.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            List {
                Section(header: Text("Authentication")) {
                    Text("Face ID")
                    Text("Touch ID")
                    Text("Passcode")
                    Text("None(not recommended!)")
                }.listSectionSeparator(.hidden)

                Section(header: Text("Data Management")) {
                    Text("Save to iCloud")
                    Text("Remove all")
                }.listSectionSeparator(.hidden)

            }
            .listStyle(PlainListStyle())
            .padding(.top, geometry.safeAreaInsets.top)
            .background(Color.mainGray)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                    .accentColor(.pink)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

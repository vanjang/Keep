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
                
                Section(header: Text("Contact")) {
                    Text("Ask for Developer")
                }.listSectionSeparator(.hidden)

            }
            .listStyle(PlainListStyle())
            .background(Color.mainGray)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

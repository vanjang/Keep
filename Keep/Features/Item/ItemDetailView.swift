//
//  ItemDetailView.swift
//  Keep
//
//  Created by myung hoon on 22/02/2024.
//

import SwiftUI

struct ItemDetailView: View {
    @State private var text = ""
    
    private let inputType: ItemInputType
    private let placeholder: String
    
    init(placeholder: String, inputType: ItemInputType) {
        self.placeholder = placeholder
        self.inputType = inputType
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            TextField(placeholder, text: $text)
                .padding()
                .background(.white)
                .cornerRadius(16)
                .textFieldStyle(PlainTextFieldStyle())
            
            Button(action: {
                print("Button tapped!")
            }) {
                Image(systemName: getIcon(inputType: inputType))
                    .foregroundColor(.pink)
            }
            .padding(.trailing, 8)
        }
    }
    
    private func getIcon(inputType: ItemInputType) -> String {
        switch inputType {
        case .textField:
            return "x.circle"
        case .textEdit:
            return "x.circle"
        case .digit:
            return "x.circle"
        case .mmyy:
            return "x.circle"
        case .sortCode:
            return "x.circle"
        }
    }
}

struct ItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(placeholder: "test", inputType: .textField)
    }
}

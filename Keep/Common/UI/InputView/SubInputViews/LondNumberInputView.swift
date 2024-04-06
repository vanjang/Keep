//
//  LondNumberInputView.swift
//  Keep
//
//  Created by myung hoon on 05/04/2024.
//

import SwiftUI

struct LondNumberInputView: InputViewType, View {
    //MARK: - Init
    let placeholder: String
    let currentText: String?
    let canEdit: Bool
    let disabled: Bool
    let canDelete: Bool
    let canPresentMenu: Bool
    @Binding var refresh: Bool
    var inputText: (String) -> Void
    
    //MARK: - States
    @State var text: String = ""
    @State private var previousValue: String = ""
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                TextField(placeholder, text: $text)
                    .foregroundColor(disabled ? Color(uiColor: .darkGray) : .black)
                    .padding()
                    .padding(.trailing, 20)
                    .disabled(disabled)
                    .background(.white)
                    .cornerRadius(16)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: text) { newValue in
                        let deleting = newValue.count < previousValue.count
                        if !deleting && newValue.count % 5 == 0 && newValue.count > 0 {
                            text.insert(" ", at: text.index(text.endIndex, offsetBy: -1))
                        }
                        previousValue = newValue
                    }
                    .contextMenu {
                        if canPresentMenu {
                            Button {
                                UIPasteboard.general.string = text
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        } else {
                            EmptyView()
                        }
                    }
                
                if canDelete && !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
                        Image(systemName: "x.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                            .foregroundColor(Color(uiColor: .systemBlue))
                    }
                    .padding(.trailing, 12)
                }
            }
            
            if canEdit {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundColor(Color(uiColor: .systemBlue))
            }            
        }
        .onChange(of: text) { newValue in
            inputText(newValue)
        }
        .onChange(of: refresh) { newValue in
            text = ""
        }
        .onAppear {
            if let currentText = currentText {
                text = currentText
            }
        }
    }
}

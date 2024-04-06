//
//  MultilineInputView.swift
//  Keep
//
//  Created by myung hoon on 05/04/2024.
//

import SwiftUI
import Combine

struct MultilineInputView: InputViewType, View {
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
    @State private var isEditing = false
    @State private var didBeginEditing = false
    
    //MARK: -
    private let characterLimit = 500
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                ZStack(alignment: .topLeading) {
                    VStack {
                        TextEditor(text: $text)
                            .foregroundColor(disabled ? Color(uiColor: .darkGray) : .black)
                            .frame(height: isEditing || !text.isEmpty ? 150 : 50)
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .disabled(disabled)
                            .background(.white)
                            .cornerRadius(16)
                            .onChange(of: text) { newText in
                                if newText.count > characterLimit {
                                    text = String(newText.prefix(characterLimit))
                                }
                            }
                            .onReceive(Publishers.keyboardHeight) { height in
                                let keyboardUp = height > 0
                                didBeginEditing = keyboardUp
                                isEditing = keyboardUp && didBeginEditing
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
                                
                                if !disabled {
                                Text("\(characterLimit - text.count)/\(characterLimit)")
                                    .foregroundColor(text.count > characterLimit ? .red : .secondary)
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .padding(.trailing, 8)
                                    .padding(.top, 2)
                            }
                        
                    }
                    
                    Text(placeholder)
                        .foregroundColor(Color(uiColor: .placeholderText))
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.leading, 4)
                        .opacity(text.isEmpty ? 1 : 0)
                        .allowsHitTesting(false)
                }
                
                if canEdit {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                        .foregroundColor(Color(uiColor: .systemBlue))
                }                
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

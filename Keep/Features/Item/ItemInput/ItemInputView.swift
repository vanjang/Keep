//
//  ItemInputView.swift
//  Keep
//
//  Created by myung hoon on 22/02/2024.
//

import SwiftUI
import Combine

struct ItemInputView: View {
    // init
    let placeholder: String
    let inputType: ItemInputType
    let displayType: ItemDisplayType
    @Binding var editButtonTap: String
    
    // states
    @State private var text = ""
    @State private var isEditing = false
    @State private var didBeginEditing = false
    @State private var previousValue: String = ""
    @State private var isKeypadDigit = false
    @State private var selectedDate: Date? = nil
    @State private var isShowingDatePicker = false

    //
    private let characterLimit = 500
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                switch inputType {
                case .textField:
                    TextField(placeholder, text: $text)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .padding(.trailing, 20)
                        .disabled(displayType != .add)
                        .background(.white)
                        .cornerRadius(16)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(isKeypadDigit ? .numberPad: .default)

                    Button(action: {
                        text = ""
                    }) {
                        if displayType == .current && !text.isEmpty {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color(uiColor: .systemBlue))
                        } else

                        if !text.isEmpty {
                            Image(systemName: "x.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(.pink)
                        }
                    }
                    .padding(.trailing, 8)
                case .textEditor:
                    ZStack(alignment: .topLeading) {
                        VStack {
                            TextEditor(text: $text)
                                .frame(height: isEditing || !text.isEmpty ? 150 : 50)
                                .padding(.horizontal)
                                .padding(.top, 8)
                                .disabled(displayType != .add)
                                .background(.white)
                                .cornerRadius(16)
                                .onChange(of: text) { newText in
                                    if newText.count > characterLimit {
                                        text = String(newText.prefix(characterLimit))
                                    }
                                }
                                .onTapGesture {
                                    didBeginEditing = true
                                }
                                .onReceive(Publishers.keyboardHeight) { height in
                                    let keyboardUp = height > 0

                                    if !keyboardUp {
                                        didBeginEditing = false
                                    }
                                    isEditing = keyboardUp && didBeginEditing
                                }

                            if displayType == .add {
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
                    }
                case .cardNumber:
                    TextField(placeholder, text: $text)
                        .padding()
                        .padding(.trailing, 20)
                        .disabled(displayType != .add)
                        .background(.white)
                        .cornerRadius(16)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(isKeypadDigit ? .numberPad: .default)
                        .onChange(of: text) { newValue in
                            let deleting = newValue.count < previousValue.count
                            if !deleting && newValue.count % 5 == 0 && newValue.count > 0 {
                                text.insert(" ", at: text.index(text.endIndex, offsetBy: -1))
                            }
                            previousValue = newValue
                        }

                    Button(action: {
                        text = ""
                    }) {
                        if displayType == .current && !text.isEmpty {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color(uiColor: .systemBlue))
                        } else

                        if !text.isEmpty {
                            Image(systemName: "x.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(.pink)
                        }
                    }
                    .padding(.trailing, 8)

                case .date:
                    let dateString = selectedDate?.formatted(date: .long, time: .omitted)

                    Text(dateString ?? placeholder)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(selectedDate != nil ? .black : Color(uiColor: .placeholderText))
                        .padding()
                        .padding(.trailing, 20)
                        .background(.white)
                        .overlay(content: {
                            GeometryReader { geometry in
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .contentShape(Rectangle())
                                    .frame(width: geometry.size.width * 0.8, height: geometry.size.height)
                                    .onTapGesture {
                                        isShowingDatePicker.toggle()
                                    }
                            }
                        })
                        .cornerRadius(16)
                        .fullScreenCover(isPresented: $isShowingDatePicker, content: {
                            DatePickerView(selectedDate: $selectedDate, isPresented: $isShowingDatePicker)
                                .background(Color(uiColor: .systemGray6))
                        })
                        .transaction({ transaction in
                            transaction.disablesAnimations = true
                        })

                    Button(action: {
                        selectedDate = nil
                    }) {
                        if displayType == .current && !(dateString?.isEmpty ?? false) {
                            Image(systemName: "doc.on.doc")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color(uiColor: .systemBlue))
                        } else if selectedDate != nil {
                            Image(systemName: "x.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(.pink)
                        }
                    }
                    .padding(.trailing, 8)

                }

            }
            
            if displayType == .edit {
                Button {
                    editButtonTap = placeholder
                } label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                        .foregroundColor(Color(uiColor: .systemBlue))
                }
            }
            
        }
    }
}

//
//  ItemDetailView.swift
//  Keep
//
//  Created by myung hoon on 22/02/2024.
//

import SwiftUI
import UIKit
import Combine

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ItemDetailView: View {
    //MARK: - init
    let itemSubType: ItemSubType
    let inputType: ItemInputType
    let displayType: ItemDisplayType
    let placeholder: String
    
    var currentText: String? = nil
    
    @Binding var refresh: Bool
    @Binding var editButtonTap: String
    @Binding var userInputItem: UserInputItem?
    
    //MARK: - states
    @State private var text = ""
    @State private var isEditing = false
    @State private var didBeginEditing = false
    @State private var previousValue: String = ""
    @State private var selectedDate: Date? = nil
    @State private var isShowingDatePicker = false
    @State private var showToast = false
//    @State private var isCopyPopupVisible = false
//        @State private var copiedText: String = ""

    //MARK: -
    private let characterLimit = 500
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                switch inputType {
                case .plain:
                    TextField(placeholder, text: $text)
                        .multilineTextAlignment(.leading)
                        .padding()
                        .padding(.trailing, 20)
                        .disabled(displayType != .add)
                        .background(.white)
                        .cornerRadius(16)
                        .textFieldStyle(PlainTextFieldStyle())
                    // current 모드에서만 되게
                        .if(displayType == .current, transform: { view in
                            view
                                .contextMenu {
                                Button {
//                                    print("Pills selected")
                                    UIPasteboard.general.string = text
                                    showToast.toggle()
                                } label: {
                                    Label("Copy", systemImage: "doc.on.doc")
                                }
                                Button {
//                                    print("Heart selected")
                                    editButtonTap = itemSubType.rawValue//UUID().uuidString
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
//                                Button {
//                                    print("ECG selected")
//                                } label: {
//                                    Label("ECG", systemImage: "waveform.path.ecg")
//                                }
                            }
                        })
                            
                    
                    
//                        .onTapGesture {
//                            Menu {
//                                Button(action: {
//
//                                }) {
//                                    Label("Add", systemImage: "plus.circle")
//                                }
//                                Button(action: {
//
//                                }) {
//                                    Label("Delete", systemImage: "minus.circle")
//                                }
//                                Button(action: {
//
//                                }) {
//                                    Label("Edit", systemImage: "pencil.circle")
//                                }
//                            } label: {
//                                Image(systemName: "ellipsis.circle")
//                            }
//                        }
                    
                    
//                }
//                    .frame(width: 300, height: 300, alignment: .center)
//                        .onTapGesture {
//                            // 텍스트를 탭하면 복사 팝업을 보이도록 토글
//                            isCopyPopupVisible.toggle()
//                            // 텍스트를 복사
//                            copiedText = "Hello, World!"
//                        }
                    // 클립보드에 텍스트 복사
//                        .onLongPressGesture {
//                            UIPasteboard.general.string = copiedText
//                        }
//                        .popover(isPresented: $isCopyPopupVisible, arrowEdge: .bottom) {
//                            // 복사 팝업
//                            VStack {
//                                Button(action: {
//                                    // 클릭하면 팝업이 사라지고 클립보드에 텍스트가 복사됨
//                                    UIPasteboard.general.string = copiedText
//                                    isCopyPopupVisible.toggle()
//                                }) {
//                                    Text("Copy")
//                                        .foregroundColor(.blue)
//                                        .padding(5)
//                                }
//                            }
//                            .padding()
//                            .background(Color.white)
//                            .cornerRadius(10)
//                            .shadow(radius: 5)
//                        }
                    /*
                     TextField
                     displayType이 .current
                      -> text가 있을 때: copy icon
                      -> text가 없을 때: icon 없음
                     
                     displayType이 .add
                     -> text가 있을 때: x icon
                     -> text가 없을 때: icon 없음
                     
                     displayType이 .edit
                     -> text가 있을 때: x icon
                     -> text가 없을 때: icon 없음
                     
                     
                     TextEditor
                     
                     */
                    if displayType == .add && !text.isEmpty {
                    Button(action: {
                        text = ""
                    }) {
//                        if displayType == .current && !text.isEmpty {
//                            Image(systemName: "doc.on.doc")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 17, height: 17)
//                                .foregroundColor(Color(uiColor: .systemBlue))
//                        } else
//                        if displayType == .add && !text.isEmpty {
                            Image(systemName: "x.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color(uiColor: .systemBlue))
//                        }
                    }
                    .padding(.trailing, 8)
                    }
                    
                case .multiLine:
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
                            .allowsHitTesting(false)
                    }
                case .longNumber:
                    TextField(placeholder, text: $text)
                        .padding()
                        .padding(.trailing, 20)
                        .disabled(displayType != .add)
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

                    Button(action: {
                        text = ""
                    }) {
//                        if displayType == .current && !text.isEmpty {
//                            Image(systemName: "doc.on.doc")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 17, height: 17)
//                                .foregroundColor(Color(uiColor: .systemBlue))
//                        } else
                        if !text.isEmpty {
                            Image(systemName: "x.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .foregroundColor(Color(uiColor: .systemBlue))
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
                                .foregroundColor(Color(uiColor: .systemBlue))
                        }
                    }
                    .padding(.trailing, 8)

                }

            }
            
            if displayType == .edit {
                Button {
                    editButtonTap = itemSubType.rawValue
                } label: {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                        .foregroundColor(Color(uiColor: .systemBlue))
                }
            }
            
        }
        .onChange(of: text) { newValue in
            userInputItem = UserInputItem(itemSubType: itemSubType, text: text)
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

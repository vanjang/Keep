//
//  DateInputView.swift
//  Keep
//
//  Created by myung hoon on 05/04/2024.
//

import SwiftUI

struct DateInputView: InputViewType, View {
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
    @State private var selectedDate: Date? = nil
    @State private var isShowingDatePicker = false
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                Text(text.isEmpty ? placeholder : text)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(getTextColor())
                    .padding()
                    .padding(.trailing, 20)
                    .background(.white)
                    .cornerRadius(16)
                    .fullScreenCover(isPresented: $isShowingDatePicker, content: {
                        DatePickerView(selectedDate: $selectedDate, isPresented: $isShowingDatePicker)
                            .background(Color(uiColor: .systemGray6))
                    })
                    .transaction({ transaction in
                        transaction.disablesAnimations = true
                    })
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
                        selectedDate = nil
                        updateText(date: selectedDate)
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .padding(4)
                            .foregroundColor(Color(uiColor: .systemBlue))
                    }
                    .padding(.trailing, 12)
                }
            }
            //TODO: blocked for disabled because navigation link and tap gesture are conflicting. Find better way.
            .if(!disabled, transform: { view in
                view
                    .onTapGesture {
                        isShowingDatePicker.toggle()
                    }

            })

                if canEdit {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundColor(Color(uiColor: .systemBlue))
            }
        }
        .onChange(of: selectedDate, perform: { newValue in
            updateText(date: newValue)
        })
        .onChange(of: refresh) { _ in
            selectedDate = nil
            updateText(date: selectedDate)
        }
        .onAppear {
            if let currentText = currentText {
                text = currentText
            }
        }
    }
    
    private func updateText(date: Date?) {
        text = date != nil ? date!.formatted(date: .long, time: .omitted) : ""
        inputText(date != nil ? date!.toISOString() : "")
    }
    
    private func getTextColor() -> Color {
        Color(uiColor: text.isEmpty ? .placeholderText : (disabled ? .darkGray : .black))
    }
}


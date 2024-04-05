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

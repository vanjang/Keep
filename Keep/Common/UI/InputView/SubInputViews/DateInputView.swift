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
    @State private var dateString: String? = nil
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                Text(dateString ?? placeholder)
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
                                UIPasteboard.general.string = dateString
                            } label: {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        } else {
                            EmptyView()
                        }
                    }
                
                if canDelete && !(dateString ?? "").isEmpty {
                    Button(action: {
                        selectedDate = nil
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
            .onTapGesture {
                isShowingDatePicker.toggle()
            }
            
            if canEdit {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                    .foregroundColor(Color(uiColor: .systemBlue))
            }
        }
        .onChange(of: selectedDate, perform: { newValue in
            dateString = selectedDate?.formatted(date: .long, time: .omitted)
            if let d = selectedDate {
                print("sss", d.toISOString())
                inputText(d.toISOString())
            }
        })
        .onChange(of: refresh) { newValue in
            dateString = nil
        }
        .onAppear {
            if let currentText = currentText {
                text = currentText
            }
        }
    }
    
    private func getTextColor() -> Color {
        if disabled {
            return Color(uiColor: .darkGray)
        } else {
            if selectedDate != nil {
                return .black
            } else {
                return Color(uiColor: .placeholderText)
            }
        }
    }
    
}


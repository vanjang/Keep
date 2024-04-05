//
//  ItemEditView.swift
//  Keep
//
//  Created by myung hoon on 22/03/2024.
//

import SwiftUI

struct ItemEditView: View {
    // MARK: - init
    let inputType: ItemInputType
    let inputField: String
    @Binding var userInputItem: UserInputItem?
    
    // MARK: - environments
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - states
    @FocusState private var focused: Bool?
    
    var body: some View {
        VStack {
            itemDetailView()
            .frame(minHeight: 50)
            .padding()
            .focused($focused, equals: true)
            .navigationBarTitle("Edit " + inputField)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        print("save button tapped")
                    }) {
                        Text("Save")
                            .foregroundColor(Color(uiColor: .systemBlue))
                            .disabled(false)
                    }
            )
            
            Spacer()
        }
        .background(Color.mainGray)
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focused = true
            }
        }
    }
    
    private func inputViewItem() -> InputViewItem {
        InputViewItem(itemSubType: .none,
                      displayType: .add,
                      placeholder: "",
                      currentText: inputField,
                      refresh: .constant(false),
                      inputText: { inputText in
            
        })
    }
    
    private func itemDetailView() -> some View {
        switch inputType {
        case .plain: return InputView.plain(inputViewItem())
        case .multiLine: return InputView.multiline(inputViewItem())
        case .longNumber: return InputView.longNumber(inputViewItem())
        case .date: return InputView.date(inputViewItem())
        }
    }
}

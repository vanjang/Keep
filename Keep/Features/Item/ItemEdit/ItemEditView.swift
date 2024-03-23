//
//  ItemEditView.swift
//  Keep
//
//  Created by myung hoon on 22/03/2024.
//

import SwiftUI

struct ItemEditView: View {
    // init
    let inputType: ItemInputType
    let inputField: String
    @Binding var userInputItem: UserInputItem?

    // environments
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    // states
    @FocusState private var focused: Bool?
    
    var body: some View {
        VStack {
            ItemInputView(itemSubType: .none, inputType: inputType, displayType: .add, editButtonTap: .constant(""), userInputItem: $userInputItem)
                .frame(minHeight: 50)
                .padding()
                .focused($focused, equals: true)
                .navigationBarBackButtonHidden()
                .navigationBarTitle("Edit " + inputField)
                .navigationBarItems(
                    leading:
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color(uiColor: .systemBlue))
                        },
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
        .manualPopBack()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.focused = true
            }
        }
    }
}

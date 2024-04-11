//
//  ItemEditView.swift
//  Keep
//
//  Created by myung hoon on 22/03/2024.
//

import SwiftUI

struct ItemEditView: View {
    // MARK: - init
    var didSave: () -> ()
    
    //MARK: - viewModel
    @StateObject private var viewModel: ItemEditViewModel
    
    //MARK: - States
    @State var showAlert = false
    
    init(item: ItemEditItem, didSave: @escaping () -> ()) {
        _viewModel = StateObject(wrappedValue: ItemEditViewModel(item: item))
        self.didSave = didSave
    }
    
    // MARK: - environments
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    // MARK: - states
    @FocusState private var focused: Bool?
    
    var body: some View {
        VStack {
            itemDetailView(viewModel.inputType)
                .frame(minHeight: 50)
                .padding()
                .focused($focused, equals: true)
                .navigationBarTitle("Edit " + viewModel.itemSubType.rawValue)
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            viewModel.saveButtonTapped.send(())
                        }) {
                            Text("Save")
                        }
                        .disabled(!viewModel.saveButtonEnabled)
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
        .onReceive(viewModel.$shouldPop) { shouldPop in
            if shouldPop {
                didSave()
                dismiss()
            }
        }
        .onReceive(viewModel.$showAlertForEmptyString, perform: { show in
            if show {
                showAlert.toggle()
            }
        })
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Can't save"), message: Text("This field is required"), dismissButton: .default(Text("Dismiss")))
        }
    }
    
    private func inputViewItem() -> InputViewItem {
        InputViewItem(itemSubType: .none,
                      displayType: .add,
                      placeholder: viewModel.placedholder,
                      currentText: viewModel.editingText,
                      refresh: .constant(false),
                      inputText: { inputText in
            viewModel.editedInputItem.send(UserInputItem(itemSubType: viewModel.itemSubType, text: inputText))
        })
    }
    
    private func itemDetailView(_ inputType: ItemInputType) -> some View {
        switch inputType {
        case .plain: return InputView.plain(inputViewItem())
        case .multiLine: return InputView.multiline(inputViewItem())
        case .longNumber: return InputView.longNumber(inputViewItem())
        case .date: return InputView.date(inputViewItem())
        }
    }
}

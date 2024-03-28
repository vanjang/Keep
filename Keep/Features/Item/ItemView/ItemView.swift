//
//  ItemView.swift
//  Keep
//
//  Created by myung hoon on 21/02/2024.
//

import SwiftUI
import Combine

struct ItemView: View {
    //MARK: - init
    let displayType: ItemDisplayType
    
    //MARK: - environment
    @Environment(\.dismiss) var dismiss
    
    //MARK: - viewModel
    @StateObject private var viewModel = ItemViewModel(logic: ItemViewModelLogic())
    
    //MARK: - states
    @State private var presentActionSheet = false
    @State private var appeared = false
    @State private var editButtonTap = ""
    @State private var pushToEdit = false
    @State private var selectedInputType: ItemInputType? = nil
    @State private var selectedInputField: String = ""
    @State private var userInputItem: UserInputItem? = nil
    @State private var refresh = false
    
    var body: some View {
        NavigationView {
            content
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(viewModel.detailItems, id: \.self) { item in
                    ItemInputView(itemSubType: item.itemSubType,
                                  inputType: item.inputType,
                                  displayType: item.displayType,
                                  placeholder: item.placeholder,
                                  refresh: $refresh,
                                  editButtonTap: $editButtonTap,
                                  userInputItem: $userInputItem)
                        .frame(minHeight: 50)
                        .onChange(of: editButtonTap) { newValue in
                            guard newValue == item.itemSubType.rawValue else { return }
                            selectedInputType = item.inputType
                            selectedInputField = item.itemSubType.rawValue
                            // to implement onChange(of:) for the same value of editButtonTap, editButtonTap should be emptied everytime it is called.
                            editButtonTap = ""
                            pushToEdit.toggle()
                        }
                }
                
                Button(viewModel.bottomButtonTitle) {
                    viewModel.bottomButtonTapped.send()
                }
                .foregroundColor(Color(uiColor: viewModel.bottomButtonColor))
                .padding()
                .disabled(!viewModel.bottomButtonEnabled)
                
                NavigationLink(destination: ItemEditView(inputType: selectedInputType ?? .plain,
                                                         inputField: selectedInputField,
                                                         userInputItem: $userInputItem),
                               isActive: $pushToEdit) {
                    EmptyView()
                }.hidden()
            }
            .buttonStyle(PlainButtonStyle())
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .adjustOffsetbyKeyboardHeight()
        }
        .scrollToDismissKeyboard(mode: .interactively)
        .animation(.easeOut(duration: 0.16), value: appeared)
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.mainGray)
        .navigationBarTitle(viewModel.title)
        .navigationBarItems(
            leading:
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(uiColor: .systemBlue))
                },
            trailing:
                HStack(content: {
                    Button(action: {
                        switch viewModel.barButtonActionType {
                        case .actionSheet: presentActionSheet.toggle()
                        case .edit: viewModel.displayType.send(.edit)
                        case .current: viewModel.displayType.send(.current)
                        }
                    }) {
                        Text(viewModel.barButtonTitle)
                            .foregroundColor(Color(uiColor: .systemBlue))
                    }
                    .actionSheet(isPresented: $presentActionSheet) {
                        let buttons = viewModel.itemTypes.map { t -> ActionSheet.Button in
                                .default(Text(t.rawValue)) {
                                    viewModel.selectedItemType.send(t)
                                }
                        } + [.cancel()]
                        
                        return ActionSheet(title: Text("Select an option"), buttons: buttons)
                    }
                    
                })
        )
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.endEditing()
                }
            }
        }
        .onAppear {
            viewModel.displayType.send(displayType)
            appeared = true
        }
        .onChange(of: userInputItem, perform: { newValue in
            guard let new = newValue else { return }
            viewModel.userInputItem.send(new)
        })
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}

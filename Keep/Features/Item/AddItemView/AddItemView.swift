//
//  AddItemView.swift
//  Keep
//
//  Created by myung hoon on 21/02/2024.
//

import SwiftUI
import Combine

struct AddItemView: View {
    //MARK: - environment
    @Environment(\.dismiss) var dismiss
    
    //MARK: - viewModel
    @StateObject private var viewModel = AddItemViewModel(logic: ItemViewModelLogic())
    
    //MARK: - states
    @State private var presentActionSheet = false
    @State private var appeared = false
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
                ForEach(viewModel.items, id: \.self) { item in
                    ItemDetailView(itemSubType: item.itemSubType,
                                   inputType: item.inputType,
                                   displayType: .add,
                                   placeholder: item.placeholder,
                                   refresh: $refresh,
                                   editButtonTap: .constant(""),
                                   userInputItem: $userInputItem)
                    .frame(minHeight: 50)
                }
                
                Button("Add") {
                    viewModel.addButtonTapped.send()
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(Color(uiColor: .systemBlue))
                .padding()
                .disabled(!viewModel.addButtonEnabled)
            }
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
                        presentActionSheet.toggle()
                    }) {
                        Text("Change")
                            .foregroundColor(Color(uiColor: .systemBlue))
                    }
                    .actionSheet(isPresented: $presentActionSheet) {
                        let buttons = viewModel.actionSheetItemTypes.map { t -> ActionSheet.Button in
                                .default(Text(t.rawValue)) {
                                    viewModel.actionSheetButtonTap.send(t)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                appeared = true
            }
        }
        // Send User's input content to VM whenever changed
        .onChange(of: userInputItem, perform: { newValue in
            guard let new = newValue else { return }
            viewModel.userInputItem.send(new)
        })
        // ActionSheet has been tapped and empty text in ItemInputView
        .onReceive(viewModel.$shouldRefresh) { _ in
            refresh.toggle()
        }
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
}

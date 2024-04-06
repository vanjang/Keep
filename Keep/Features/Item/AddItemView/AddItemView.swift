//
//  AddItemView.swift
//  Keep
//
//  Created by myung hoon on 21/02/2024.
//

import SwiftUI
import Combine

struct AddItemView: View {
    //MARK: - Init
    var notifyReload: () -> ()
    
    //MARK: - environment
    @Environment(\.dismiss) var dismiss
    
    //MARK: - viewModel
    @StateObject private var viewModel = AddItemViewModel(logic: ItemViewModelLogic())
    
    //MARK: - states
    @State private var presentActionSheet = false
    @State private var appeared = false
    @State private var inputText: String = ""
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
                    itemDetailView(item: item)
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
        .onDisappear {
            notifyReload()
        }
        .onReceive(viewModel.$shouldRefresh) { _ in
            refresh.toggle()
        }
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
    }
    
    private func getInputViewItem(item: AddItem) -> InputViewItem {
        InputViewItem(itemSubType: item.itemSubType,
                      displayType: .add,
                      placeholder: item.placeholder,
                      currentText: nil,
                      refresh: $refresh,
                      inputText: {
            viewModel.userInputItem.send(UserInputItem(itemSubType: item.itemSubType, text: $0))
        })
    }
    
    private func itemDetailView(item: AddItem) -> some View {
        switch item.inputType {
        case .plain: return InputView.plain(getInputViewItem(item: item))
        case .multiLine: return InputView.multiline(getInputViewItem(item: item))
        case .longNumber: return InputView.longNumber(getInputViewItem(item: item))
        case .date: return InputView.date(getInputViewItem(item: item))
        }
    }
}

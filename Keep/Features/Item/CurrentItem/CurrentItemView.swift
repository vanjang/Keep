//
//  CurrentItemView.swift
//  Keep
//
//  Created by myung hoon on 28/03/2024.
//

import SwiftUI
import Combine

struct CurrentItemView: View {
    //MARK: - environment
    @Environment(\.dismiss) var dismiss
    
    //MARK: - viewModel
    @StateObject private var viewModel: CurrentItemViewModel
    
    //MARK: - states
    @State private var editButtonTap = ""
    @State private var pushToEdit = false
    @State private var selectedInputType: ItemInputType? = nil
    @State private var selectedInputField: String = ""
    @State private var refresh = false
    @State private var showInfoSheet = false
    @State private var showDeleteAlert = false
    
    /// KeepItem ID
    init(id: String, itemType: ItemType) {
        _viewModel = StateObject(wrappedValue: CurrentItemViewModel(id: id, itemType: itemType, logic: ItemViewModelLogic()))
    }
    
    var body: some View {
        content
    }
    
    private var content: some View {
        ZStack(alignment: .bottom) {
            navigationView
                .padding(.bottom, viewModel.bottomOffset)
            
            if !viewModel.isInfoButtonHidden {
                Button {
                    showInfoSheet.toggle()
                } label: {
                    Image(systemName: "info.circle")
                }
                .frame(height: 50)
            }
            
            BottomSheetView(isShowing: $showInfoSheet) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(viewModel.infoItems, id: \.self) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.title)
                                    .foregroundColor(Color(uiColor: .lightGray))
                                    .font(.system(size: 12, weight: .medium))
                                Spacer()
                            }
                            
                            Text(item.content)
                                .font(.system(size: 14, weight: .medium))
                        }
                    }
                    
                    Divider()
                    
                    Button("Delete") {
                        showDeleteAlert.toggle()
                    }
                    .foregroundColor(Color(uiColor: .systemRed))
                }
                .padding(18)
                
                Spacer()
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Item"),
                    message: Text("Are you sure you want to delete this item?"),
                    primaryButton: .destructive(Text("Delete")) {
                        viewModel.deleteButtonTapped.send()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
        .background(Color(uiColor: .mainGray))
    }
    
    private var navigationView: some View {
        NavigationView {
            scrollView
                .navigationBarTitleDisplayMode(.inline)
                .navigationViewStyle(StackNavigationViewStyle())
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
                                case .edit: viewModel.displayType.send(.edit)
                                case .current: viewModel.displayType.send(.current)
                                default: break
                                }
                            }) {
                                Text(viewModel.barButtonTitle)
                                    .foregroundColor(Color(uiColor: .systemBlue))
                            }
                        })
                )
                .onAppear {
                    viewModel.displayType.send(.current)
                }
                .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
                    if shouldDismiss {
                        dismiss()
                    }
                }
        }
    }
    
    private var scrollView: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(viewModel.items, id: \.self) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.placeholder)
                            .padding(.leading, 6)
                            .foregroundColor(Color(uiColor: .lightGray))
                            .font(.system(size: 14, weight: .medium))
                        
                        ItemDetailView(itemSubType: item.itemSubType,
                                       inputType: item.inputType,
                                       displayType: item.displayType,
                                       placeholder: "",
                                       currentText: item.text,
                                       refresh: $refresh,
                                       editButtonTap: $editButtonTap,
                                       userInputItem: .constant(nil))
                        .frame(minHeight: 50)
                        .onChange(of: editButtonTap) { newValue in
                            guard newValue == item.itemSubType.rawValue else { return }
                            selectedInputType = item.inputType
                            selectedInputField = item.itemSubType.rawValue
                            // to implement onChange(of:) for the same value of editButtonTap, editButtonTap should be emptied everytime it is called.
                            editButtonTap = ""
                            viewModel.displayType.send(.edit)
                            pushToEdit.toggle()
                        }
                    }
                }
                
                NavigationLink(destination: ItemEditView(inputType: selectedInputType ?? .plain,
                                                         inputField: selectedInputField,
                                                         userInputItem: .constant(nil)),
                               isActive: $pushToEdit) {
                    EmptyView()
                }.hidden()
            }
            .buttonStyle(PlainButtonStyle())
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.mainGray)
    }
}

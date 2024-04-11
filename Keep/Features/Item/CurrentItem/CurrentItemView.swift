//
//  CurrentItemView.swift
//  Keep
//
//  Created by myung hoon on 28/03/2024.
//

import SwiftUI
import Combine

struct CurrentItemView: View {
    //MARK: - Init
    private var notifyReload: () -> ()
    
    //MARK: - environment
    @Environment(\.dismiss) var dismiss
    
    //MARK: - viewModel
    @StateObject private var viewModel: CurrentItemViewModel
    
    //MARK: - states
    @State private var refresh = false
    @State private var showInfoSheet = false
    @State private var showDeleteAlert = false
    
    /// KeepItem ID
    init(id: String, itemType: ItemType, refresh: @escaping () -> ()) {
        self.notifyReload = refresh
        _viewModel = StateObject(wrappedValue: CurrentItemViewModel(id: id, itemType: itemType))
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
        .onAppear {
            viewModel.displayType.send(.current)
        }
        .onReceive(viewModel.$shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                dismiss()
            }
        }
        .onDisappear(perform: {
            notifyReload()
        })
        .onAppear(perform: {
            viewModel.fetch.send()
        })
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
                )
        }
    }
    
    private var scrollView: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(viewModel.items, id: \.self) { item in
                    if item.displayType == .edit {
                        NavigationLink {
                            itemEditView(item: item)
                        } label: {
                            itemCellView(item: item)
                        }
                    } else {
                        itemCellView(item: item)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.mainGray)
    }
    
    private func itemEditView(item: CurrentItem) -> some View {
        ItemEditView(item: ItemEditItem(id: item.id,
                                        itemType: item.itemType,
                                        placeholder: item.placeholder,
                                        inputType: item.inputType,
                                        subType: item.itemSubType,
                                        editingText: item.text),
                     didSave: {
            viewModel.fetch.send(())
        })
    }
    
    private func itemCellView(item: CurrentItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.itemSubType.rawValue)
                .padding(.leading, 6)
                .foregroundColor(Color(uiColor: .lightGray))
                .font(.system(size: 14, weight: .medium))
            
            inputView(item: item)
                .frame(minHeight: 50)
        }
    }
    
    private func inputViewItem(item: CurrentItem) -> InputViewItem {
        InputViewItem(itemSubType: item.itemSubType,
                      displayType: item.displayType,
                      placeholder: item.placeholder,
                      currentText: item.text,
                      refresh: $refresh,
                      inputText: { _ in })
    }
    
    private func inputView(item: CurrentItem) -> some View {
        switch item.inputType {
        case .plain: return InputView.plain(inputViewItem(item: item))
        case .multiLine: return InputView.multiline(inputViewItem(item: item))
        case .longNumber: return InputView.longNumber(inputViewItem(item: item))
        case .date: return InputView.date(inputViewItem(item: item))
        }
    }
}

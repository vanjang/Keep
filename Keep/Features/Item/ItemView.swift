//
//  ItemView.swift
//  Keep
//
//  Created by myung hoon on 21/02/2024.
//

import SwiftUI
import Combine

struct ItemView: View {
    @StateObject private var viewModel: ItemAddViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @State private var presentActionSheet = false
    @State private var pushToEdit = false
    @State private var appeared = false
    @State private var offset: CGFloat = 0
    
    private let displayType: ItemDisplayType
    
    init(displayType: ItemDisplayType) {
        self.displayType = displayType
        _viewModel = StateObject(wrappedValue: ItemAddViewModel(displayType: displayType))
    }
    
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
                    ItemDetailView(placeholder: item.placeholder, inputType: item.inputType, displayType: displayType)
                        .frame(minHeight: 50)
                }
                
                Button(viewModel.buttonTitle) {
                    dismiss()
                }
            }
            .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
            .offset(y: -offset)
            .animation(.easeOut(duration: 0.16), value: offset)
            .gesture(
                DragGesture().onChanged { gesture in
                    if gesture.translation.height > 0 {
                        UIApplication.shared.endEditing()
                    }
                })
        }
        .onReceive(Publishers.keyboardHeight) { height in
            let isUp = height > 1
            let setUpOffset = {
                let keyboardTop = UIScreen.main.bounds.height - height
                let focusedTextInputBottom = (UIResponder.currentFirstResponder()?.globalFrame?.maxY ?? 0) + 45//20
                self.offset = max(0, focusedTextInputBottom - keyboardTop)
            }
            
            if isUp {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16, execute: setUpOffset)
            } else {
                setUpOffset()
            }
        }
        .animation(.easeOut(duration: 0.16), value: appeared)
        .edgesIgnoringSafeArea(.bottom)
        .background(Color.mainGray)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Spacer()
                    Text(viewModel.title)
                    Spacer()
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(uiColor: .systemBlue))
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    displayType == .add ? presentActionSheet.toggle() : pushToEdit.toggle()
                } label: {
                    Image(systemName: viewModel.barButtonTitle)
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
            }
        }
        .onAppear {
            appeared = true
        }
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(displayType: .add)
    }
}

//
//  ItemView.swift
//  Keep
//
//  Created by myung hoon on 21/02/2024.
//

import SwiftUI

struct ItemView: View {
    @Environment(\.dismiss) var dismiss
    @State private var presentActionSheet = false
    @State private var pushToEdit = false
    
    private let displayType: ItemDisplayType
    
    init(displayType: ItemDisplayType) {
        self.displayType = displayType
    }
    
    var body: some View {
        NavigationView(content: {
            ScrollView {
                VStack(spacing: 24) {
                    ItemDetailView(placeholder: "title", inputType: .textField)
                        .frame(height: 50)
                    
                    ItemDetailView(placeholder: "email", inputType: .textField)
                        .frame(height: 50)
                    
                    ItemDetailView(placeholder: "username", inputType: .textField)
                        .frame(height: 50)
                    
                    ItemDetailView(placeholder: "password", inputType: .textField)
                        .frame(height: 50)
                    
                    if displayType == .add {
                        Button("Add") {
                            dismiss()
                        }
                    }
                }
                .padding(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                .gesture(
                    DragGesture().onChanged { gesture in
                        if gesture.translation.height > 0 {
                            UIApplication.shared.endEditing()
                        }
                    })
            }
            .bounceBehaviourForScrollView(.basedOnSize, axes: [.vertical])
            .background(Color.mainGray)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Password")
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
                        Image(systemName: displayType == .add ? "arrow.left.arrow.right" : "slider.horizontal.3")
                            .foregroundColor(Color(uiColor: .systemBlue))
                    }
                    .actionSheet(isPresented: $presentActionSheet) {
                        ActionSheet(title: Text("Select an option"), buttons: [
                            .default(Text("Card")) {
                                print("Card")
                            },
                            .default(Text("Bank Account")) {
                                print("Bank Account")
                            },
                            .default(Text("etc.")) {
                                print("etc")
                            },
                            .cancel()
                        ])
                    }
                }
            }            
        })
    }
}

struct AddItemView_Previews: PreviewProvider {
    static var previews: some View {
        ItemView(displayType: .add)
    }
}


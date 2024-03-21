//
//  ItemAddViewModel.swift
//  Keep
//
//  Created by myung hoon on 13/03/2024.
//

import Foundation
import Combine

final class ItemAddViewModel: ObservableObject {
    // inputs
    let selectedItemType = CurrentValueSubject<ItemType, Never>(.password)
    
    // outputs
    @Published private(set) var title: String = ""
    @Published private(set) var itemTypes: [ItemType] = []
    @Published private(set) var buttonTitle: String = ""
    @Published private(set) var barButtonTitle: String = ""
    @Published private(set) var detailItems: [ItemDetailViewItem] = []
    
    
    private var cancellables = Set<AnyCancellable>()
    
    init(displayType: ItemDisplayType) {
        selectedItemType
            .map { $0.rawValue }
            .assign(to: \.title, on: self)
            .store(in: &cancellables)
        
        selectedItemType
            .map { type -> [ItemType] in
                [.password, .bankAccount, .card, .etc].filter { $0 != type }
            }
            .assign(to: \.itemTypes, on: self)
            .store(in: &cancellables)
        
        selectedItemType
            .map { type -> [ItemDetailViewItem] in
                let titleItem = [ItemDetailViewItem(placeholder: "Title", inputType: .textField)]
                var additionalItems: [ItemDetailViewItem] = []
                
                switch type {
                case .password:
                    additionalItems = [
                        ItemDetailViewItem(placeholder: "Email", inputType: .textField),
                        ItemDetailViewItem(placeholder: "Username", inputType: .textField),
                        ItemDetailViewItem(placeholder: "Password", inputType: .textField),
                        ItemDetailViewItem(placeholder: "Memo", inputType: .textEditor)
                    ]
                case .bankAccount:
                    additionalItems = [
                        ItemDetailViewItem(placeholder: "Sort Code", inputType: .textField),
                        ItemDetailViewItem(placeholder: "Account Number", inputType: .textField),
                        ItemDetailViewItem(placeholder: "Memo", inputType: .textEditor)
                    ]
                case .card:
                    additionalItems = [
                        ItemDetailViewItem(placeholder: "Card Long Number", inputType: .cardNumber),
                        ItemDetailViewItem(placeholder: "Start from", inputType: .date),
                        ItemDetailViewItem(placeholder: "Expire by", inputType: .date),
                        ItemDetailViewItem(placeholder: "Security Code", inputType: .textField),
                        ItemDetailViewItem(placeholder: "Memo", inputType: .textEditor)
                    ]
                case .etc:
                    additionalItems = [
                        ItemDetailViewItem(placeholder: "Memo", inputType: .textEditor)
                    ]
                }
                
                return titleItem + additionalItems
            }
            .assign(to: \.detailItems, on: self)
            .store(in: &cancellables)
        
        Just(displayType)
            .map { type -> String in
                type == .add ? "Add" : "Save"
            }
            .assign(to: \.buttonTitle, on: self)
            .store(in: &cancellables)
        
        Just(displayType)
            .map { type -> String in
                type == .add ? "arrow.left.arrow.right" : "square.and.pencil"
            }
            .assign(to: \.barButtonTitle, on: self)
            .store(in: &cancellables)
        
    }
    
    
}

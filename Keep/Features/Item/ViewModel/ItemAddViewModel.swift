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
    let displayType = PassthroughSubject<ItemDisplayType, Never>()
    let selectedItemType = CurrentValueSubject<ItemType, Never>(.password)
    
    // outputs
    @Published private(set) var title: String = ""
    @Published private(set) var itemTypes: [ItemType] = []
    @Published private(set) var buttonTitle: String = ""
    @Published private(set) var barButtonTitle: String = ""
    @Published private(set) var detailItems: [ItemInputItem] = []
    @Published private(set) var barButtonActionType: ItemBarButtonActionType = .current
    
    //
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
        
        Publishers.CombineLatest(selectedItemType, displayType)
            .map { type, displayType -> [ItemInputItem] in
                let titleItem = [ItemInputItem(placeholder: "Title", inputType: .textField, displayType: displayType)]
                var additionalItems: [ItemInputItem] = []
                
                switch type {
                case .password:
                    additionalItems = [
                        ItemInputItem(placeholder: "Email", inputType: .textField, displayType: displayType),
                        ItemInputItem(placeholder: "Username", inputType: .textField, displayType: displayType),
                        ItemInputItem(placeholder: "Password", inputType: .textField, displayType: displayType),
                        ItemInputItem(placeholder: "Memo", inputType: .textEditor, displayType: displayType)
                    ]
                case .bankAccount:
                    additionalItems = [
                        ItemInputItem(placeholder: "Sort Code", inputType: .textField, displayType: displayType),
                        ItemInputItem(placeholder: "Account Number", inputType: .textField, displayType: displayType),
                        ItemInputItem(placeholder: "Memo", inputType: .textEditor, displayType: displayType)
                    ]
                case .card:
                    additionalItems = [
                        ItemInputItem(placeholder: "Card Long Number", inputType: .cardNumber, displayType: displayType),
                        ItemInputItem(placeholder: "Start from", inputType: .date, displayType: displayType),
                        ItemInputItem(placeholder: "Expire by", inputType: .date, displayType: displayType),
                        ItemInputItem(placeholder: "Security Code", inputType: .textField, displayType: displayType),
                        ItemInputItem(placeholder: "Memo", inputType: .textEditor, displayType: displayType)
                    ]
                case .etc:
                    additionalItems = [
                        ItemInputItem(placeholder: "Memo", inputType: .textEditor, displayType: displayType)
                    ]
                }
                
                return titleItem + additionalItems
            }
            .assign(to: \.detailItems, on: self)
            .store(in: &cancellables)
        
        displayType
            .map { type -> ItemBarButtonActionType in
                switch type {
                case .add: return .actionSheet
                case .current: return .edit
                case .edit: return .current
                }
            }
            .assign(to: \.barButtonActionType, on: self)
            .store(in: &cancellables)
        
        displayType
            .map { type -> String in
                switch type {
                case .add: return "Add"
                case .current: return ""
                case .edit: return ""
                }
            }
            .assign(to: \.buttonTitle, on: self)
            .store(in: &cancellables)
        
        displayType
            .map { type -> String in
                switch type {
                case .add: return "Change"
                case .current: return "Edit"
                case .edit: return "Cancel"
                }
            }
            .assign(to: \.barButtonTitle, on: self)
            .store(in: &cancellables)
    }
    
}

enum ItemBarButtonActionType {
    case actionSheet, edit, current
}

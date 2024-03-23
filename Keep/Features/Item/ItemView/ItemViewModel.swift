//
//  ItemViewModel.swift
//  Keep
//
//  Created by myung hoon on 13/03/2024.
//

import Foundation
import Combine

final class ItemViewModel: ObservableObject {
    // inputs
    let displayType = PassthroughSubject<ItemDisplayType, Never>()
    let selectedItemType = CurrentValueSubject<ItemType, Never>(.password)
    let userInputItem = PassthroughSubject<UserInputItem, Never>()
    
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
                switch type {
                case .password:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .email, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .username, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .password, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType)]
                case .bankAccount:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .sortCode, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .accountNumber, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType)]
                case .card:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .longNumber, inputType: .longNumber, displayType: displayType),
                            ItemInputItem(itemSubType: .startFrom, inputType: .date, displayType: displayType),
                            ItemInputItem(itemSubType: .expireBy, inputType: .date, displayType: displayType),
                            ItemInputItem(itemSubType: .securityCode, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType)]
                case .etc:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType)]
                }
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

        Publishers.CombineLatest(userInputItem, selectedItemType)
            .scan(([UserInputItem](), ItemType.password)) { last, current in
                let currentItem = current.0
                let currentType = current.1
                
                let lastItems = last.0
                let lastType = last.1
                
                if currentType == lastType {
                    return (lastItems.filter { $0.itemSubType != currentItem.itemSubType } + [currentItem], currentType)
                } else {
                    return ([], currentType)
                }
            }
            .sink { items in
                print(items)
            }
            .store(in: &cancellables)
        
    }
    
}

enum ItemBarButtonActionType {
    case actionSheet, edit, current
}

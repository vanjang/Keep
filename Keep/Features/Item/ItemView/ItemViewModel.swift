//
//  ItemViewModel.swift
//  Keep
//
//  Created by myung hoon on 13/03/2024.
//

import Foundation
import Combine
// refactor 할 거 있나요?
final class ItemViewModel: ObservableObject {
    // inputs
    let displayType = PassthroughSubject<ItemDisplayType, Never>()
    let selectedItemType = CurrentValueSubject<ItemType, Never>(.password)
    let userInputItem = PassthroughSubject<UserInputItem, Never>()
    
    // outputs
    @Published private(set) var title = ""
    @Published private(set) var itemTypes: [ItemType] = []
    @Published private(set) var buttonTitle = ""
    @Published private(set) var barButtonTitle = ""
    @Published private(set) var detailItems: [ItemInputItem] = []
    @Published private(set) var barButtonActionType: ItemBarButtonActionType = .current
    @Published private(set) var canSave = false
    
    //
    private var cancellables = Set<AnyCancellable>()
    private let keychainService: KeychainService<UserInputItem, Serializer<UserInputItem>>
    
    init(keychainService: KeychainService<UserInputItem, Serializer<UserInputItem>> = KeychainService(serializer: Serializer<UserInputItem>())) {
        self.keychainService = keychainService
        
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
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .email, inputType: .plain, displayType: displayType, placeholder: ItemSubType.email.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .username, inputType: .plain, displayType: displayType, placeholder: ItemSubType.username.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .password, inputType: .plain, displayType: displayType, placeholder: ItemSubType.password.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
                case .bankAccount:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .sortCode, inputType: .plain, displayType: displayType, placeholder: ItemSubType.sortCode.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .accountNumber, inputType: .plain, displayType: displayType, placeholder: ItemSubType.accountNumber.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
                case .card:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .longNumber, inputType: .longNumber, displayType: displayType, placeholder: ItemSubType.longNumber.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .startFrom, inputType: .date, displayType: displayType, placeholder: ItemSubType.startFrom.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .expireBy, inputType: .date, displayType: displayType, placeholder: ItemSubType.expireBy.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .securityCode, inputType: .plain, displayType: displayType, placeholder: ItemSubType.securityCode.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
                case .etc:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue, isOptional: false)]
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

        let currentUserInputItems = Publishers.CombineLatest(userInputItem, selectedItemType)
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
            .eraseToAnyPublisher()
            .share()
        
        currentUserInputItems
            .map { (inputItems, inputType) -> Bool in
                switch inputType {
                case .password:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .password }
                case .bankAccount:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .accountNumber }
                case .card:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .longNumber }
                case .etc:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .memo }
                }
            }
            .assign(to: \.canSave, on: self)
            .store(in: &cancellables)
        
        
    }
    
}

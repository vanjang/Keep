//
//  ItemViewModelLogic.swift
//  Keep
//
//  Created by myung hoon on 27/03/2024.
//

import UIKit

struct ItemViewModelLogic {
    func getItemTypes(itemType: ItemType) -> [ItemType] {
        [.password, .bankAccount, .card, .etc].filter { $0 != itemType }
    }
    
    func getBottomButtonColor(displayType: ItemDisplayType) -> UIColor {
        displayType == .current ? .systemRed : .systemBlue
    }

    func getItemInputItems(type: ItemType, displayType: ItemDisplayType) -> [ItemInputItem] {
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
    
    func getButtonActionType(displayType: ItemDisplayType) -> ItemBarButtonActionType {
        switch displayType {
        case .add: return .actionSheet
        case .current: return .edit
        case .edit: return .current
        }
    }
    
    func getBottomButtonTitle(displayType: ItemDisplayType) -> String {
        switch displayType {
        case .add: return "Add"
        case .current: return "Delete"
        case .edit: return ""
        }
    }
    
    func getBarButtonTitle(displayType: ItemDisplayType) -> String {
        switch displayType {
        case .add: return "Change"
        case .current: return "Edit"
        case .edit: return "Cancel"
        }
    }
    
    func getCurrentUserInputItems(last: ([UserInputItem], ItemType), current: (UserInputItem, ItemType)) -> ([UserInputItem], ItemType) {
        let currentItem = current.0
        let currentType = current.1
        
        var lastItems = last.0
        let lastType = last.1
        
        if currentType == lastType {
            if currentItem.text.isEmpty, let index = lastItems.firstIndex(where: { $0.itemSubType == currentItem.itemSubType }) {
                lastItems.remove(at: index)
                return (lastItems, currentType)
            } else {
                return (lastItems.filter { $0.itemSubType != currentItem.itemSubType } + [currentItem], currentType)
            }
        } else {
            return ([], currentType)
        }
    }
    
    func getBottomButtonEnabledForAdd(inputItems: [UserInputItem], itemType: ItemType) -> Bool {
        switch itemType {
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
    
    func createCurrentKeepItem(items: ([UserInputItem], ItemType)) -> KeepItem {
        switch items.1 {
        case .password: return self.createPassword(from: items.0)
        case .bankAccount: return self.createBankAccount(from: items.0)
        case .card: return self.createCard(from: items.0)
        case .etc: return self.createEtc(from: items.0)
        }
    }
    
    func createPassword(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let email = inputItems.first { $0.itemSubType == .email }?.text
        let username = inputItems.first { $0.itemSubType == .username }?.text
        let password = inputItems.first { $0.itemSubType == .password }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .password(Password(id: Helpers.randomString(), title: title, email: email, username: username, password: password, memo: memo, dateCreated: "", dateModified: nil))
    }
    
    func createBankAccount(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let sortCode = inputItems.first { $0.itemSubType == .sortCode }?.text
        let accountNumber = inputItems.first { $0.itemSubType == .accountNumber }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .bankAccount(BankAccount(id: Helpers.randomString(), title: title, sortCode: sortCode, accountNumber: accountNumber, memo: memo, dateCreated: "", dateModified: nil))
    }
    
    func createCard(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let longNumber = inputItems.first { $0.itemSubType == .longNumber }?.text ?? ""
        let dateStartingFrom = inputItems.first { $0.itemSubType == .startFrom }?.text
        let dateEndingBy = inputItems.first { $0.itemSubType == .expireBy }?.text
        let securityCode = inputItems.first { $0.itemSubType == .securityCode }?.text
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .card(Card(id: Helpers.randomString(), title: title, longNumber: longNumber, dateStartingFrom: dateStartingFrom, dateEndingBy: dateEndingBy, securityCode: securityCode, memo: memo, dateCreated: "", dateModified: nil))
    }
    
    private func createEtc(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text ?? ""
        return .etc(Etc(id: Helpers.randomString(), title: title, memo: memo, dateCreated: "", dateModified: nil))
    }
    
}


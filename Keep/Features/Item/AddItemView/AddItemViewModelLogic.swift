//
//  AddItemViewModelLogic.swift
//  Keep
//
//  Created by myung hoon on 11/04/2024.
//

import Foundation

struct AddItemViewModelLogic {
    func getItemTypes(itemType: ItemType) -> [ItemType] {
        [.password, .bankAccount, .card, .etc].filter { $0 != itemType }
    }
    
    func getItemInputItems(type: ItemType) -> [AddItem] {
        switch type {
        case .password:
            return [AddItem(itemSubType: .title, inputType: .plain, placeholder: ItemSubType.title.rawValue, isOptional: false),
                    AddItem(itemSubType: .password, inputType: .plain, placeholder: ItemSubType.password.rawValue, isOptional: false),
                    AddItem(itemSubType: .email, inputType: .plain, placeholder: ItemSubType.email.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .username, inputType: .plain, placeholder: ItemSubType.username.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .memo, inputType: .multiLine, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
        case .bankAccount:
            return [AddItem(itemSubType: .title, inputType: .plain, placeholder: ItemSubType.title.rawValue, isOptional: false),
                    AddItem(itemSubType: .accountNumber, inputType: .plain, placeholder: ItemSubType.accountNumber.rawValue, isOptional: false),
                    AddItem(itemSubType: .sortCode, inputType: .plain, placeholder: ItemSubType.sortCode.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .memo, inputType: .multiLine, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
        case .card:
            return [AddItem(itemSubType: .title, inputType: .plain, placeholder: ItemSubType.title.rawValue, isOptional: false),
                    AddItem(itemSubType: .longNumber, inputType: .longNumber, placeholder: ItemSubType.longNumber.rawValue, isOptional: false),
                    AddItem(itemSubType: .startFrom, inputType: .date, placeholder: ItemSubType.startFrom.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .expireBy, inputType: .date, placeholder: ItemSubType.expireBy.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .securityCode, inputType: .plain, placeholder: ItemSubType.securityCode.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .memo, inputType: .multiLine, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
        case .etc:
            return [AddItem(itemSubType: .title, inputType: .plain, placeholder: ItemSubType.title.rawValue, isOptional: false),
                    AddItem(itemSubType: .memo, inputType: .multiLine, placeholder: ItemSubType.memo.rawValue, isOptional: false)]
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
        return .password(Password(id: Helpers.randomString(), title: title, email: email, username: username, password: password, memo: memo, dateCreated: Date(), dateModified: nil))
    }
    
    func createBankAccount(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let sortCode = inputItems.first { $0.itemSubType == .sortCode }?.text
        let accountNumber = inputItems.first { $0.itemSubType == .accountNumber }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .bankAccount(BankAccount(id: Helpers.randomString(), title: title, sortCode: sortCode, accountNumber: accountNumber, memo: memo, dateCreated: Date(), dateModified: nil))
    }
    
    func createCard(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let longNumber = inputItems.first { $0.itemSubType == .longNumber }?.text ?? ""
        let dateStartingFrom = inputItems.first { $0.itemSubType == .startFrom }?.text
        let dateEndingBy = inputItems.first { $0.itemSubType == .expireBy }?.text
        let securityCode = inputItems.first { $0.itemSubType == .securityCode }?.text
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .card(Card(id: Helpers.randomString(), title: title, longNumber: longNumber, dateStartingFrom: dateStartingFrom, dateEndingBy: dateEndingBy, securityCode: securityCode, memo: memo, dateCreated: Date(), dateModified: nil))
    }
    
    private func createEtc(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text ?? ""
        return .etc(Etc(id: Helpers.randomString(), title: title, memo: memo, dateCreated: Date(), dateModified: nil))
    }
}

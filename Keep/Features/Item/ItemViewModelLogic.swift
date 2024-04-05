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
    
    func getBottomOffset(displayType: ItemDisplayType) -> CGFloat {
        isInfoButonHidden(displayType: displayType) ? 0 : 50
    }
    
    func isInfoButonHidden(displayType: ItemDisplayType) -> Bool {
        displayType != .current
    }
    
    func getKeepItem(from keepItems: [KeepItem], keepItemId: String) -> KeepItem? {
        guard let keepItem = keepItems.first(where: { keepItem in
            keepItem.id == keepItemId
        }) else {
            return nil
        }
        return keepItem
    }
    
    func getCurrentInfoItem(from keepItems: [KeepItem], keepItemId: String) -> [CurrentInfoItem] {
        guard let keepItem = getKeepItem(from: keepItems, keepItemId: keepItemId) else { return [] }
        let dateCreated = CurrentInfoItem(title: "Created Date", content: DateFormatter.getDiplayTimeString(date: keepItem.dateCreated, preferredFormat: .dateAndTime))
        var infoItems: [CurrentInfoItem] = [dateCreated]
        
        if let dateModified = keepItem.dateModified {
            let dateModified = CurrentInfoItem(title: "Modified Date", content: DateFormatter.getDiplayTimeString(date: dateModified))
            infoItems.append(dateModified)
        }
        return infoItems
    }
    
    func getCurrentItems(from keepItems: [KeepItem], keepItemId: String, displayType: ItemDisplayType) -> [CurrentItem] {
        guard let keepItem = getKeepItem(from: keepItems, keepItemId: keepItemId) else { return [] }
        switch keepItem {
        case .password(let password): return getPasswordCurrentItems(from: password, displayType: displayType)
        case .card(let card): return getCardCurrentItems(from: card, displayType: displayType)
        case .bankAccount(let bankAccount): return getBankAccountCurrentItems(from: bankAccount, displayType: displayType)
        case .etc(let etc): return getEtcCurrentItems(from: etc, displayType: displayType)
        }
    }
    
    func getPasswordCurrentItems(from password: Password, displayType: ItemDisplayType) -> [CurrentItem] {
        let id = password.id
        let title = password.title
        let email = password.email
        let username = password.username
        let pw = password.password
        let memo = password.memo
        
        return [CurrentItem(id: id, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
                CurrentItem(id: id, itemSubType: .email, inputType: .plain, displayType: displayType, text: email, placeholder: ItemSubType.email.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemSubType: .username, inputType: .plain, displayType: displayType, text: username, placeholder: ItemSubType.username.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemSubType: .password, inputType: .plain, displayType: displayType, text: pw, placeholder: ItemSubType.password.rawValue, isOptional: false),
                CurrentItem(id: id, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)].filter { displayType == .edit ? true : $0.text != nil }
        
    }
    
    private func getCardCurrentItems(from card: Card, displayType: ItemDisplayType) -> [CurrentItem] {
        let id = card.id
        let title = card.title
        let longNumber = card.longNumber
        let dateStartingFrom = DateFormatter.getDiplayTimeString(date: card.dateStartingFrom?.toDate() ?? Date(), preferredFormat: .dateMonthAndYear)
        let dateEndingBy = DateFormatter.getDiplayTimeString(date: card.dateEndingBy?.toDate() ?? Date(), preferredFormat: .dateMonthAndYear)
        let securityCode = card.securityCode
        let memo = card.memo
        
        return [CurrentItem(id: id, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
                CurrentItem(id: id, itemSubType: .longNumber, inputType: .longNumber, displayType: displayType, text: longNumber, placeholder: ItemSubType.longNumber.rawValue, isOptional: false),
                CurrentItem(id: id, itemSubType: .startFrom, inputType: .plain, displayType: displayType, text: dateStartingFrom, placeholder: ItemSubType.startFrom.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemSubType: .expireBy, inputType: .plain, displayType: displayType, text: dateEndingBy, placeholder: ItemSubType.expireBy.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemSubType: .securityCode, inputType: .plain, displayType: displayType, text: securityCode, placeholder: ItemSubType.securityCode.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)].filter { displayType == .edit ? true : $0.text != nil }
    }
    
    private func getBankAccountCurrentItems(from bankAccount: BankAccount, displayType: ItemDisplayType) -> [CurrentItem] {
        let id = bankAccount.id
        let title = bankAccount.title
        let sortCode = bankAccount.sortCode
        let accountNumber = bankAccount.accountNumber
        let memo = bankAccount.memo
        
        return [CurrentItem(id: id, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
            CurrentItem(id: id, itemSubType: .accountNumber, inputType: .plain, displayType: displayType, text: accountNumber, placeholder: ItemSubType.accountNumber.rawValue, isOptional: false),
            CurrentItem(id: id, itemSubType: .sortCode, inputType: .plain, displayType: displayType, text: sortCode, placeholder: ItemSubType.sortCode.rawValue + "(optional)", isOptional: true),
            CurrentItem(id: id, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)].filter { displayType == .edit ? true : $0.text != nil }
    }
    
    private func getEtcCurrentItems(from etc: Etc, displayType: ItemDisplayType) -> [CurrentItem] {
        let id = etc.id
        let title = etc.title
        let memo = etc.memo
        
        return [CurrentItem(id: id, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
            CurrentItem(id: id, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue, isOptional: false)]
    }

    func getItemInputItems(type: ItemType) -> [AddItem] {
        switch type {
        case .password:
            return [AddItem(itemSubType: .title, inputType: .plain, placeholder: ItemSubType.title.rawValue, isOptional: false),
                    AddItem(itemSubType: .email, inputType: .plain, placeholder: ItemSubType.email.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .username, inputType: .plain, placeholder: ItemSubType.username.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .password, inputType: .plain, placeholder: ItemSubType.password.rawValue, isOptional: false),
                    AddItem(itemSubType: .memo, inputType: .multiLine, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
        case .bankAccount:
            return [AddItem(itemSubType: .title, inputType: .plain, placeholder: ItemSubType.title.rawValue, isOptional: false),
                    AddItem(itemSubType: .sortCode, inputType: .plain, placeholder: ItemSubType.sortCode.rawValue + "(optional)", isOptional: true),
                    AddItem(itemSubType: .accountNumber, inputType: .plain, placeholder: ItemSubType.accountNumber.rawValue, isOptional: false),
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
    
    func getButtonActionType(displayType: ItemDisplayType) -> ItemBarButtonActionType {
        switch displayType {
        case .add: return .actionSheet
        case .current: return .edit
        case .edit: return .current
        }
    }
    
    func getCurrentItemViewBarButtonTitle(displayType: ItemDisplayType) -> String {
        switch displayType {
        case .current: return "Edit"
        case .edit: return "Cancel"
        default: return ""
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


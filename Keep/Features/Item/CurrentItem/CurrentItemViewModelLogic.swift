//
//  CurrentItemViewModelLogic.swift
//  Keep
//
//  Created by myung hoon on 11/04/2024.
//

import Foundation

struct CurrentItemViewModelLogic {
    func getKeepItem(from keepItems: [KeepItem], keepItemId: String) -> KeepItem? {
        guard let keepItem = keepItems.first(where: { keepItem in
            keepItem.id == keepItemId
        }) else {
            return nil
        }
        return keepItem
    }
    
    func getBottomOffset(displayType: ItemDisplayType) -> CGFloat {
        isInfoButonHidden(displayType: displayType) ? 0 : 50
    }
    
    func isInfoButonHidden(displayType: ItemDisplayType) -> Bool {
        displayType != .current
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
        
        return [CurrentItem(id: id, itemType: .password, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
                CurrentItem(id: id, itemType: .password, itemSubType: .password, inputType: .plain, displayType: displayType, text: pw, placeholder: ItemSubType.password.rawValue, isOptional: false),
                CurrentItem(id: id, itemType: .password, itemSubType: .email, inputType: .plain, displayType: displayType, text: email, placeholder: ItemSubType.email.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemType: .password, itemSubType: .username, inputType: .plain, displayType: displayType, text: username, placeholder: ItemSubType.username.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemType: .password, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)].filter { displayType == .edit ? true : $0.text != nil }
        
    }
    
    private func getCardCurrentItems(from card: Card, displayType: ItemDisplayType) -> [CurrentItem] {
        let id = card.id
        let title = card.title
        let longNumber = card.longNumber
        
        var dateStartingFrom: String?
        var dateEndingBy: String?
        
        if let startingDate = card.dateStartingFrom?.toDate() {
            dateStartingFrom = DateFormatter.getDiplayTimeString(date: startingDate, preferredFormat: .dateMonthAndYear)
        }
        
        if let endingDate = card.dateEndingBy?.toDate() {
            dateEndingBy = DateFormatter.getDiplayTimeString(date: endingDate, preferredFormat: .dateMonthAndYear)
        }
        
        let securityCode = card.securityCode
        let memo = card.memo
        
        return [CurrentItem(id: id, itemType: .card, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
                CurrentItem(id: id, itemType: .card, itemSubType: .longNumber, inputType: .longNumber, displayType: displayType, text: longNumber, placeholder: ItemSubType.longNumber.rawValue, isOptional: false),
                CurrentItem(id: id, itemType: .card, itemSubType: .startFrom, inputType: .date, displayType: displayType, text: dateStartingFrom, placeholder: ItemSubType.startFrom.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemType: .card, itemSubType: .expireBy, inputType: .date, displayType: displayType, text: dateEndingBy, placeholder: ItemSubType.expireBy.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemType: .card, itemSubType: .securityCode, inputType: .plain, displayType: displayType, text: securityCode, placeholder: ItemSubType.securityCode.rawValue + "(optional)", isOptional: true),
                CurrentItem(id: id, itemType: .card, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)].filter { displayType == .edit ? true : $0.text != nil }
    }
    
    private func getBankAccountCurrentItems(from bankAccount: BankAccount, displayType: ItemDisplayType) -> [CurrentItem] {
        let id = bankAccount.id
        let title = bankAccount.title
        let sortCode = bankAccount.sortCode
        let accountNumber = bankAccount.accountNumber
        let memo = bankAccount.memo
        
        return [CurrentItem(id: id, itemType: .bankAccount, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
            CurrentItem(id: id, itemType: .bankAccount, itemSubType: .accountNumber, inputType: .plain, displayType: displayType, text: accountNumber, placeholder: ItemSubType.accountNumber.rawValue, isOptional: false),
            CurrentItem(id: id, itemType: .bankAccount, itemSubType: .sortCode, inputType: .plain, displayType: displayType, text: sortCode, placeholder: ItemSubType.sortCode.rawValue + "(optional)", isOptional: true),
            CurrentItem(id: id, itemType: .bankAccount, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)].filter { displayType == .edit ? true : $0.text != nil }
    }
    
    private func getEtcCurrentItems(from etc: Etc, displayType: ItemDisplayType) -> [CurrentItem] {
        let id = etc.id
        let title = etc.title
        let memo = etc.memo
        
        return [CurrentItem(id: id, itemType: .etc, itemSubType: .title, inputType: .plain, displayType: displayType, text: title, placeholder: ItemSubType.title.rawValue, isOptional: false),
            CurrentItem(id: id, itemType: .etc, itemSubType: .memo, inputType: .multiLine, displayType: displayType, text: memo, placeholder: ItemSubType.memo.rawValue, isOptional: false)]
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
        case .edit: return "Done"
        default: return ""
        }
    }
    
    func removeKeepItem(for id: String, keepItems: [KeepItem]) -> [KeepItem] {
        if let index = keepItems.firstIndex(where: { $0.id == id }) {
            var items = keepItems
            items.remove(at: index)
            return items
        }
        return keepItems
    }
}

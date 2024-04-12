//
//  ItemEditViewModelLogic.swift
//  Keep
//
//  Created by myung hoon on 11/04/2024.
//

import Foundation

struct ItemEditViewModelLogic {
    /// - Parameters:
    ///   - item: A KeepItem to replace.
    ///   - items: A current KeepItems
    /// - Returns: A KeepItems that replaced with item.
    func replaceKeepItem(item: KeepItem, current items: [KeepItem]) -> [KeepItem] {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updatedItems = items
            updatedItems[index] = item
            return updatedItems
        }
        return items
    }

    func hasEditingTextChanged(editedText: String, editingText: String) -> Bool {
        // user can leave it empty(depends on subInputType though) therefore not checking emptiness.
        editedText != editingText
    }
    func checkCanSave(shouldNotLeaveEmpty: Bool, editedText: String) -> Bool {
        // If required field, check isEmpty. If optional field, can leave it empty so return true.
        shouldNotLeaveEmpty ? !editedText.isEmpty : true
    }
    
    func switchCurrentKeepItem(id: String, inputItem: UserInputItem, itemType: ItemType, current keepItems: [KeepItem]) -> [KeepItem] {
        guard let editingKeepItem = keepItems.first(where: { $0.id == id }) else { return keepItems }
        var editedKeepItem: KeepItem
        
        switch editingKeepItem {
        case .password(let pw):
            var title = pw.title
            var memo = pw.memo
            var email = pw.email
            var username = pw.username
            var password = pw.password
            
            switch inputItem.itemSubType {
            case .title:
                title = inputItem.text
            case .memo:
                memo = inputItem.text.isEmpty ? nil : inputItem.text
            case .email:
                email = inputItem.text.isEmpty ? nil : inputItem.text
            case .username:
                username = inputItem.text.isEmpty ? nil : inputItem.text
            case .password:
                password = inputItem.text
            default: break
            }
            
            editedKeepItem = KeepItem.password(Password(id: id, title: title, email: email, username: username, password: password, memo: memo, dateCreated: pw.dateCreated, dateModified: Date()))
        case .card(let card):
            var title = card.title
            var memo = card.memo
            var longNumber = card.longNumber
            var dateStartingFrom = card.dateStartingFrom
            var dateEndingBy = card.dateEndingBy
            var securityCode = card.securityCode
            
            switch inputItem.itemSubType {
            case .title:
                title = inputItem.text
            case .memo:
                memo = inputItem.text.isEmpty ? nil : inputItem.text
            case .longNumber:
                longNumber = inputItem.text
            case .startFrom:
                dateStartingFrom = inputItem.text.isEmpty ? nil : inputItem.text
            case .expireBy:
                dateEndingBy = inputItem.text.isEmpty ? nil : inputItem.text
            case .securityCode:
                securityCode = inputItem.text.isEmpty ? nil : inputItem.text
            default: break
            }
            
            editedKeepItem = KeepItem.card(Card(id: id, title: title, longNumber: longNumber, dateStartingFrom: dateStartingFrom, dateEndingBy: dateEndingBy, securityCode: securityCode, memo: memo, dateCreated: card.dateCreated, dateModified: Date()))
        case .bankAccount(let ba):
            var title = ba.title
            var memo = ba.memo
            var sortCode = ba.sortCode
            var accountNumber = ba.accountNumber
            
            switch inputItem.itemSubType {
            case .title:
                title = inputItem.text
            case .memo:
                memo = inputItem.text.isEmpty ? nil : inputItem.text
            case .sortCode:
                sortCode = inputItem.text.isEmpty ? nil : inputItem.text
            case .accountNumber:
                accountNumber = inputItem.text
            default: break
            }
            editedKeepItem = KeepItem.bankAccount(BankAccount(id: id, title: title, sortCode: sortCode, accountNumber: accountNumber, memo: memo, dateCreated: ba.dateCreated, dateModified: Date()))
        case .etc(let etc):
            var title = etc.title
            var memo = etc.memo
            
            switch inputItem.itemSubType {
            case .title:
                title = inputItem.text
            case .memo:
                memo = inputItem.text
            default: break
            }
            editedKeepItem = KeepItem.etc(Etc(id: id, title: title, memo: memo, dateCreated: etc.dateCreated, dateModified: Date()))
        }
        return replaceKeepItem(item: editedKeepItem, current: keepItems)
    }
}

//
//  MainListViewModelLogic.swift
//  Keep
//
//  Created by myung hoon on 11/04/2024.
//

import Foundation

struct MainListViewModelLogic {
    func search(from keepItems: [KeepItem], searchText: String) -> [KeepItem] {
        if searchText.isEmpty {
            return keepItems
        } else {
            return keepItems
                .filter { item in
                    switch item {
                    case .password(let password):
                        return password.title.contains(searchText)
                    case .card(let card):
                        return card.title.contains(searchText)
                    case .bankAccount(let bankAccount):
                        return bankAccount.title.contains(searchText)
                    case .etc(let etc):
                        return etc.title.contains(searchText)
                    }
                }
        }
    }
    
    func getMainLilstItems(from keepItems: [KeepItem], searchText: String) -> [MainListItem] {
        search(from: keepItems, searchText: searchText)
            .map { keepItem -> MainListItem in
                switch keepItem {
                case .password(let pw):
                    return MainListItem(id: pw.id, title: pw.title, itemType: .password)
                case .card(let card):
                    return MainListItem(id: card.id, title: card.title, itemType: .card)
                case .bankAccount(let account):
                    return MainListItem(id: account.id, title: account.title, itemType: .bankAccount)
                case .etc(let etc):
                    return MainListItem(id: etc.id, title: etc.title, itemType: .etc)
                }
            }
    }
}

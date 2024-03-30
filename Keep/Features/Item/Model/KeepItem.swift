//
//  KeepItem.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Foundation

//https://stackoverflow.com/questions/50205373/make-a-protocol-codable-and-store-it-in-an-array
enum KeepItem: Codable {
    case password(Password)
    case card(Card)
    case bankAccount(BankAccount)
    case etc(Etc)
    
    var id: String {
        switch self {
        case .password(let password): return password.id
        case .card(let card): return card.id
        case .bankAccount(let bankAccount): return bankAccount.id
        case .etc(let etc): return etc.id
        }
    }
    
    var dateCreated: Date {
        switch self {
        case .password(let password): return password.dateCreated
        case .card(let card): return card.dateCreated
        case .bankAccount(let bankAccount): return bankAccount.dateCreated
        case .etc(let etc): return etc.dateCreated
        }
    }
    
    var dateModified: Date? {
        switch self {
        case .password(let password): return password.dateModified
        case .card(let card): return card.dateModified
        case .bankAccount(let bankAccount): return bankAccount.dateModified
        case .etc(let etc): return etc.dateModified
        }
    }
}

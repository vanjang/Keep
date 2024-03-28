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
}

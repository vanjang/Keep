//
//  BankAccount.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Foundation

struct BankAccount: Codable {
    let id: String
    let title: String
    let sortCode: String?
    let accountNumber: String
    let memo: String?
    let dateCreated: Date
    let dateModified: Date?
}

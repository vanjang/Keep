//
//  Password.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Foundation

struct Password: Codable {
    let id: String
    let title: String
    let email: String?
    let username: String?
    let password: String
    let memo: String?
    let dateCreated: String
    let dateModified: String?
}

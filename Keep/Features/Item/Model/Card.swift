//
//  Card.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Foundation

struct Card: Codable {
    let id: String
    let title: String
    let longNumber: String
    let dateStartingFrom: String?
    let dateEndingBy: String?
    let securityCode: String?
    let memo: String?
    let dateCreated: Date
    let dateModified: Date?
}

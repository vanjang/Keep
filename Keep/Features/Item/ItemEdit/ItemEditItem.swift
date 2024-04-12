//
//  ItemEditItem.swift
//  Keep
//
//  Created by myung hoon on 10/04/2024.
//

import Foundation

struct ItemEditItem {
    let id: String
    let itemType: ItemType
    let placeholder: String
    let inputType: ItemInputType
    let subType: ItemSubType
    let editingText: String?
    
    var shouldNotLeaveEmpty: Bool {
        switch itemType {
        case .password:
            return subType == .title || subType == .password
        case .bankAccount:
            return subType == .title || subType == .accountNumber
        case .card:
            return subType == .title || subType == .longNumber
        case .etc:
            return subType == .title || subType == .memo
        }
    }
}

//
//  AddItem.swift
//  Keep
//
//  Created by myung hoon on 14/03/2024.
//

import Foundation

struct AddItem: Hashable {
    let itemSubType: ItemSubType
    let inputType: ItemInputType
    let placeholder: String
    let isOptional: Bool
}

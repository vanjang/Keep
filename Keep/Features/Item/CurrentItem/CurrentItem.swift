//
//  CurrentItem.swift
//  Keep
//
//  Created by myung hoon on 28/03/2024.
//

import Foundation

struct CurrentItem: Hashable {
    let id: String
    let itemSubType: ItemSubType
    let inputType: ItemInputType
    let displayType: ItemDisplayType
    let text: String?
    let placeholder: String
    let isOptional: Bool
}

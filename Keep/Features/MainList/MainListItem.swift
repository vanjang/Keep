//
//  MainListItem.swift
//  Keep
//
//  Created by myung hoon on 23/03/2024.
//

import Foundation

struct MainListItem: Identifiable, Hashable {
    let id: String
    let title: String
    let itemType: ItemType
}

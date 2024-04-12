//
//  InputViewItem.swift
//  Keep
//
//  Created by myung hoon on 05/04/2024.
//

import SwiftUI

struct InputViewItem {
    let itemSubType: ItemSubType
    let displayType: ItemDisplayType
    let placeholder: String
    let currentText: String?
    var refresh: Binding<Bool>
    var inputText: (String) -> Void
}

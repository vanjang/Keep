//
//  InputViewType.swift
//  Keep
//
//  Created by myung hoon on 05/04/2024.
//

import SwiftUI

protocol InputViewType where Self: View {
    var text: String { get }
    var placeholder: String { get }
    var canEdit: Bool { get }
    var disabled: Bool { get }
    var canDelete: Bool { get }
    var canPresentMenu: Bool { get }
    var refresh: Bool { get }
    var inputText: (String) -> Void { get }
}

//
//  InputView.swift
//  Keep
//
//  Created by myung hoon on 05/04/2024.
//

import SwiftUI

enum InputView: View {
    case plain(InputViewItem)
    case multiline(InputViewItem)
    case longNumber(InputViewItem)
    case date(InputViewItem)
    
    var body: some View {
        switch self {
        case .plain(let i):
            PlainInputView(placeholder: i.placeholder,
                           currentText: i.currentText,
                           canEdit: i.displayType == .edit,
                           disabled: i.displayType != .add,
                           canDelete: i.displayType == .add,
                           canPresentMenu: i.displayType == .current,
                           refresh: i.refresh,
                           inputText: i.inputText)
        case .multiline(let i):
            MultilineInputView(placeholder: i.placeholder,
                               currentText: i.currentText,
                               canEdit: i.displayType == .edit,
                               disabled: i.displayType != .add,
                               canDelete: i.displayType == .add,
                               canPresentMenu: i.displayType == .current,
                               refresh: i.refresh,
                               inputText: i.inputText)
        case .longNumber(let i):
            LondNumberInputView(placeholder: i.placeholder,
                                currentText: i.currentText,
                                canEdit: i.displayType == .edit,
                                disabled: i.displayType != .add,
                                canDelete: i.displayType == .add,
                                canPresentMenu: i.displayType == .current,
                                refresh: i.refresh,
                                inputText: i.inputText)
        case .date(let i):
            DateInputView(placeholder: i.placeholder,
                          currentText: i.currentText,
                          canEdit: i.displayType == .edit,
                          disabled: i.displayType != .add,
                          canDelete: i.displayType == .add,
                          canPresentMenu: i.displayType == .current,
                          refresh: i.refresh,
                          inputText: i.inputText)
        }
    }
}

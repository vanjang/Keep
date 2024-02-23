//
//  View_Extension.swift
//  Keep
//
//  Created by myung hoon on 23/02/2024.
//

import SwiftUI

extension View {
    func listBackgroundColor() -> some View {
        modifier(ListBackgroundModifier())
    }
}

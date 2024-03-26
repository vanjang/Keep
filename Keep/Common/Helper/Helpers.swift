//
//  Helpers.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Foundation

enum Helpers {
    static func randomString(length: Int = 6, isNumber: Bool = false) -> String {
        let letters = isNumber ? "0123456789" : "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

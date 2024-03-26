//
//  KeychainError.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Foundation

enum KeychainError: Error {
    case duplicatedItem
    case unexpectedError
    case noItem
    case generalError(Error)
}

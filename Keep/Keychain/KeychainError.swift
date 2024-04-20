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
    
    var description: String {
        switch self {
        case .duplicatedItem: return "Attempted to save a duplicated item."
        case .unexpectedError: return "Unexpected error has occurred."
        case .noItem: return "No item."
        case .generalError(let error): return error.localizedDescription
        }
    }
}

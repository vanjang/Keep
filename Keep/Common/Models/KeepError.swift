//
//  KeepError.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Foundation

enum KeepError: Error {
    case unexpectedError
    case unknown
    case generalError(Error)
    case none
    case keychainError(KeychainError)
    
    var description: String {
        switch self {
        case .unexpectedError: return "Unexpected error has occurred."
        case .unknown, .none: return "Unknown error has occurred."
        case .generalError(let error): return error.localizedDescription
        case .keychainError(let keychainError): return keychainError.description
        }
    }
}

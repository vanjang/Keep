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
}

//
//  SerializeType.swift
//  Keep
//
//  Created by myung hoon on 24/03/2024.
//

import Foundation

protocol SerializeType {
    associatedtype UserData
    
    func encodeData(object: UserData) throws -> Data
    func decodeData(data: Data) throws -> UserData
}

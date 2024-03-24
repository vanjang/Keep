//
//  Serializer.swift
//  Keep
//
//  Created by myung hoon on 24/03/2024.
//

import Foundation

struct Serializer<UserData: Codable>: SerializeType {
    func getData(object: UserData) throws -> Data {
        try JSONEncoder().encode(object)
    }
}

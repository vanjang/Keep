//
//  Serializer.swift
//  Keep
//
//  Created by myung hoon on 24/03/2024.
//

import Foundation

struct Serializer<UserData: Codable>: SerializeType {
    func decodeData(data: Data) throws -> UserData {
        try JSONDecoder().decode(UserData.self, from: data)
    }
    
    func encodeData(object: UserData) throws -> Data {
        try JSONEncoder().encode(object)
    }
}

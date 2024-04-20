//
//  KeychainServiceType.swift
//  Keep
//
//  Created by myung hoon on 27/03/2024.
//

import Combine

protocol KeychainServiceType {
    associatedtype UserData
    
    func createBaseQueryDictionary(forKey key: String) -> [String: Any?]
    func save(data: UserData, forKey key: String) -> AnyPublisher<Void, KeychainError>
    func loadData(forKey key: String) -> AnyPublisher<UserData, KeychainError>
    func update(_ data: UserData, forKey key: String) -> AnyPublisher<Void, KeychainError>
    func delete(forKey key: String) -> AnyPublisher<Void, KeychainError>
}


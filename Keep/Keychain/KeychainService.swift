//
//  KeychainService.swift
//  Keep
//
//  Created by myung hoon on 24/03/2024.
//

import Foundation
import Combine

struct KeychainService<Serializer: SerializeType>: KeychainServiceType {
    typealias UserData = Serializer.UserData
    
    let serializer: Serializer
    
    private var serviceName: String {
        Bundle.main.bundleIdentifier ?? "KeychainStore"
    }
    
    func createBaseQueryDictionary(forKey key: String) -> [String: Any?] {
        let encodedKey = key.data(using: .utf8)
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.serviceName,
            kSecAttrGeneric as String: encodedKey,
            kSecAttrAccount as String: encodedKey,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
    }
    
    func save(data: UserData, forKey key: String) -> AnyPublisher<Void, KeychainError> {
        return Future<Void, KeychainError> { promise in
            do {
                let d = try serializer.encodeData(object: data)
                var query = self.createBaseQueryDictionary(forKey: key)
                query[kSecValueData as String] = d as CFData
                
                var result: CFTypeRef?
                let status: OSStatus = SecItemAdd(query as CFDictionary, &result)
                
                if status == errSecSuccess {
                    promise(.success(()))
                } else if status == errSecDuplicateItem {
                    promise(.failure(KeychainError.duplicatedItem))
                } else if let error = result?.error, let _error = error {
                    promise(.failure(.generalError(_error)))
                } else {
                    promise(.failure(KeychainError.unexpectedError))
                }
            } catch {
                promise(.failure(.generalError(error)))
            }
        }.eraseToAnyPublisher()
    }
    
    func loadData(forKey key: String) -> AnyPublisher<Serializer.UserData, KeychainError> {
        return Future<UserData, KeychainError> { promise in
            var query = self.createBaseQueryDictionary(forKey: key)
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnData as String] = kCFBooleanTrue
            
            var result: CFTypeRef?
            let _: OSStatus = SecItemCopyMatching(query as CFDictionary, &result)
            
            do {
                guard let data = result as? Data else {
                    promise(.failure(KeychainError.noItem))
                    return }
                let userData = try serializer.decodeData(data: data)
                promise(.success(userData))
            } catch {
                promise(.failure(.generalError(error)))
            }
        }.eraseToAnyPublisher()
    }
    
    func update(_ data: UserData, forKey key: String) -> AnyPublisher<Void, KeychainError> {
        return Future<Void, KeychainError> { promise in
            do {
                let d = try serializer.encodeData(object: data)
                let query = self.createBaseQueryDictionary(forKey: key) as CFDictionary
                let updateDictionary = [kSecValueData as String: d] as CFDictionary
                
                let status: OSStatus = SecItemUpdate(query, updateDictionary)
                
                if status == errSecSuccess {
                    promise(.success(()))
                } else {
                    promise(.failure(KeychainError.unexpectedError))
                }
                
            } catch {
                promise(.failure(.generalError(error)))
            }
        }.eraseToAnyPublisher()
    }
    
    func delete(forKey key: String) -> AnyPublisher<Void, KeychainError> {
        return Future<Void, KeychainError> { promise in
            let query = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: self.serviceName
            ] as [String : Any] as CFDictionary
            
            let status: OSStatus = SecItemDelete(query)
            
            if status == errSecSuccess {
                promise(.success(()))
            } else {
                promise(.failure(KeychainError.unexpectedError))
            }
        }.eraseToAnyPublisher()
    }
}

//
//  KeychainService.swift
//  Keep
//
//  Created by myung hoon on 24/03/2024.
//

import Foundation

struct KeychainService<UserData: Codable, Serializer: SerializeType> {
    let serializer: Serializer
    
    var serviceName: String {
        Bundle.main.bundleIdentifier ?? "KeychainStore"
    }
    
    enum KeychainError: Error {
        case duplicatedItem
        case unexpectedError
    }
    
    func createBaseQueryDicionary(forKey key: String) -> [String: Any?] {
        let encodedKey = key.data(using: .utf8)
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.serviceName,
            kSecAttrGeneric as String: encodedKey,
            kSecAttrAccount as String: encodedKey,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
    }
    
    func save(data: Serializer.UserData, forKey key: String, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let d = try serializer.getData(object: data)
            var query = self.createBaseQueryDicionary(forKey: key)
            query[kSecValueData as String] = d as CFData
            
            var result: CFTypeRef?
            let status: OSStatus = SecItemAdd(query as CFDictionary, &result)
            
            if status == errSecSuccess {
                completion(.success(()))
            } else if status == errSecDuplicateItem {
                self.update(d, forKey: key, completion: completion)
            } else if let error = result?.error, let _error = error {
                completion(.failure(_error))
            } else {
                completion(.failure(KeychainError.unexpectedError))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func update(_ data: Data, forKey key: String, completion: @escaping (Result<Void,Error>) -> Void) {
        let query = self.createBaseQueryDicionary(forKey: key) as CFDictionary
        let updateDictionary = [kSecValueData as String: data] as CFDictionary
        
        let status: OSStatus = SecItemUpdate(query, updateDictionary)
        
        completion(status == errSecSuccess ? .success(()) : .failure(KeychainError.unexpectedError))
    }
    
    func deleteCache(forKey key: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.serviceName
        ] as [String : Any] as CFDictionary
        
        let status: OSStatus = SecItemDelete(query)
        
        completion(status == errSecSuccess ? .success(()) : .failure(KeychainError.unexpectedError))
    }
}

//
//  KeychainContainableViewModel.swift
//  Keep
//
//  Created by myung hoon on 27/03/2024.
//

import Combine

class KeychainContainableViewModel: ObservableObject, KeychainContainable {
    let keychainService: KeychainService<Serializer<[KeepItem]>>
    
    init(keychainService: any KeychainServiceType = KeychainService(serializer: Serializer<[KeepItem]>())) {
        self.keychainService = keychainService as! KeychainService<Serializer<[KeepItem]>>
    }
}

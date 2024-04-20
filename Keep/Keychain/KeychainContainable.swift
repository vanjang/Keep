//
//  KeychainContainable.swift
//  Keep
//
//  Created by myung hoon on 26/03/2024.
//

import Combine

protocol KeychainContainable {
    var keychainService: KeychainService<Serializer<[KeepItem]>> { get }
}

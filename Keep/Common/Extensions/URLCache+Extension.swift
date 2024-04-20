//
//  URLCache+Extension.swift
//  Keep
//
//  Created by myung hoon on 12/04/2024.
//

import Foundation

extension URLCache {
    static func configSharedCache(memory: Int, disk: Int) {
        let cache = URLCache(memoryCapacity: memory, diskCapacity: disk, diskPath: "apodApiCache")
        URLCache.shared = cache
    }
}

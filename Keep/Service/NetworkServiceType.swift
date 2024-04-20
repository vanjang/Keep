//
//  NetworkServiceType.swift
//  Keep
//
//  Created by myung hoon on 12/04/2024.
//

import Foundation
import Combine

/// Protocol defining the requirements for a network service.
protocol NetworkServiceType {
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error>
}

class TestClass {
    
}

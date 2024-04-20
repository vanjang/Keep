//
//  NetworkService.swift
//  Keep
//
//  Created by myung hoon on 12/04/2024.
//

import Foundation
import Combine

/// Network layer that caches URL responses automatically for better performance and UX.
struct NetworkService: NetworkServiceType {
    private let session: URLSession
    
    init(session: URLSession = URLSession(configuration: URLSessionConfiguration.default)) {
        self.session = session
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) -> AnyPublisher<T, Error> {
        guard let url = URL(string: "\(endpoint.baseURL)\(endpoint.path)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = endpoint.parameters
        
        guard let requestURL = components?.url else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = endpoint.method.rawValue
        
        if let headers = endpoint.headers {
            headers.forEach { (key, value) in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // get cachedData if available
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let cachedData = try? JSONDecoder().decode(T.self, from: cachedResponse.data) {
            return Just(cachedData)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
       return session.dataTaskPublisher(for: request)
            .cache(using: URLCache.shared, for: request, with: T.self)
            .eraseToAnyPublisher()
    }
}


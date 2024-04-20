//
//  Publishers.swift
//  Keep
//
//  Created by myung hoon on 20/03/2024.
//

import UIKit
import Combine

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect }
            .map { $0.height }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

extension Publisher {
    func filter<O>(if trigger: O) -> AnyPublisher<Output, Failure> where O: Publisher, O.Output == Bool, Self.Failure == O.Failure {
        self.combineLatest(trigger)
            .filter { $0.1 }
            .map { $0.0 }
            .eraseToAnyPublisher()
    }}

extension Publisher {
    static func empty() -> AnyPublisher<Output, Failure> {
        return Empty<Output, Failure>().eraseToAnyPublisher()
    }
}

//https://stackoverflow.com/a/65884335/10648994
extension Publisher {
    func withLatestFrom<P>(
        _ other: P
    ) -> AnyPublisher<(Self.Output, P.Output), Failure> where P: Publisher, Self.Failure == P.Failure {
        let other = other
        // Note: Do not use `.map(Optional.some)` and `.prepend(nil)`.
        // There is a bug in iOS versions prior 14.5 in `.combineLatest`. If P.Output itself is Optional.
        // In this case prepended `Optional.some(nil)` will become just `nil` after `combineLatest`.
            .map { (value: $0, ()) }
            .prepend((value: nil, ()))
        
        return map { (value: $0, token: UUID()) }
            .combineLatest(other)
            .removeDuplicates(by: { (old, new) in
                let lhs = old.0, rhs = new.0
                return lhs.token == rhs.token
            })
            .map { ($0.value, $1.value) }
            .compactMap { (left, right) in
                right.map { (left, $0) }
            }
            .eraseToAnyPublisher()
    }
}

//https://forums.swift.org/t/does-assign-to-produce-memory-leaks/29546/9
extension Publisher where Self.Failure == Never {
    public func assignNoRetain<Root>(to keyPath: ReferenceWritableKeyPath<Root, Self.Output>, on object: Root) -> AnyCancellable where Root: AnyObject {
        sink { [weak object] (value) in
            object?[keyPath: keyPath] = value
        }
    }
}

extension Publisher where Output == (data: Data, response: URLResponse), Failure == URLError {
    func cache<T: Decodable>(using cache: URLCache, for request: URLRequest, with type: T.Type, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        return map { (data, response) in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let cachedResponse = CachedURLResponse(response: httpResponse, data: data)
                cache.storeCachedResponse(cachedResponse, for: request)
            }
            return data
        }
        .decode(type: T.self, decoder: decoder)
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func flatMapLatest<T: Publisher>(_ transform: @escaping (Self.Output) -> T) -> Publishers.SwitchToLatest<T, Publishers.Map<Self, T>> where T.Failure == Self.Failure {
        map(transform).switchToLatest()
    }
    
    static func just(_ output: Output) -> AnyPublisher<Output, Failure> {
        return Just(output)
            .catch { _ in AnyPublisher<Output, Failure>.empty() }
            .eraseToAnyPublisher()
    }

    static func fail(_ error: Failure) -> AnyPublisher<Output, Failure> {
        return Fail(error: error).eraseToAnyPublisher()
    }
}

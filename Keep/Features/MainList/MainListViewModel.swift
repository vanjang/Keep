//
//  MainListViewModel.swift
//  Keep
//
//  Created by myung hoon on 29/02/2024.
//

import Combine

final class MainListViewModel: KeychainContainableViewModel {
    
    @Published private(set) var items: [MainListItem] = []
    @Published private(set) var error: KeepError = .none
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(keychainService: any KeychainServiceType = KeychainService(serializer: Serializer<[KeepItem]>())) {
        super.init(keychainService: keychainService)
        setupBindings()
    }
    
    private func setupBindings() {
        bindItems()
    }
       
    private var savedItems: AnyPublisher<[KeepItem], Never> {
        keychainService.loadData(forKey: keepKey)
            .catch { [weak self] error -> AnyPublisher<[KeepItem], Never> in
                switch error {
                case .unexpectedError: self?.error = .unexpectedError
                case .noItem: return Just([]).eraseToAnyPublisher()
                case .generalError(let e): self?.error = .generalError(e)
                default: break
                }
                return .empty()
            }
            .eraseToAnyPublisher()
    }
    
    private func bindItems() {
        savedItems
            .map {
                $0.map { keepItem -> MainListItem in
                    switch keepItem {
                    case .password(let pw):
                        return MainListItem(title: pw.title)
                    case .card(let card):
                        return MainListItem(title: card.title)
                    case .bankAccount(let account):
                        return MainListItem(title: account.title)
                    case .etc(let etc):
                        return MainListItem(title: etc.title)
                    }
                }
            }
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
}

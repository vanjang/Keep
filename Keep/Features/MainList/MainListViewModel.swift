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
                        return MainListItem(id: pw.id, title: pw.title, itemType: .password)
                    case .card(let card):
                        return MainListItem(id: card.id, title: card.title, itemType: .card)
                    case .bankAccount(let account):
                        return MainListItem(id: account.id, title: account.title, itemType: .bankAccount)
                    case .etc(let etc):
                        return MainListItem(id: etc.id, title: etc.title, itemType: .etc)
                    }
                }
            }
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
}

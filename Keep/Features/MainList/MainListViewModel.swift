//
//  MainListViewModel.swift
//  Keep
//
//  Created by myung hoon on 29/02/2024.
//

import Combine

final class MainListViewModel: KeychainContainableViewModel {
    //MARK: - Input
    let fetch = PassthroughSubject<Void, Never>()
    let searchText = CurrentValueSubject<String, Never>("")
    
    //MARK: - Output
    @Published private(set) var items: [MainListItem] = []
    @Published private(set) var error: KeepError = .none
    
    private var cancellables = Set<AnyCancellable>()
    private let logic: MainListViewModelLogic
    
    init(keychainService: any KeychainServiceType = KeychainService(serializer: Serializer<[KeepItem]>()),
         logic: MainListViewModelLogic = MainListViewModelLogic()) {
        self.logic = logic
        super.init(keychainService: keychainService)
        setupBindings()
    }
    
    private func setupBindings() {
        bindItems()
    }
       
    private var savedKeepItems: AnyPublisher<[KeepItem], Never> {
        fetch
            .flatMap { [unowned self] _ -> AnyPublisher<[KeepItem], KeychainError> in
                self.keychainService.loadData(forKey: keepKey)
            }
            .map { $0.sorted { ($0.dateModified ?? $0.dateCreated) > ($1.dateModified ?? $1.dateCreated) } }
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
        Publishers.CombineLatest(savedKeepItems, searchText)
            .map(logic.getMainLilstItems)
            .assign(to: \.items, on: self)
            .store(in: &cancellables)
    }
}

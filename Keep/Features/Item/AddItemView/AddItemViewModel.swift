//
//  AddItemViewModel.swift
//  Keep
//
//  Created by myung hoon on 13/03/2024.
//

import Combine

final class AddItemViewModel: KeychainContainableViewModel {
    //MARK: - inputs
    let actionSheetButtonTap = CurrentValueSubject<ItemType, Never>(.password)
    let userInputItem = PassthroughSubject<UserInputItem, Never>()
    let addButtonTapped = PassthroughSubject<Void, Never>()
    
    //MARK: - outputs
    @Published private(set) var title = ""
    @Published private(set) var actionSheetItemTypes: [ItemType] = []
    @Published private(set) var items: [AddItem] = []
    @Published private(set) var addButtonEnabled = false
    @Published private(set) var shouldDismiss = false
    @Published private(set) var shouldRefresh = false
    @Published private(set) var error: KeepError = .none
    
    //MARK: - Injection
    private let logic: ItemViewModelLogic
    
    //MARK: -
    private var cancellables = Set<AnyCancellable>()

    init(keychainService: any KeychainServiceType = KeychainService(serializer: Serializer<[KeepItem]>()), logic: ItemViewModelLogic) {
        self.logic = logic
        super.init(keychainService: keychainService)
        setupBindings()
    }
    
    //MARK: - Binders
    private func setupBindings() {
        bindTitle()
        bindActionSheetItemTypes()
        bindInputItems()
        bindShouldRefresh()
        bindAddButtonEnabled()
        bindSaveKeepItem()
        bindUpdate()
    }
    
    /// Binding navigation bar tile
    private func bindTitle() {
        actionSheetButtonTap
            .map { $0.rawValue }
            .assignNoRetain(to: \.title, on: self)
            .store(in: &cancellables)
    }
    
    /// Binding ActionSheet item types to appear when action sheet button is tapped.
    private func bindActionSheetItemTypes() {
        actionSheetButtonTap
            .map(logic.getItemTypes)
            .assignNoRetain(to: \.actionSheetItemTypes, on: self)
            .store(in: &cancellables)
    }
    
    /// Binding input items reacting the current ItemType
    private func bindInputItems() {
        actionSheetButtonTap
            .map(logic.getItemInputItems)
            .assignNoRetain(to: \.items, on: self)
            .store(in: &cancellables)
    }
    
    /// Binding reloading when action sheet button is tapped.
    private func bindShouldRefresh() {
        actionSheetButtonTap
            .map { _ in true }
            .assignNoRetain(to: \.shouldRefresh, on: self)
            .store(in: &cancellables)
    }
    
    /// Accumulated current input items. To be reset when action sheet button is tapped.
    private var currentUserInputItems: AnyPublisher<([UserInputItem], ItemType), Never> {
        Publishers.CombineLatest(userInputItem, actionSheetButtonTap)
            .scan(([UserInputItem](), ItemType.password)) { [unowned self] last, current in self.logic.getCurrentUserInputItems(last: last, current: current) }
            .eraseToAnyPublisher()
    }
    
    /// Binding current input items for bottom button enabled.
    private func bindAddButtonEnabled() {
        currentUserInputItems
            .map(logic.getBottomButtonEnabledForAdd)
            .assignNoRetain(to: \.addButtonEnabled, on: self)
            .store(in: &cancellables)
    }
    
    /// Current KeepItems
    private var currentKeepItems: AnyPublisher<[KeepItem], Never> {
        currentUserInputItems
            .map(logic.createCurrentKeepItem)
            .withLatestFrom(savedKeepItems)
            .map { [$0] + $1 }
            .eraseToAnyPublisher()
    }

    // MARK: - Keychain operations
    /// Currently saved KeepItems in Keychain
    private var savedKeepItems: AnyPublisher<[KeepItem], Never> {
        keychainService.loadData(forKey: keepKey)
            .catch { [weak self] error -> AnyPublisher<[KeepItem], Never> in
                switch error {
                case .noItem: return Just([]).eraseToAnyPublisher()
                default: self?.error = .keychainError(error)
                }
                return .empty()
            }
            .eraseToAnyPublisher()
    }
    
    /// Binding add button tap to save  user data in Keychain.
    private func bindSaveKeepItem() {
        addButtonTapped
            .withLatestFrom(currentKeepItems)
            .flatMap { [unowned self] items in
                self.keychainService.save(data: items.1, forKey: keepKey)
            }
            .catch { [weak self] error -> AnyPublisher<Void, Never> in
                switch error {
                case .duplicatedItem: self?.shouldUpdate.send(())
                default: self?.error = .keychainError(error)
                }
                return .empty()
            }
            .map { _ in true }
            .assignNoRetain(to: \.shouldDismiss, on: self)
            .store(in: &cancellables)
    }
    
    /// A subject to be emitted upon getting error of dupliate items.
    private let shouldUpdate = PassthroughSubject<Void, Never>()
    
    /// Binding update subject to update.
    private func bindUpdate() {
        shouldUpdate
            .withLatestFrom(currentKeepItems)
            .flatMap { [unowned self] items in
                self.keychainService.update(items.1, forKey: keepKey)
            }
            .catch { [weak self] error -> AnyPublisher<Void, Never> in
                self?.error = .keychainError(error)
                return .empty()
            }
            .map { _ in true }
            .assignNoRetain(to: \.shouldDismiss, on: self)
            .store(in: &cancellables)
    }
    
    deinit {
        print("AddItemViewModel deinit")
    }
}

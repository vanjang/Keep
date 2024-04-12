//
//  CurrentItemViewModel.swift
//  Keep
//
//  Created by myung hoon on 28/03/2024.
//

import Foundation
import Combine

final class CurrentItemViewModel: KeychainContainableViewModel {
    //MARK: - inputs
    let displayType = PassthroughSubject<ItemDisplayType, Never>()
    let deleteButtonTapped = PassthroughSubject<Void, Never>()
    let fetch = PassthroughSubject<Void, Never>()
    
    //MARK: - outputs
    @Published private(set) var title = ""
    @Published private(set) var barButtonTitle = ""
    @Published private(set) var items: [CurrentItem] = []
    @Published private(set) var infoItems: [CurrentInfoItem] = []
    @Published private(set) var barButtonActionType: ItemBarButtonActionType = .current
    @Published private(set) var shouldDismiss = false
    @Published private(set) var isInfoButtonHidden = false
    @Published private(set) var bottomOffset: CGFloat = 0
    @Published private(set) var error: KeepError = .none
    @Published var toEditView = false
    
    //MARK: - Injection
    private let logic: CurrentItemViewModelLogic
    private let id: String
    private let itemType: ItemType
    
    //MARK: -
    private var cancellables = Set<AnyCancellable>()

    init(id: String,
         itemType: ItemType,
         keychainService: any KeychainServiceType = KeychainService(serializer: Serializer<[KeepItem]>()),
         logic: CurrentItemViewModelLogic = CurrentItemViewModelLogic()) {
        self.id = id
        self.itemType = itemType
        self.logic = logic
        super.init(keychainService: keychainService)
        setupBindings()
    }
    
    //MARK: - Binders
    private func setupBindings() {
        bindTitle()
        bindCurrentItems()
        bindBarButtonActionType()
        bindBarButtonTitle()
        bindDeleteItem()
        bindCurrentInfoItem()
        bindIsInfoButtonHidden()
        bindBottomOffset()
    }
    
    private func bindTitle() {
        Just(itemType)
            .map { $0.rawValue }
            .assignNoRetain(to: \.title, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBottomOffset() {
        displayType
            .map { [unowned self] displayType in self.logic.getBottomOffset(displayType: displayType) }
            .assignNoRetain(to: \.bottomOffset, on: self)
            .store(in: &cancellables)
    }
    
    private func bindIsInfoButtonHidden() {
        displayType
            .map { [unowned self] displayType in self.logic.isInfoButonHidden(displayType: displayType) }
            .assignNoRetain(to: \.isInfoButtonHidden, on: self)
            .store(in: &cancellables)
    }
    
    private func bindCurrentInfoItem() {
        savedKeepItems
            .map { [unowned self] keepItems in
                self.logic.getCurrentInfoItem(from: keepItems, keepItemId: self.id)
            }
            .assignNoRetain(to: \.infoItems, on: self)
            .store(in: &cancellables)
    }
    
    private func bindCurrentItems() {
        Publishers.CombineLatest(savedKeepItems, displayType)
            .map { [unowned self] keepItems, displayType in
                self.logic.getCurrentItems(from: keepItems, keepItemId: self.id, displayType: displayType)
            }
            .assignNoRetain(to: \.items, on: self)
            .store(in: &cancellables)
    }
    
    private var currentKeepItem: AnyPublisher<KeepItem, Never> {
        savedKeepItems
            .map { [unowned self] items in (items, self.id)}
            .compactMap(logic.getKeepItem)
            .eraseToAnyPublisher()
    }
    
    private func bindBarButtonActionType() {
        displayType
            .map(logic.getButtonActionType)
            .assignNoRetain(to: \.barButtonActionType, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBarButtonTitle() {
        displayType
            .map(logic.getCurrentItemViewBarButtonTitle)
            .assignNoRetain(to: \.barButtonTitle, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Keychain operations
    private var savedKeepItems: AnyPublisher<[KeepItem], Never> {
        fetch
            .flatMap { [unowned self] _ -> AnyPublisher<[KeepItem], KeychainError> in
                self.keychainService.loadData(forKey: keepKey)
            }
            .catch { [weak self] error -> AnyPublisher<[KeepItem], Never> in
                switch error {
                case .noItem: return Just([]).eraseToAnyPublisher()
                default: self?.error = .keychainError(error)
                }
                return .empty()
            }
            .eraseToAnyPublisher()
    }
    
    private func bindDeleteItem() {
        deleteButtonTapped
            .withLatestFrom(savedKeepItems)
            .map { [unowned self] e in (self.id, e.1)}
            .map(logic.removeKeepItem)
            .flatMap { [unowned self] items in
                self.keychainService.update(items, forKey: keepKey)
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
        print("CurrentItemViewModel deinit")
    }
}

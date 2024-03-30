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
    let userInputItem = PassthroughSubject<UserInputItem, Never>()
    let deleteButtonTapped = PassthroughSubject<Void, Never>()
    
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
    
    //MARK: - Injection
    private let logic: ItemViewModelLogic
    private let id: String
    private let itemType: ItemType
    
    //MARK: -
    private var cancellables = Set<AnyCancellable>()

    init(id: String,
         itemType: ItemType,
         keychainService: any KeychainServiceType = KeychainService(serializer: Serializer<[KeepItem]>()),
         logic: ItemViewModelLogic) {
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
        savedItems
            .map { [unowned self] keepItems in
                self.logic.getCurrentInfoItem(from: keepItems, keepItemId: self.id)
            }
            .assignNoRetain(to: \.infoItems, on: self)
            .store(in: &cancellables)
    }
    
    private func bindCurrentItems() {
        Publishers.CombineLatest(savedItems, displayType)
            .map { [unowned self] keepItems, displayType in
                self.logic.getCurrentItems(from: keepItems, keepItemId: self.id, displayType: displayType)
            }
            .assignNoRetain(to: \.items, on: self)
            .store(in: &cancellables)
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
    private var savedItems: AnyPublisher<[KeepItem], Never> {
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
    
    private func bindDeleteItem() {
        deleteButtonTapped
            .filter(if: displayType.map { $0 == .current })
            .sink { items in
                print("삭제")
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("CurrentItemViewModel deinit")
    }
}

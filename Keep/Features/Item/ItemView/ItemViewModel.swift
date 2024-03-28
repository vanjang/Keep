//
//  ItemViewModel.swift
//  Keep
//
//  Created by myung hoon on 13/03/2024.
//

import Foundation
import Combine
import UIKit

final class ItemViewModel: KeychainContainableViewModel {
    //MARK: - inputs
    let displayType = PassthroughSubject<ItemDisplayType, Never>()
    let selectedItemType = CurrentValueSubject<ItemType, Never>(.password)
    let userInputItem = PassthroughSubject<UserInputItem, Never>()
    let bottomButtonTapped = PassthroughSubject<Void, Never>()
    
    //MARK: - outputs
    @Published private(set) var title = ""
    @Published private(set) var itemTypes: [ItemType] = []
    @Published private(set) var bottomButtonTitle = ""
    @Published private(set) var barButtonTitle = ""
    @Published private(set) var detailItems: [ItemInputItem] = []
    @Published private(set) var barButtonActionType: ItemBarButtonActionType = .current
    @Published private(set) var bottomButtonEnabled = false
    @Published private(set) var shouldDismiss = false
    @Published private(set) var error: KeepError = .none
    @Published private(set) var bottomButtonColor: UIColor = .systemRed
    
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
        bindItemTypes()
        bindBottomButtonColor()
        bindInputItems()
        bindBarButtonActionType()
        bindBottomButtonTitle()
        bindBarButtonTitle()
        bindBottomButtonEnabled()
        bindSaveItem()
        bindDeleteItem()
        bindUpdate()
    }
    
    private func bindTitle() {
        selectedItemType
            .map { $0.rawValue }
            .assignNoRetain(to: \.title, on: self)
            .store(in: &cancellables)
    }
    
    private func bindItemTypes() {
        selectedItemType
            .map(logic.getItemTypes)
            .assignNoRetain(to: \.itemTypes, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBottomButtonColor() {
        displayType
            .map(logic.getBottomButtonColor)
            .assignNoRetain(to: \.bottomButtonColor, on: self)
            .store(in: &cancellables)
    }
    
    private func bindInputItems() {
        Publishers.CombineLatest(selectedItemType, displayType)
            .map(logic.getItemInputItems)
            .assignNoRetain(to: \.detailItems, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBarButtonActionType() {
        displayType
            .map(logic.getButtonActionType)
            .assignNoRetain(to: \.barButtonActionType, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBottomButtonTitle() {
        displayType
            .map(logic.getBottomButtonTitle)
            .assignNoRetain(to: \.bottomButtonTitle, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBarButtonTitle() {
        displayType
            .map(logic.getBarButtonTitle)
            .assignNoRetain(to: \.barButtonTitle, on: self)
            .store(in: &cancellables)
    }
    
    private var currentUserInputItems: AnyPublisher<([UserInputItem], ItemType), Never> {
        Publishers.CombineLatest(userInputItem, selectedItemType)
            .scan(([UserInputItem](), ItemType.password)) { [unowned self] last, current in self.logic.getCurrentUserInputItems(last: last, current: current) }
            .eraseToAnyPublisher()
    }
    
    private var bottomButtonEnabledForAdd: AnyPublisher<Bool, Never> {
        currentUserInputItems
            .map(logic.getBottomButtonEnabledForAdd)
            .eraseToAnyPublisher()
    }
    
    private var bottomButtonEnabledForCurrentMode: AnyPublisher<Bool, Never> {
        displayType.filter { $0 == .current }.map { _ in true }.eraseToAnyPublisher()
    }
    
    private func bindBottomButtonEnabled() {
        Publishers.Merge(bottomButtonEnabledForAdd, bottomButtonEnabledForCurrentMode)
            .assignNoRetain(to: \.bottomButtonEnabled, on: self)
            .store(in: &cancellables)
    }
    
    private var currentKeepItems: AnyPublisher<[KeepItem], Never> {
        currentUserInputItems
            .map(logic.createCurrentKeepItem)
            .withLatestFrom(savedItems)
            .map { [$0] + $1 }
            .eraseToAnyPublisher()
    }

    // MARK: - Keychain operations
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
    
    private func bindSaveItem() {
        bottomButtonTapped
            .filter(if: displayType.map { $0 == .add })
            .withLatestFrom(currentKeepItems)
            .flatMap { [unowned self] items in
                self.keychainService.save(data: items.1, forKey: keepKey)
            }
            .catch { [weak self] error -> AnyPublisher<Void, Never> in
                switch error {
                case .duplicatedItem: self?.shouldUpdate.send(())
                case .noItem, .unexpectedError: self?.error = .unknown
                case .generalError(let e): self?.error = .generalError(e)
                }
                return .empty()
            }
            .map { _ in true }
            .assignNoRetain(to: \.shouldDismiss, on: self)
            .store(in: &cancellables)
    }
    
    private let shouldUpdate = PassthroughSubject<Void, Never>()
    
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
    
    private func bindDeleteItem() {
        bottomButtonTapped
            .filter(if: displayType.map { $0 == .current })
            .sink { items in
                print("삭제")
            }
            .store(in: &cancellables)
    }
    
    deinit {
        print("ItemViewModel deinit")
    }
}

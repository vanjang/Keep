//
//  ItemEditViewModel.swift
//  Keep
//
//  Created by myung hoon on 09/04/2024.
//

import Foundation
import Combine

final class ItemEditViewModel: KeychainContainableViewModel {
    let editedInputItem: CurrentValueSubject<UserInputItem, Never>
    let saveButtonTapped = PassthroughSubject<Void, Never>()
    
    @Published private(set) var saveButtonEnabled = false
    @Published private(set) var editingText: String?
    @Published private(set) var inputType: ItemInputType
    @Published private(set) var itemSubType: ItemSubType
    @Published private(set) var placedholder: String
    @Published private(set) var shouldPop = false
    @Published private(set) var error: KeepError = .none
    @Published private(set) var showAlertForEmptyString = false
    
    //MARK: - Injection
    private let logic: ItemEditViewModelLogic
    
    //MARK: -
    private var cancellables = Set<AnyCancellable>()
    private let itemType: ItemType
    private let id: String
    private let shouldNotLeaveEmpty: Bool
    
    init(item: ItemEditItem,
         keychainService: any KeychainServiceType = KeychainService(serializer: Serializer<[KeepItem]>()),
         logic: ItemEditViewModelLogic = ItemEditViewModelLogic()) {
        self.editingText = item.editingText
        self.inputType = item.inputType
        self.itemSubType = item.subType
        self.logic = logic
        self.placedholder = item.placeholder
        self.itemType = item.itemType
        self.id = item.id
        self.shouldNotLeaveEmpty = item.shouldNotLeaveEmpty
        self.editedInputItem = CurrentValueSubject(UserInputItem(itemSubType: item.subType, text: ""))
        
        super.init(keychainService: keychainService)
        setupBindings()
    }
    
    private func setupBindings() {
        bindUpdateKeepItem()
        bindSaveButtonEnabled()
        bindShowAlertForEmptyString()
    }
    
    private var currentKeepItems: AnyPublisher<[KeepItem], Never> {
        editedInputItem
            .compactMap { $0 }
            .withLatestFrom(savedKeepItems)
            // KeepItem ID, UserInputItem, ItemType, [KeepItem]
            .map { [unowned self] e in (self.id, e.0, self.itemType, e.1) }
            .map(logic.switchCurrentKeepItem)
            .eraseToAnyPublisher()
    }

    
    private func bindSaveButtonEnabled() {
        editedInputItem
            .compactMap { $0 }
            .map { [unowned self] item in (item.text, self.editingText ?? "") }
            .map(logic.hasEditingTextChanged)
            .assignNoRetain(to: \.saveButtonEnabled, on: self)
            .store(in: &cancellables)
    }

    private var canSave: AnyPublisher<Bool, Never> {
        saveButtonTapped
            .withLatestFrom(editedInputItem)
            .map { [unowned self] item in (self.shouldNotLeaveEmpty, item.1.text) }
            .map(logic.checkCanSave)
            .eraseToAnyPublisher()
    }
    
    private func bindShowAlertForEmptyString() {
        canSave
            .filter { !$0 }
            .map { !$0 }
            .assignNoRetain(to: \.showAlertForEmptyString, on: self)
            .store(in: &cancellables)
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
    
    private func bindUpdateKeepItem() {
        canSave
            .filter { $0 }
            .withLatestFrom(currentKeepItems)
            .flatMap { [unowned self] items in
                self.keychainService.update(items.1, forKey: keepKey)
            }
            .catch { [weak self] error -> AnyPublisher<Void, Never> in
                self?.error = .keychainError(error)
                return .empty()
            }
            .map { _ in true }
            .assignNoRetain(to: \.shouldPop, on: self)
            .store(in: &cancellables)
    }
    
    deinit {
        print("ItemEditViewModel deinit")
    }
}

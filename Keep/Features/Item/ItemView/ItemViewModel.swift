//
//  ItemViewModel.swift
//  Keep
//
//  Created by myung hoon on 13/03/2024.
//

import Foundation
import Combine

final class ItemViewModel: ObservableObject {
    // inputs
    let displayType = PassthroughSubject<ItemDisplayType, Never>()
    let selectedItemType = CurrentValueSubject<ItemType, Never>(.password)
    let userInputItem = PassthroughSubject<UserInputItem, Never>()
    let bottomButtonTapped = PassthroughSubject<Void, Never>()
    
    // outputs
    @Published private(set) var title = ""
    @Published private(set) var itemTypes: [ItemType] = []
    @Published private(set) var bottomButtonTitle = ""
    @Published private(set) var barButtonTitle = ""
    @Published private(set) var detailItems: [ItemInputItem] = []
    @Published private(set) var barButtonActionType: ItemBarButtonActionType = .current
    @Published private(set) var bottomButtonEnabled = false
    @Published private(set) var shouldDismiss = false
    @Published private(set) var error: KeepError = .none
    
    //
    private var cancellables = Set<AnyCancellable>()
    
    private let keychainService: KeychainService<Serializer<[KeepItem]>>
    
    init(keychainService: KeychainService<Serializer<[KeepItem]>> = KeychainService(serializer: Serializer<[KeepItem]>())) {
        self.keychainService = keychainService
        setupBindings()
    }
    
    private func setupBindings() {
        bindTitle()
        bindItemTypes()
        bindDetailItems()
        bindBarButtonActionType()
        bindButtonTitle()
        bindBarButtonTitle()
        bindBottomButtonEnabled()
        bindSaveItem()
        bindDeleteItem()
        bindUpdate()
    }
    
    private func bindTitle() {
        selectedItemType
            .map { $0.rawValue }
            .assign(to: \.title, on: self)
            .store(in: &cancellables)
    }
    
    private func bindItemTypes() {
        selectedItemType
            .map { type -> [ItemType] in
                [.password, .bankAccount, .card, .etc].filter { $0 != type }
            }
            .assign(to: \.itemTypes, on: self)
            .store(in: &cancellables)
    }
    
    private func bindDetailItems() {
        Publishers.CombineLatest(selectedItemType, displayType)
            .map { type, displayType -> [ItemInputItem] in
                switch type {
                case .password:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .email, inputType: .plain, displayType: displayType, placeholder: ItemSubType.email.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .username, inputType: .plain, displayType: displayType, placeholder: ItemSubType.username.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .password, inputType: .plain, displayType: displayType, placeholder: ItemSubType.password.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
                case .bankAccount:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .sortCode, inputType: .plain, displayType: displayType, placeholder: ItemSubType.sortCode.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .accountNumber, inputType: .plain, displayType: displayType, placeholder: ItemSubType.accountNumber.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
                case .card:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .longNumber, inputType: .longNumber, displayType: displayType, placeholder: ItemSubType.longNumber.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .startFrom, inputType: .date, displayType: displayType, placeholder: ItemSubType.startFrom.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .expireBy, inputType: .date, displayType: displayType, placeholder: ItemSubType.expireBy.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .securityCode, inputType: .plain, displayType: displayType, placeholder: ItemSubType.securityCode.rawValue + "(optional)", isOptional: true),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue + "(optional)", isOptional: true)]
                case .etc:
                    return [ItemInputItem(itemSubType: .title, inputType: .plain, displayType: displayType, placeholder: ItemSubType.title.rawValue, isOptional: false),
                            ItemInputItem(itemSubType: .memo, inputType: .multiLine, displayType: displayType, placeholder: ItemSubType.memo.rawValue, isOptional: false)]
                }
            }
            .assign(to: \.detailItems, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBarButtonActionType() {
        displayType
            .map { type -> ItemBarButtonActionType in
                switch type {
                case .add: return .actionSheet
                case .current: return .edit
                case .edit: return .current
                }
            }
            .assign(to: \.barButtonActionType, on: self)
            .store(in: &cancellables)
    }
    
    private func bindButtonTitle() {
        displayType
            .map { type -> String in
                switch type {
                case .add: return "Add"
                case .current: return "Delete"
                case .edit: return ""
                }
            }
            .assign(to: \.bottomButtonTitle, on: self)
            .store(in: &cancellables)
    }
    
    private func bindBarButtonTitle() {
        displayType
            .map { type -> String in
                switch type {
                case .add: return "Change"
                case .current: return "Edit"
                case .edit: return "Cancel"
                }
            }
            .assign(to: \.barButtonTitle, on: self)
            .store(in: &cancellables)
    }
    
    private lazy var currentUserInputItems: AnyPublisher<([UserInputItem], ItemType), Never> = {
        Publishers.CombineLatest(userInputItem, selectedItemType)
            .scan(([UserInputItem](), ItemType.password)) { last, current in
                let currentItem = current.0
                let currentType = current.1

                var lastItems = last.0
                let lastType = last.1
                
                if currentType == lastType {
                    if currentItem.text.isEmpty, let index = lastItems.firstIndex(where: { $0.itemSubType == currentItem.itemSubType }) {
                        lastItems.remove(at: index)
                        return (lastItems, currentType)
                    } else {
                        return (lastItems.filter { $0.itemSubType != currentItem.itemSubType } + [currentItem], currentType)
                    }
                } else {
                    return ([], currentType)
                }
            }
            .eraseToAnyPublisher()
    }()
    
    private func bindBottomButtonEnabled() {
        let add = currentUserInputItems
            .map { (inputItems, inputType) -> Bool in
                switch inputType {
                case .password:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .password }
                case .bankAccount:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .accountNumber }
                case .card:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .longNumber }
                case .etc:
                    return inputItems.contains { $0.itemSubType == .title } && inputItems.contains { $0.itemSubType == .memo }
                }
            }
        
        let current = displayType.filter { $0 == .current }.map { _ in true }
        
        Publishers.Merge(add, current)
            .assign(to: \.bottomButtonEnabled, on: self)
            .store(in: &cancellables)
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
    
    private var buttonTapped: AnyPublisher<[KeepItem], Never> {
       bottomButtonTapped
            .filter(if: displayType.map { $0 == .add })
            .withLatestFrom(currentUserInputItems)
            .map { [unowned self] (_, items) -> KeepItem in
                switch items.1 {
                case .password: return self.createPassword(from: items.0)
                case .bankAccount: return self.createBankAccount(from: items.0)
                case .card: return self.createCard(from: items.0)
                case .etc: return self.createEtc(from: items.0)
                }
            }
            .withLatestFrom(savedItems)
            .map { [$0] + $1 }
            .eraseToAnyPublisher()
    }
    
    private let shouldUpdate = PassthroughSubject<Void, Never>()
    
    private func bindUpdate() {
        shouldUpdate
            .withLatestFrom(savedItems)
            .flatMap { [unowned self] items in
                self.keychainService.update(items.1, forKey: keepKey)
            }
            .catch { error -> AnyPublisher<Void, Never> in
                return .empty()
            }
            .map { _ in true }
            .assign(to: \.shouldDismiss, on: self)
            .store(in: &cancellables)
    }
    
    private func bindSaveItem() {
        buttonTapped
            .flatMap { [unowned self] items in
                self.keychainService.save(data: items, forKey: keepKey)
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
            .assign(to: \.shouldDismiss, on: self)
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
    
    private func createPassword(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let email = inputItems.first { $0.itemSubType == .email }?.text
        let username = inputItems.first { $0.itemSubType == .username }?.text
        let password = inputItems.first { $0.itemSubType == .password }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .password(Password(id: Helpers.randomString(), title: title, email: email, username: username, password: password, memo: memo, dateCreated: "", dateModified: nil))
    }

    private func createBankAccount(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let sortCode = inputItems.first { $0.itemSubType == .sortCode }?.text
        let accountNumber = inputItems.first { $0.itemSubType == .accountNumber }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .bankAccount(BankAccount(id: Helpers.randomString(), title: title, sortCode: sortCode, accountNumber: accountNumber, memo: memo, dateCreated: "", dateModified: nil))
    }

    private func createCard(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let longNumber = inputItems.first { $0.itemSubType == .longNumber }?.text ?? ""
        let dateStartingFrom = inputItems.first { $0.itemSubType == .startFrom }?.text
        let dateEndingBy = inputItems.first { $0.itemSubType == .expireBy }?.text
        let securityCode = inputItems.first { $0.itemSubType == .securityCode }?.text
        let memo = inputItems.first { $0.itemSubType == .memo }?.text
        return .card(Card(id: Helpers.randomString(), title: title, longNumber: longNumber, dateStartingFrom: dateStartingFrom, dateEndingBy: dateEndingBy, securityCode: securityCode, memo: memo, dateCreated: "", dateModified: nil))
    }

    private func createEtc(from inputItems: [UserInputItem]) -> KeepItem {
        let title = inputItems.first { $0.itemSubType == .title }?.text ?? ""
        let memo = inputItems.first { $0.itemSubType == .memo }?.text ?? ""
        return .etc(Etc(id: Helpers.randomString(), title: title, memo: memo, dateCreated: "", dateModified: nil))
    }
}

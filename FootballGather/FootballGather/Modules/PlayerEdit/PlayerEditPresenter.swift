//
//  PlayerEditPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 25/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerEditPresenterProtocol
protocol PlayerEditPresenterProtocol: AnyObject {
    var title: String { get }
    var playerRowValue: String { get }
    var isSelectionViewType: Bool { get }
    var numberOfRows: Int { get }
    var selectedItemIndex: Int? { get }
    var editablePlayer: PlayerResponseModel { get }
    
    func doneButtonIsEnabled(newValue: String?) -> Bool
    func doneButtonIsEnabled(selectedIndexPath: IndexPath) -> Bool
    func updatePlayerBasedOnViewType(inputFieldValue: String?)
    func itemRowTextDescription(indexPath: IndexPath) -> String?
    func isSelectedIndexPath(_ indexPath: IndexPath) -> Bool
    func updateSelectedItemIndex(_ newItemIndex: Int)
}

// MARK: - PlayerEditPresenter
final class PlayerEditPresenter: PlayerEditPresenterProtocol {
    
    // MARK: - Properties
    private weak var view: PlayerEditViewProtocol?
    private var playerEditModel: PlayerEditModel
    private var viewType: PlayerEditViewType
    private var playerItemsEditModel: PlayerItemsEditModel?
    private var service: StandardNetworkService
    
    // MARK: - Public API
    init(view: PlayerEditViewProtocol? = nil,
         viewType: PlayerEditViewType = .text,
         playerEditModel: PlayerEditModel,
         playerItemsEditModel: PlayerItemsEditModel? = nil,
         service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.view = view
        self.viewType = viewType
        self.playerEditModel = playerEditModel
        self.playerItemsEditModel = playerItemsEditModel
        self.service = service
    }
    
    var title: String {
        return playerEditModel.playerRow.title
    }
    
    var playerRowValue: String {
        return playerEditModel.playerRow.value
    }

    var isSelectionViewType: Bool {
        return viewType == .selection
    }
    
    var editablePlayer: PlayerResponseModel {
        return playerEditModel.player
    }
    
    func doneButtonIsEnabled(newValue: String?) -> Bool {
        if let newValue = newValue, playerEditModel.playerRow.value != newValue {
            return true
        }
        
        return false
    }
    
    func doneButtonIsEnabled(selectedIndexPath: IndexPath) -> Bool {
        if let newValue = playerItemsEditModel?.items[selectedIndexPath.row], playerEditModel.playerRow.value != newValue {
            return true
        }
        
        return false
    }

    
    func updatePlayerBasedOnViewType(inputFieldValue: String?) {
        guard shouldUpdatePlayer(inputFieldValue: inputFieldValue) else { return }
        
        view?.showLoadingView()
        
        let fieldValue = isSelectionViewType ? selectedItemValue : inputFieldValue
        
        updatePlayer(newFieldValue: fieldValue) { [weak self] updated in
            DispatchQueue.main.async {
                self?.view?.hideLoadingView()
                self?.handleUpdatedPlayerResult(updated)
            }
        }
    }
    
    private func shouldUpdatePlayer(inputFieldValue: String?) -> Bool {
        if isSelectionViewType {
            return newValueIsDifferentFromOldValue(newFieldValue: selectedItemValue)
        }
        
        return newValueIsDifferentFromOldValue(newFieldValue: inputFieldValue)
    }
    
    private func newValueIsDifferentFromOldValue(newFieldValue: String?) -> Bool {
        guard let newFieldValue = newFieldValue else { return false }
        
        return playerEditModel.playerRow.value.lowercased() != newFieldValue.lowercased()
    }

    private func updatePlayer(newFieldValue: String?, completion: @escaping (Bool) -> ()) {
        guard let newFieldValue = newFieldValue else {
            completion(false)
            return
        }
        
        playerEditModel.player.update(usingField: playerEditModel.playerRow.editableField, value: newFieldValue)
        requestUpdatePlayer(completion: completion)
    }
    
    private var selectedItemValue: String? {
        guard let playerItemsEditModel = playerItemsEditModel else { return nil}
        
        return playerItemsEditModel.items[playerItemsEditModel.selectedItemIndex]
    }
    
    private func requestUpdatePlayer(completion: @escaping (Bool) -> ()) {
        let player = playerEditModel.player
        service.update(PlayerCreateModel(player), resourceID: ResourceID.integer(player.id)) { [weak self] result in
            if case .success(let updated) = result {
                self?.playerEditModel.player = player
                completion(updated)
            } else {
                completion(false)
            }
        }
    }
    
    private func handleUpdatedPlayerResult(_ playerWasUpdated: Bool) {
        if playerWasUpdated {
            view?.handleSuccessfulPlayerUpdate(editablePlayer)
        } else {
            view?.handleError(title: "Error update", message: "Unable to update player. Please try again.")
        }
    }
    
    // MARK: - TableView interaction
    var numberOfRows: Int {
        return playerItemsEditModel?.items.count ?? 0
    }

    func itemRowTextDescription(indexPath: IndexPath) -> String? {
        return playerItemsEditModel?.items[indexPath.row].capitalized
    }
    
    func isSelectedIndexPath(_ indexPath: IndexPath) -> Bool {
        return playerItemsEditModel?.selectedItemIndex == indexPath.row
    }

    var selectedItemIndex: Int? {
        return playerItemsEditModel?.selectedItemIndex
    }
    
    func updateSelectedItemIndex(_ newItemIndex: Int) {
        playerItemsEditModel?.selectedItemIndex = newItemIndex
    }
    
}

// MARK: - PlayerEditViewType
enum PlayerEditViewType {
    case text, selection
}

// MARK: - PlayerEditModel
struct PlayerEditModel {
    var player: PlayerResponseModel
    let playerRow: PlayerRow
}

// MARK: -
struct PlayerItemsEditModel {
    let items: [String]
    var selectedItemIndex: Int
}

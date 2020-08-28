//
//  PlayerEditViewModel.swift
//  FootballGather
//
//  Created by Radu Dan on 27/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerEditViewModel
final class PlayerEditViewModel {
    
    // MARK: - Properties
    private var viewType: PlayerEditViewType
    private var playerEditModel: PlayerEditModel
    private var playerItemsEditModel: PlayerItemsEditModel?
    private var service: StandardNetworkService
    
    // MARK: - Public API
    init(viewType: PlayerEditViewType = .text,
         playerEditModel: PlayerEditModel,
         playerItemsEditModel: PlayerItemsEditModel? = nil,
         service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.viewType = viewType
        self.playerEditModel = playerEditModel
        self.playerItemsEditModel = playerItemsEditModel
        self.service = service
    }
    
    func updatePlayerItemsEditModel(newItemsEditModel: PlayerItemsEditModel) {
        playerItemsEditModel = newItemsEditModel
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
    
    func doneButtonIsEnabled(selectedIndexPath: IndexPath) -> Bool {
        if let newValue = playerItemsEditModel?.items[selectedIndexPath.row], playerEditModel.playerRow.value != newValue {
            return true
        }
        
        return false
    }
    
    func doneButtonIsEnabled(newValue: String?) -> Bool {
        if let newValue = newValue, playerEditModel.playerRow.value != newValue {
            return true
        }
        
        return false
    }
    
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
    
    // MARK: - Update player
    func shouldUpdatePlayer(inputFieldValue: String?) -> Bool {
        if isSelectionViewType {
            return newValueIsDifferentFromOldValue(newFieldValue: selectedItemValue)
        }
        
        return newValueIsDifferentFromOldValue(newFieldValue: inputFieldValue)
    }
    
    private func newValueIsDifferentFromOldValue(newFieldValue: String?) -> Bool {
        guard let newFieldValue = newFieldValue else { return false }
        
        return playerEditModel.playerRow.value.lowercased() != newFieldValue.lowercased()
    }
    
    private var selectedItemValue: String? {
        guard let playerItemsEditModel = playerItemsEditModel else { return nil}
        
        return playerItemsEditModel.items[playerItemsEditModel.selectedItemIndex]
    }
    
    func updatePlayerBasedOnViewType(inputFieldValue: String?, completion: @escaping (Bool) -> ()) {
        if isSelectionViewType {
            updatePlayer(newFieldValue: selectedItemValue, completion: completion)
        } else {
            updatePlayer(newFieldValue: inputFieldValue, completion: completion)
        }
    }
    
    private func updatePlayer(newFieldValue: String?, completion: @escaping (Bool) -> ()) {
        guard let newFieldValue = newFieldValue else {
            completion(false)
            return
        }
        
        playerEditModel.player.update(usingField: playerEditModel.playerRow.editableField, value: newFieldValue)
        requestUpdatePlayer(completion: completion)
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

//
//  PlayerEditInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 22/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerEditInteractor
final class PlayerEditInteractor: PlayerEditInteractable {
    
    var presenter: PlayerEditPresenterProtocol
    weak var delegate: PlayerEditDelegate?
    
    private var playerEditable: PlayerEditable
    private var service: StandardNetworkService
    
    init(presenter: PlayerEditPresenterProtocol = PlayerEditPresenter(),
         delegate: PlayerEditDelegate? = nil,
         playerEditable: PlayerEditable,
         service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.presenter = presenter
        self.delegate = delegate
        self.playerEditable = playerEditable
        self.service = service
    }
    
}

// MARK: - Configure
extension PlayerEditInteractor: PlayerEditInteractorConfigurable {
    func configureField(request: PlayerEdit.ConfigureField.Request) {
        let response = PlayerEdit.ConfigureField.Response(rowDetailsValue: playerEditable.rowDetails?.value,
                                                          editableItemsAreEmpty: editableItemsAreEmpty)
        presenter.presentField(response: response)
    }
    
    private var editableItemsAreEmpty: Bool {
        playerEditable.items.isEmpty == false
    }
    
    func configureTitle(request: PlayerEdit.ConfigureTitle.Request) {
        let response = PlayerEdit.ConfigureTitle.Response(playerName: playerEditable.player.name)
        presenter.presentTitle(response: response)
    }
    
    func configureTable(request: PlayerEdit.ConfigureTable.Request) {
        let response = PlayerEdit.ConfigureTable.Response(editableItemsAreEmpty: editableItemsAreEmpty)
        presenter.presentTable(response: response)
    }
}

// MARK: Table Delegate
extension PlayerEditInteractor: PlayerEditInteractorTableDelegate {
    func numberOfRows(request: PlayerEdit.RowsCount.Request) -> Int {
        playerEditable.items.count
    }
    
    func rowDetails(request: PlayerEdit.RowDetails.Request) -> PlayerEdit.RowDetails.ViewModel {
        let isSelected = rowIsSelected(at: request.indexPath.row)
        let response = PlayerEdit.RowDetails.Response(indexPath: request.indexPath,
                                                      editablePlayer: playerEditable,
                                                      isSelected: isSelected)
        return presenter.rowDetails(response: response)
    }
    
    func updateSelection(request: PlayerEdit.UpdateSelection.Request) {
        guard rowIsSelected(at: request.indexPath.row) == false else {
            return
        }
        
        let response = PlayerEdit.UpdateSelection.Response(selectedItemIndex: playerEditable.selectedItemIndex,
                                                           indexPath: request.indexPath)
        presenter.updateViewSelection(response: response)
    }
    
    private func rowIsSelected(at index: Int) -> Bool {
        playerEditable.selectedItemIndex == index
    }
    
    func selectRow(request: PlayerEdit.SelectRow.Request) {
        let index = request.indexPath.row
        
        guard rowIsSelected(at: index) == false else {
            return
        }
        
        updateSelectedItemIndex(index)
        
        let response = PlayerEdit.SelectRow.Response(index: index,
                                                     editablePlayer: playerEditable)
        presenter.updateSelectedPlayer(response: response)
    }
    
    private func updateSelectedItemIndex(_ index: Int) {
        playerEditable.selectedItemIndex = index
    }
}

// MARK: - Actionable
extension PlayerEditInteractor: PlayerEditInteractorActionable {
    func updateValue(request: PlayerEdit.UpdateField.Request) {
        let response = PlayerEdit.UpdateField.Response(currentRowDetailsValue: playerEditable.rowDetails?.value,
                                                       editableFieldOption: playerEditable.rowDetails?.editableField,
                                                       updatedValue: request.text)
        presenter.updateView(response: response)
    }
    
    func endEditing(request: PlayerEdit.Done.Request) {
        commitUpdates(enteredText: request.text)
        updatePlayer()
    }
    
    private func commitUpdates(enteredText: String? = nil) {
        if playerEditable.items.isEmpty {
            updatePlayerField(newValue: enteredText)
        } else if let selectedIndex = playerEditable.selectedItemIndex {
            let newValue = playerEditable.items[selectedIndex]
            updatePlayerField(newValue: newValue)
        }
    }
    
    private func updatePlayer() {
        let player = playerEditable.player
        service.update(PlayerCreateModel(player), resourceID: ResourceID.integer(player.id)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if case .success(let updated) = result, updated == true {
                    self.playerEditable.player = player
                    self.delegate?.didUpdate(player: player)
                    self.presenter.dismissEditView()
                } else {
                    let errorResponse = PlayerEdit.ErrorResponse(error: .updateError)
                    self.presenter.presentError(response: errorResponse)
                }
            }
        }
    }
}

// MARK: - Private methodss
private extension PlayerEditInteractor {
    func updatePlayerField(newValue: String?) {
        guard let fieldOption = playerEditable.rowDetails?.editableField else {
            return
        }
        
        switch fieldOption {
        case .age:
            updateAge(newValue: newValue)
            
        case .favouriteTeam:
            updateTeam(newValue: newValue)
            
        case .name:
            updateName(newValue: newValue)
            
        case .position:
            updatePosition(newValue: newValue)
            
        case .skill:
            updateSkill(newValue: newValue)
        }
    }
    
    func updateAge(newValue: String?) {
        if let newValue = newValue {
            playerEditable.player.age = Int(newValue)
        } else {
            playerEditable.player.age = nil
        }
    }
    
    func updateTeam(newValue: String?) {
        if let team = newValue {
            playerEditable.player.favouriteTeam = team
        } else {
            playerEditable.player.favouriteTeam = nil
        }
    }
    
    func updateName(newValue: String?) {
        guard let name = newValue, name.isEmpty == false else {
            return
        }
        
        playerEditable.player.name = name
    }
    
    func updatePosition(newValue: String?) {
        if let position = newValue {
            playerEditable.player.preferredPosition = PlayerPosition(rawValue: position)
        } else {
            playerEditable.player.preferredPosition = nil
        }
    }
    
    func updateSkill(newValue: String?) {
        if let skill = newValue {
            playerEditable.player.skill = PlayerSkill(rawValue: skill)
        } else {
            playerEditable.player.skill = nil
        }
    }
}

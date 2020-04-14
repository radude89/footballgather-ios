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
    
    weak var presenter: PlayerEditPresenterProtocol?
    
    private(set) var playerEditable: PlayerEditable
    private var service: StandardNetworkService
    
    init(playerEditable: PlayerEditable,
         service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.playerEditable = playerEditable
        self.service = service
    }
    
}

// MARK: - Service Handler
extension PlayerEditInteractor: PlayerEditInteractorServiceHander {
    func updateSelectedItemIndex(_ index: Int) {
        playerEditable.selectedItemIndex = index
    }
    
    func updatePlayer() {
        let player = playerEditable.player
        service.update(PlayerCreateModel(player), resourceID: ResourceID.integer(player.id)) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let updated) = result, updated == true {
                    self?.playerEditable.player = player
                    self?.presenter?.playerWasUpdated()
                } else {
                    self?.presenter?.serviceFailedToUpdatePlayer()
                }
            }
        }
    }
    
    func commitUpdates(with enteredText: String? = nil) {
        if playerEditable.items.isEmpty {
            updatePlayerField(with: enteredText)
        } else if let selectedIndex = playerEditable.selectedItemIndex {
            let newValue = playerEditable.items[selectedIndex]
            updatePlayerField(with: newValue)
        }
    }
}

// MARK: - Private methodss
private extension PlayerEditInteractor {
    private func updatePlayerField(with newValue: String?) {
        guard let fieldOption = playerEditable.rowDetails?.editableField else {
            return
        }
        
        switch fieldOption {
        case .age:
            updateAge(with: newValue)
            
        case .favouriteTeam:
            updateTeam(with: newValue)
            
        case .name:
            updateName(with: newValue)
            
        case .position:
            updatePosition(with: newValue)
            
        case .skill:
            updateSkill(with: newValue)
        }
    }
    
    private func updateAge(with newValue: String?) {
        if let newValue = newValue {
            playerEditable.player.age = Int(newValue)
        } else {
            playerEditable.player.age = nil
        }
    }
    
    private func updateTeam(with newValue: String?) {
        if let team = newValue {
            playerEditable.player.favouriteTeam = team
        } else {
            playerEditable.player.favouriteTeam = nil
        }
    }
    
    private func updateName(with newValue: String?) {
        guard let name = newValue, name.isEmpty == false else {
            return
        }
        
        playerEditable.player.name = name
    }
    
    private func updatePosition(with newValue: String?) {
        if let position = newValue {
            playerEditable.player.preferredPosition = PlayerPosition(rawValue: position)
        } else {
            playerEditable.player.preferredPosition = nil
        }
    }
    
    private func updateSkill(with newValue: String?) {
        if let skill = newValue {
            playerEditable.player.skill = PlayerSkill(rawValue: skill)
        } else {
            playerEditable.player.skill = nil
        }
    }
}

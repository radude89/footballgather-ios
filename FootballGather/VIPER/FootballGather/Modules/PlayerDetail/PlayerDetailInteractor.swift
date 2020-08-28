//
//  PlayerDetailInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 21/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerDetailInteractor
final class PlayerDetailInteractor: PlayerDetailInteractable {
    
    weak var presenter: PlayerDetailPresenterProtocol?
    
    private(set) var player: PlayerResponseModel
    
    init(player: PlayerResponseModel) {
        self.player = player
    }
    
}

// MARK: - Service Handler
extension PlayerDetailInteractor: PlayerDetailInteractorServiceHander {
    func updatePlayer(_ player: PlayerResponseModel) {
        self.player = player
        presenter?.playerWasUpdated()
    }
}

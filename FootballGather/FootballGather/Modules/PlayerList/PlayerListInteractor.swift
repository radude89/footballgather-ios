//
//  PlayerListInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 15/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerListInteractor
final class PlayerListInteractor: PlayerListInteractable {
    
    weak var presenter: PlayerListPresenterProtocol?
    var players: [PlayerResponseModel]
    
    private let playersService: StandardNetworkService
    
    init(playersService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true),
         players: [PlayerResponseModel] = []) {
        self.playersService = playersService
        self.players = players
    }
    
}

// MARK: - Service Handler
extension PlayerListInteractor: PlayerListInteractorServiceHander {
    
    var minimumPlayersToPlay: Int { 2 }
    
    func loadPlayers() {
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.presenter?.serviceFailedWithError(error)
                    
                case .success(let players):
                    self?.players = players
                    self?.presenter?.playerListDidLoad()
                }
            }
        }
    }
    
    func deletePlayer(at index: Int) {
        let player = players[index]
        var service = playersService
        
        service.delete(withID: ResourceID.integer(player.id)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.presenter?.serviceFailedWithError(error)
                    
                case .success(_):
                    self?.presenter?.playerWasDeleted(at: index)
                }
            }
        }
    }
    
    func updatePlayer(_ player: PlayerResponseModel) {
        guard let index = players.firstIndex(of: player) else {
            return
        }
        
        players[index] = player
    }
    
    func selectedPlayers(atRows rows: Set<Int>) -> [TeamSection: [PlayerResponseModel]] {
        let selectedPlayers = rows.map { players[$0] }
        return [.bench: selectedPlayers]
    }
}

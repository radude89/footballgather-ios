//
//  ConfirmPlayersInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 27/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - ConfirmPlayersInteractor
final class ConfirmPlayersInteractor: ConfirmPlayersInteractable {
    
    weak var presenter: ConfirmPlayersPresenterProtocol?
    
    private var playersDictionary: [TeamSection: [PlayerResponseModel]]
    private let gatherService: StandardNetworkService
    
    private let dispatchGroup = DispatchGroup()
    private var gatherUUID: UUID?
    
    init(playersDictionary: [TeamSection: [PlayerResponseModel]] = [:],
         gatherService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)) {
        self.playersDictionary = playersDictionary
        self.gatherService = gatherService
    }
    
}

// MARK: - Service Handler
extension ConfirmPlayersInteractor: ConfirmPlayersInteractorServiceHander {
    var teamSections: [TeamSection] { TeamSection.allCases }
    
    var hasPlayersInBothTeams: Bool {
        playersDictionary[.teamA]?.isEmpty == false && playersDictionary[.teamB]?.isEmpty == false
    }
    
    func players(for teamSection: TeamSection) -> [PlayerResponseModel] {
        playersDictionary[teamSection] ?? []
    }
    
    func removePlayer(from sourceTeam: TeamSection, index: Int) {
        playersDictionary[sourceTeam]?.remove(at: index)
    }
    
    func insertPlayer(_ player: PlayerResponseModel, at destinationTeam: TeamSection, index: Int) {
        if playersDictionary[destinationTeam]?.isEmpty == false {
            playersDictionary[destinationTeam]?.insert(player, at: index)
        } else {
            playersDictionary[destinationTeam] = [player]
        }
    }
    
    func startGather() {
        createGatherAndAddPlayers { [weak self] result in
            DispatchQueue.main.async {
                if let gather = self?.gatherModel, result == false {
                    self?.presenter?.createdGather(gather)
                } else {
                    self?.presenter?.serviceFailedToStartGather()
                }
            }
        }
    }
    
    private func createGatherAndAddPlayers(completion: @escaping (Bool) -> ()) {
        createGather { [weak self] uuid in
            guard let gatherUUID = uuid else {
                completion(false)
                return
            }
            
            self?.gatherUUID = gatherUUID
            self?.addPlayersToGather(havingUUID: gatherUUID, completion: completion)
        }
    }
    
    private func createGather(completion: @escaping (UUID?) -> Void) {
        gatherService.create(GatherCreateModel()) { result in
            if case let .success(ResourceID.uuid(gatherUUID)) = result {
                completion(gatherUUID)
            } else {
                completion(nil)
            }
        }
    }
    
    private func addPlayersToGather(havingUUID gatherUUID: UUID, completion: @escaping (Bool) -> ()) {
        var serviceFailed = false
        
        playerTeamArray.forEach { playerTeam in
            dispatchGroup.enter()
            
            self.addPlayer(playerTeam.player, toGatherHavingUUID: gatherUUID, team: playerTeam.team) { [weak self] playerWasAdded in
                if !playerWasAdded {
                    serviceFailed = true
                }
                
                self?.dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(serviceFailed)
        }
    }
    
    private var playerTeamArray: [PlayerTeamModel] {
        var players: [PlayerTeamModel] = []
        players += self.playersDictionary
            .filter { $0.key == .teamA }
            .flatMap { $0.value }
            .map { PlayerTeamModel(team: .teamA, player: $0) }
        
        players += self.playersDictionary
            .filter { $0.key == .teamB }
            .flatMap { $0.value }
            .map { PlayerTeamModel(team: .teamB, player: $0) }
        
        return players
    }
    
    private func addPlayer(_ player: PlayerResponseModel,
                           toGatherHavingUUID gatherUUID: UUID,
                           team: TeamSection,
                           completion: @escaping (Bool) -> Void) {
        var addPlayerToGatherService = AddPlayerToGatherService()
        addPlayerToGatherService.addPlayer(
            havingServerId: player.id,
            toGatherWithId: gatherUUID,
            team: PlayerGatherTeam(team: team.headerTitle)) { result in
                if case let .success(resultValue) = result {
                    completion(resultValue)
                } else {
                    completion(false)
                }
        }
    }
    
    private var gatherModel: GatherModel? {
        guard let gatherUUID = gatherUUID else { return nil }
        
        return GatherModel(players: playerTeamArray, gatherUUID: gatherUUID)
    }
}

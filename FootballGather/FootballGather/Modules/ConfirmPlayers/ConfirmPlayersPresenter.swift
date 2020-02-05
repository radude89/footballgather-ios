//
//  ConfirmPlayersPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - ConfirmPlayersPresenterProtocol
protocol ConfirmPlayersPresenterProtocol: AnyObject {
    var gatherModel: GatherModel? { get }
    var startGatherButtonIsEnabled: Bool { get }
    var numberOfSections: Int { get }
    
    func titleForHeaderInSection(_ section: Int) -> String?
    func numberOfRowsInSection(_ section: Int) -> Int
    func rowTitle(at indexPath: IndexPath) -> String?
    func rowDescription(at indexPath: IndexPath) -> String?
    func moveRowAt(sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    func initiateStartGather()
}

// MARK: - ConfirmPlayersPresenter
final class ConfirmPlayersPresenter: ConfirmPlayersPresenterProtocol {
    
    // MARK: - Properties
    private weak var view: ConfirmPlayersViewProtocol?
    private var playersDictionary: [TeamSection: [PlayerResponseModel]]
    private var addPlayerService: AddPlayerToGatherService
    private let gatherService: StandardNetworkService
    
    private let dispatchGroup = DispatchGroup()
    private var gatherUUID: UUID?
    
    // MARK: - Public API
    init(view: ConfirmPlayersViewProtocol? = nil,
         playersDictionary: [TeamSection: [PlayerResponseModel]] = [:],
         addPlayerService: AddPlayerToGatherService = AddPlayerToGatherService(),
         gatherService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)) {
        self.view = view
        self.playersDictionary = playersDictionary
        self.addPlayerService = addPlayerService
        self.gatherService = gatherService
    }
    
    var gatherModel: GatherModel? {
        guard let gatherUUID = gatherUUID else { return nil }
        
        return GatherModel(players: playerTeamArray, gatherUUID: gatherUUID)
    }
    
    var startGatherButtonIsEnabled: Bool {
        if playersDictionary[.teamA]?.isEmpty == false &&
            playersDictionary[.teamB]?.isEmpty == false {
            return true
        }
        
        return false
    }
    
    var numberOfSections: Int {
        return TeamSection.allCases.count
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        return TeamSection(rawValue: section)?.headerTitle
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let team = TeamSection(rawValue: section), let players = playersDictionary[team] else { return 0 }
        
        return players.count
    }
    
    func rowTitle(at indexPath: IndexPath) -> String? {
        guard let team = TeamSection(rawValue: indexPath.section), let players = playersDictionary[team] else { return nil }
        
        return players[indexPath.row].name
    }
    
    func rowDescription(at indexPath: IndexPath) -> String? {
        guard let team = TeamSection(rawValue: indexPath.section), let players = playersDictionary[team] else { return nil }
        
        return players[indexPath.row].preferredPosition?.acronym
    }
    
    func moveRowAt(sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let sourceTeam = TeamSection(rawValue: sourceIndexPath.section),
            let sourcePlayer = playersDictionary[sourceTeam]?[sourceIndexPath.row],
            let destinationTeam = TeamSection(rawValue: destinationIndexPath.section) else {
                fatalError("Unable to move players")
        }
        
        playersDictionary[sourceTeam]?.remove(at: sourceIndexPath.row)
        
        if playersDictionary[destinationTeam]?.isEmpty == false {
            playersDictionary[destinationTeam]?.insert(sourcePlayer, at: destinationIndexPath.row)
        } else {
            playersDictionary[destinationTeam] = [sourcePlayer]
        }
    }
    
    // MARK: - Service
    func initiateStartGather() {
        view?.showLoadingView()

        startGather { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingView()

                if !result {
                    self?.view?.handleError(title: "Error", message: "Unable to create gather.")
                } else {
                    self?.view?.handleSuccessfulStartGather()
                }
            }
        }
    }
    
    private func startGather(completion: @escaping (Bool) -> ()) {
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
        addPlayerService.addPlayer(
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
    
}

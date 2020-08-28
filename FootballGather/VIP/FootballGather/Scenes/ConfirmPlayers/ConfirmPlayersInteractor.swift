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
    
    var presenter: ConfirmPlayersPresenterProtocol
    weak var delegate: ConfirmPlayersDelegate?
    
    private var playersDictionary: [TeamSection: [PlayerResponseModel]]
    private let gatherService: StandardNetworkService
    private let dispatchGroup = DispatchGroup()
    private var gatherUUID: UUID?
    
    init(presenter: ConfirmPlayersPresenterProtocol = ConfirmPlayersPresenter(),
         delegate: ConfirmPlayersDelegate? = nil,
         playersDictionary: [TeamSection: [PlayerResponseModel]] = [:],
         gatherService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)) {
        self.presenter = presenter
        self.delegate = delegate
        self.playersDictionary = playersDictionary
        self.gatherService = gatherService
    }
    
}
    
// MARK: - Actionable
extension ConfirmPlayersInteractor: ConfirmPlayersInteractorActionable {
    func startGather(request: ConfirmPlayers.StartGather.Request) {
        createGatherAndAddPlayers { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let gather = self.gatherModel, result == false {
                    let response = ConfirmPlayers.StartGather.Response(gather: gather, delegate: self)
                    self.presenter.showGatherView(response: response)
                } else {
                    let errorResponse = ConfirmPlayers.ErrorResponse(error: .startGatherError)
                    self.presenter.presentError(response: errorResponse)
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

// MARK: Table Delegate
extension ConfirmPlayersInteractor: ConfirmPlayersInteractorTableDelegate {
    func numberOfSections(request: ConfirmPlayers.SectionsCount.Request) -> Int {
        let response = ConfirmPlayers.SectionsCount.Response()
        return presenter.numberOfSections(response: response)
    }
    
    func numberOfRowsInSection(request: ConfirmPlayers.RowsCount.Request) -> Int {
        guard let teamSection = TeamSection(rawValue: request.section) else {
            return 0
        }
        
        let players = self.players(for: teamSection)
        let response = ConfirmPlayers.RowsCount.Response(players: players)
        
        return presenter.numberOfRowsInSection(response: response)
    }
    
    private func players(for teamSection: TeamSection) -> [PlayerResponseModel] {
        playersDictionary[teamSection] ?? []
    }
    
    func titleForHeaderInSection(request: ConfirmPlayers.SectionTitle.Request) -> ConfirmPlayers.SectionTitle.ViewModel {
        let response = ConfirmPlayers.SectionTitle.Response(section: request.section)
        return presenter.titleForHeaderInSection(response: response)
    }
    
    func rowDetails(request: ConfirmPlayers.RowDetails.Request) -> ConfirmPlayers.RowDetails.ViewModel? {
        let player = self.player(at: request.indexPath)
        let response = ConfirmPlayers.RowDetails.Response(player: player)
        return presenter.rowDetails(response: response)
    }
    
    func move(request: ConfirmPlayers.Move.Request) {
        let sourceIndexPath = request.sourceIndexPath
        let destinationIndexPath = request.destinationIndexPath
        
        guard let sourceTeam = TeamSection(rawValue: sourceIndexPath.section),
            let player = player(at: sourceIndexPath),
            let destinationTeam = TeamSection(rawValue: destinationIndexPath.section) else {
                fatalError("Unable to move players")
        }
        
        removePlayer(from: sourceTeam, index: sourceIndexPath.row)
        insertPlayer(player, at: destinationTeam, index: destinationIndexPath.row)
        
        let response = ConfirmPlayers.Move.Response(hasPlayersInBothTeams: hasPlayersInBothTeams)
        presenter.move(response: response)
    }
    
    private func player(at indexPath: IndexPath) -> PlayerResponseModel? {
        guard let teamSection = TeamSection(rawValue: indexPath.section) else {
            return nil
        }
        
        let players = self.players(for: teamSection)
        
        if players.isEmpty {
            return nil
        }
        
        return players[indexPath.row]
    }
    
    private var hasPlayersInBothTeams: Bool {
        playersDictionary[.teamA]?.isEmpty == false &&
            playersDictionary[.teamB]?.isEmpty == false
    }
    
    private func removePlayer(from sourceTeam: TeamSection, index: Int) {
        playersDictionary[sourceTeam]?.remove(at: index)
    }
    
    private func insertPlayer(_ player: PlayerResponseModel, at destinationTeam: TeamSection, index: Int) {
        if playersDictionary[destinationTeam]?.isEmpty == false {
            playersDictionary[destinationTeam]?.insert(player, at: index)
        } else {
            playersDictionary[destinationTeam] = [player]
        }
    }
}

// MARK: - GatherDelegate
extension ConfirmPlayersInteractor: GatherDelegate {
    func didEndGather() {
        delegate?.didEndGather()
    }
}

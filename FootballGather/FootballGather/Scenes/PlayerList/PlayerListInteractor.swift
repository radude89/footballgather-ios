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
    
    var presenter: PlayerListPresenterProtocol
    
    private let playersService: StandardNetworkService
    private var players: [PlayerResponseModel] = []
    private static let minimumPlayersToPlay = 2
    
    init(presenter: PlayerListPresenterProtocol = PlayerListPresenter(),
         playersService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.presenter = presenter
        self.playersService = playersService
    }
    
}

// MARK: - PlayerListInteractorServiceRequester
extension PlayerListInteractor: PlayerListInteractorServiceRequester {
    func fetchPlayers(request: PlayerList.FetchPlayers.Request) {
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let players):
                    self.players = players
                    let response = PlayerList.FetchPlayers.Response(players: players,
                                                                    minimumPlayersToPlay: Self.minimumPlayersToPlay)
                    self.presenter.presentFetchedPlayers(response: response)
                    
                case .failure(let error):
                    let errorResponse = PlayerList.ErrorResponse(error: .serviceFailed(error.localizedDescription))
                    self.presenter.presentError(response: errorResponse)
                }
            }
        }
    }
    
    func deletePlayer(request: PlayerList.DeletePlayer.Request) {
        let index = request.index
        let player = players[index]
        var service = playersService
        
        service.delete(withID: ResourceID.integer(player.id)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(_):
                    self.players.remove(at: index)
                    
                    let response = PlayerList.DeletePlayer.Response(index: index)
                    self.presenter.playerWasDeleted(response: response)
                    
                case .failure(let error):
                    let errorResponse = PlayerList.ErrorResponse(error: .serviceFailed(error.localizedDescription))
                    self.presenter.presentError(response: errorResponse)
                }
            }
        }
    }
}
    
// MARK: - PlayerListInteractorActionable
extension PlayerListInteractor: PlayerListInteractorActionable {
    func requestToDeletePlayer(request: PlayerList.DeletePlayer.Request) {
        let response = PlayerList.DeletePlayer.Response(index: request.index)
        presenter.presentDeleteConfirmationAlert(response: response)
    }
    
    func selectPlayers(request: PlayerList.SelectPlayers.Request) {
        presenter.presentViewForSelection()
    }
    
    func confirmOrAddPlayers(request: PlayerList.ConfirmOrAddPlayers.Request) {
        let response = PlayerList.ConfirmOrAddPlayers.Response(teamPlayersDictionary: [.bench: players],
                                                               addDelegate: self,
                                                               confirmDelegate: self)
        presenter.confirmOrAddPlayers(response: response)
    }
}

// MARK: - Table Delegate
extension PlayerListInteractor: PlayerListInteractorTableDelegate {
    func canEditRow(request: PlayerList.CanEdit.Request) -> Bool {
        let response = PlayerList.CanEdit.Response()
        return presenter.canEditRow(response: response)
    }
    
    func selectRow(request: PlayerList.SelectPlayer.Request) {
        guard !players.isEmpty else {
            return
        }
        
        let response = PlayerList.SelectPlayer.Response(index: request.index,
                                                        player: players[request.index],
                                                        detailDelegate: self)
        presenter.selectPlayer(response: response)
    }
}

// MARK: - PlayerDetailDelegate
extension PlayerListInteractor: PlayerDetailDelegate {
    func didUpdate(player: PlayerResponseModel) {
        guard let index = players.firstIndex(of: player) else {
            return
        }
        
        players[index] = player
        
        let response = PlayerList.FetchPlayers.Response(players: players,
                                                        minimumPlayersToPlay: Self.minimumPlayersToPlay)
        presenter.updatePlayers(response: response)
    }
}

// MARK: - AddDelegate
extension PlayerListInteractor: PlayerAddDelegate {
    func didAddPlayer() {
        fetchPlayers(request: PlayerList.FetchPlayers.Request())
    }
}

// MARK: - ConfirmDelegate
extension PlayerListInteractor: ConfirmPlayersDelegate {
    func didEndGather() {
        let response = PlayerList.ReloadViewState.Response(viewState: .list)
        presenter.reloadViewState(response: response)
    }
}

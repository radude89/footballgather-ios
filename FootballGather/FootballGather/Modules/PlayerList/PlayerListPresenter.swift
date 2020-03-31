//
//  PlayerListPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerListPresenterProtocol
protocol PlayerListPresenterProtocol: AnyObject {
    var title: String { get }
    var barButtonItemTitle: String { get }
    var barButtonItemIsEnabled: Bool { get }
    var actionButtonIsEnabled: Bool { get }
    var actionButtonTitle: String { get }
    var playersCollectionIsEmpty: Bool { get }
    var numberOfRows: Int { get }
    var isInListViewMode: Bool { get }
    var playersCanPlay: Bool { get }
    var selectedPlayersTitle: String { get }
    var indexPathForDeletion: IndexPath? { get set }
    var playersDictionary: [TeamSection: [PlayerResponseModel]] { get }
    
    func toggleViewState()
    func loadPlayers()
    func performPlayerDeleteRequest()
    func cancelPlayerDeletion()
    func deleteLocallyPlayer(at indexPath: IndexPath)
    func clearSelectedPlayerIfNeeded(at indexPath: IndexPath)
    func playerNameDescription(at indexPath: IndexPath) -> String
    func playerPositionDescription(at indexPath: IndexPath) -> String
    func playerSkillDescription(at indexPath: IndexPath) -> String
    func playerIsSelected(at indexPath: IndexPath) -> Bool
    func selectPlayerForDisplayingDetails(at indexPath: IndexPath) -> PlayerResponseModel
    func selectPlayer(at indexPath: IndexPath)
    func updateSelectedPlayers(isSelected: Bool, at indexPath: IndexPath)
    func index(of player: PlayerResponseModel) -> Int?
    func didEdit(player: PlayerResponseModel)
}

// MARK: - PlayerListPresenter
final class PlayerListPresenter: PlayerListPresenterProtocol {
    
    // MARK: - Properties
    private weak var view: PlayerListViewProtocol?
    private let playersService: StandardNetworkService
    private var players: [PlayerResponseModel]
    private var viewState: PlayerListViewState
    private var viewStateDetails: PlayerListViewStateDetails {
        return PlayerListViewStateDetailsFactory.makeViewStateDetails(from: viewState)
    }
    
    private(set) var selectedPlayersDictionary: [Int: PlayerResponseModel] = [:]
    
    var indexPathForDeletion: IndexPath?
    
    // MARK: - Public API
    init(view: PlayerListViewProtocol? = nil,
         playersService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true),
         players: [PlayerResponseModel] = [],
         viewState: PlayerListViewState = .list) {
        self.view = view
        self.playersService = playersService
        self.players = players
        self.viewState = viewState
    }
    
    var title: String {
        return "Players"
    }
    
    var barButtonItemTitle: String {
        return viewStateDetails.barButtonItemTitle
    }
    
    var barButtonItemIsEnabled: Bool {
        return !playersCollectionIsEmpty
    }
    
    var actionButtonIsEnabled: Bool {
        if viewState == .selection {
            return playersCanPlay
        }
        
        return true
    }
    
    var actionButtonTitle: String {
        return viewStateDetails.actionButtonTitle
    }
    
    var playersCollectionIsEmpty: Bool {
        return players.isEmpty
    }
    
    func toggleViewState() {
        viewState.toggle()
    }
    
    // MARK: - Fetch players
    func loadPlayers() {
        DispatchQueue.main.async {
            self.view?.setViewInteraction(false)
        }
        
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            DispatchQueue.main.async {
                self?.view?.setViewInteraction(true)
                
                switch result {
                case .failure(let error):
                    self?.view?.handleError(title: "Error", message: String(describing: error))
                    
                case .success(let players):
                    self?.players = players
                    self?.view?.handleLoadPlayersSuccessfulResponse()
                }
            }
        }
    }
    
    // MARK: - Delete player
    func performPlayerDeleteRequest() {
        guard let indexPath = indexPathForDeletion else { return }
        
        view?.showLoadingView()
        
        requestDeletePlayer(at: indexPath) { [weak self] result in
            if result {
                self?.view?.handlePlayerDeletion(forRowAt: indexPath)
            }
        }
    }
    
    func cancelPlayerDeletion() {
        indexPathForDeletion = nil
    }
    
    private func requestDeletePlayer(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let player = players[indexPath.row]
        var service = playersService
        
        service.delete(withID: ResourceID.integer(player.id)) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingView()
                
                switch result {
                case .failure(let error):
                    self?.view?.handleError(title: "Error", message: String(describing: error))
                    completion(false)

                case .success(_):
                    completion(true)
                }
            }
        }
    }
    
    func deleteLocallyPlayer(at indexPath: IndexPath) {
        players.remove(at: indexPath.row)
    }
    
    // MARK: - TableView Methods
    var numberOfRows: Int {
        return players.count
    }
    
    var isInListViewMode: Bool {
        return viewState == .list
    }
    
    func clearSelectedPlayerIfNeeded(at indexPath: IndexPath) {
        if viewState == .list {
            selectedPlayersDictionary[indexPath.row] = nil
        }
    }
    
    func playerNameDescription(at indexPath: IndexPath) -> String {
        return players[indexPath.row].name
    }
    
    func playerPositionDescription(at indexPath: IndexPath) -> String {
        let player = players[indexPath.row]
        
        if let position = player.preferredPosition {
            return "Position: \(position.rawValue)"
        }
        
        return "Position: -"
    }
    
    func playerSkillDescription(at indexPath: IndexPath) -> String {
        let player = players[indexPath.row]
        
        if let skill = player.skill {
            return "Skill: \(skill.rawValue)"
        }
        
        return "Skill: -"
    }
    
    func playerIsSelected(at indexPath: IndexPath) -> Bool {
        return selectedPlayersDictionary[indexPath.row] != nil
    }
    
    func selectPlayerForDisplayingDetails(at indexPath: IndexPath) -> PlayerResponseModel {
        return players[indexPath.row]
    }
    
    func selectPlayer(at indexPath: IndexPath) {
        selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
    }
    
    var selectedPlayersTitle: String {
        let selectedPlayersCount = selectedPlayersDictionary.values.count
        return selectedPlayersCount > 0 ? "\(selectedPlayersCount) selected" : "Players"
    }
    
    func updateSelectedPlayers(isSelected: Bool, at indexPath: IndexPath) {
        if isSelected {
            selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
        } else {
            selectedPlayersDictionary[indexPath.row] = nil
        }
    }
    
    private let minimumPlayersToPlay = 2
    
    var playersCanPlay: Bool {
        return selectedPlayersDictionary.values.count >= minimumPlayersToPlay
    }
    
    var playersDictionary: [TeamSection: [PlayerResponseModel]] {
        var playersDictionary: [TeamSection: [PlayerResponseModel]] = [:]
        playersDictionary[.bench] = Array(selectedPlayersDictionary.values)

        return playersDictionary
    }
    
    func index(of player: PlayerResponseModel) -> Int? {
        return players.firstIndex(of: player)
    }
    
    func didEdit(player: PlayerResponseModel) {
        guard let index = index(of: player) else { return }
        
        players[index] = player
    }
    
}

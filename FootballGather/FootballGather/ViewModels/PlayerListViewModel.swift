//
//  PlayerListViewModel.swift
//  FootballGather
//
//  Created by Radu Dan on 22/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerListViewModelDelegate
protocol PlayerListViewModelDelegate: AnyObject {
    func viewStateDidChange()
}

// MARK: - PlayerListViewModel
final class PlayerListViewModel {
    
    // MARK: - Properties
    weak var delegate: PlayerListViewModelDelegate?
    
    private let playersService: StandardNetworkService
    private var players: [PlayerResponseModel]
    private var viewState: ViewState
    private var viewStateDetails: LoginViewStateDetails {
        return ViewStateDetailsFactory.makeViewStateDetails(from: viewState)
    }
    
    private(set) var selectedPlayersDictionary: [Int: PlayerResponseModel] = [:]
    private(set) var selectedPlayerForDetails: PlayerResponseModel?
    
    // MARK: - Public API
    init(playersService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true),
         players: [PlayerResponseModel] = [],
         viewState: ViewState = .list) {
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
    
    var actionButtonIsEnabled: Bool {
        return viewStateDetails.actionButtonIsEnabled
    }
    
    var actionButtonTitle: String {
        return viewStateDetails.actionButtonTitle
    }
    
    var segueIdentifier: String {
        return viewStateDetails.segueIdentifier
    }
    
    var playersCollectionIsEmpty: Bool {
        return players.isEmpty
    }
    
    func toggleViewState() {
        viewState.toggle()
    }
    
    func fetchPlayers(completion: @escaping (Error?) -> ()) {
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            switch result {
            case .failure(let error):
                completion(error)
                
            case .success(let players):
                self?.players = players
                completion(nil)
            }
        }
    }
    
    func requestDeletePlayer(at indexPath: IndexPath, completion: @escaping (Error?) -> Void) {
        let player = players[indexPath.row]
        var service = playersService
        
        service.delete(withID: ResourceID.integer(player.id)) { result in
            switch result {
            case .failure(let error):
                completion(error)
                
            case .success(_):
                completion(nil)
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
    
    func clearSelectedPlayerIfNeeded(at indexPath: IndexPath) {
        if viewState == .list {
            selectedPlayersDictionary[indexPath.row] = nil
        }
    }
    
    func didEdit(player: PlayerResponseModel) {
        guard let index = index(of: player) else { return }
        
        players[index] = player
    }
    
    func index(of player: PlayerResponseModel) -> Int? {
        return players.firstIndex(of: player)
    }

    var isInListViewMode: Bool {
        return viewState == .list
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
    
    func selectPlayer(at indexPath: IndexPath) {
        selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
    }
    
    func selectPlayerForDisplayingDetails(at indexPath: IndexPath) {
        selectedPlayerForDetails = players[indexPath.row]
    }
    
    func updateSelectedPlayers(isSelected: Bool, at indexPath: IndexPath) {
        if isSelected {
            selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
        } else {
            selectedPlayersDictionary[indexPath.row] = nil
        }
    }
    
    var selectedPlayersTitle: String {
        let selectedPlayersCount = selectedPlayersDictionary.values.count
        return selectedPlayersCount > 0 ? "\(selectedPlayersCount) selected" : "Players"
    }
    
    private let minimumPlayersToPlay = 2
    
    var playersCanPlay: Bool {
        return selectedPlayersDictionary.values.count >= minimumPlayersToPlay
    }
    
}

// MARK: - Models
protocol LoginViewStateDetails {
    var barButtonItemTitle: String { get }
    var actionButtonIsEnabled: Bool { get }
    var actionButtonTitle: String { get }
    var segueIdentifier: String { get }
}

extension PlayerListViewModel {
    enum ViewState {
        case list
        case selection
        
        mutating func toggle() {
            self = self == .list ? .selection : .list
        }
    }
}

fileprivate extension PlayerListViewModel {
    
    struct ListViewStateDetails: LoginViewStateDetails {
        var barButtonItemTitle: String {
            return "Select"
        }
        
        var actionButtonIsEnabled: Bool {
            return false
        }
        
        var segueIdentifier: String {
            return SegueIdentifier.addPlayer.rawValue
        }
        
        var actionButtonTitle: String {
            return "Add player"
        }
    }

    struct SelectionViewStateDetails: LoginViewStateDetails {
        var barButtonItemTitle: String {
            return "Cancel"
        }
        
        var actionButtonIsEnabled: Bool {
            return true
        }
        
        var segueIdentifier: String {
            return SegueIdentifier.confirmPlayers.rawValue
        }
        
        var actionButtonTitle: String {
            return "Confirm players"
        }
    }

    enum ViewStateDetailsFactory {
        static func makeViewStateDetails(from viewState: ViewState) -> LoginViewStateDetails {
            switch viewState {
            case .list:
                return ListViewStateDetails()
                
            case .selection:
                return SelectionViewStateDetails()
            }
        }
    }
}

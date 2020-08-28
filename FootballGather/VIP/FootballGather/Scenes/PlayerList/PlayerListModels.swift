//
//  PlayerListModels.swift
//  FootballGather
//
//  Created by Radu Dan on 02/06/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum PlayerList {
    
    // MARK: - Fetch
    enum FetchPlayers {
        struct Request {}
        
        struct Response {
            let players: [PlayerResponseModel]
            let minimumPlayersToPlay: Int
        }
        
        struct ViewModel {
            struct DisplayedPlayer {
                let name: String
                let positionDescription: String?
                let skillDescription: String?
                var isSelected: Bool
            }
            
            var displayedPlayers: [DisplayedPlayer]
        }
    }

    // MARK: - Select players
    enum SelectPlayers {
        struct Request {}
        
        struct ViewModel: ReloadViewModel {
            let title: String
            let barButtonItemTitle: String
            let actionButtonTitle: String
            let actionButtonIsEnabled: Bool
            let isInListViewMode: Bool
        }
    }
        
    // MARK: - ConfirmAdd
    enum ConfirmOrAddPlayers {
        struct Request {}
        
        struct Response {
            let teamPlayersDictionary: [TeamSection: [PlayerResponseModel]]
            let addDelegate: PlayerAddDelegate
            let confirmDelegate: ConfirmPlayersDelegate
        }
    }
    
    // MARK: - Select Player
    enum SelectPlayer {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
            let player: PlayerResponseModel
            let detailDelegate: PlayerDetailDelegate
        }
        
        struct ViewModel {
            let index: Int
            let title: String
            let actionButtonIsEnabled: Bool
        }
    }
    
    // MARK: - Delete Player
    enum DeletePlayer {
        struct Request {
            let index: Int
        }
        
        struct Response {
            let index: Int
        }
    }
    
    // MARK: - Can Edit
    enum CanEdit {
        struct Request {}
        struct Response {}
    }
    
    // MARK: - ReloadViewState
    enum ReloadViewState {
        struct Response {
            let viewState: PlayerListViewState
        }
        
        struct ViewModel: ReloadViewModel {
            let title: String
            let barButtonItemTitle: String
            let actionButtonTitle: String
            let actionButtonIsEnabled: Bool
            let isInListViewMode: Bool
        }
    }
    
    // MARK: - Errors
    struct ErrorResponse {
        let error: PlayerListError
    }
    
    struct ErrorViewModel {
        let errorTitle: String
        let errorMessage: String
    }
}

// MARK: - PlayerListError
enum PlayerListError: Error {
    case serviceFailed(String)
}

// MARK: - Convenience init
extension PlayerList.FetchPlayers.ViewModel.DisplayedPlayer {
    init(player: PlayerResponseModel) {
        name = player.name
        positionDescription = player.preferredPosition?.rawValue
        skillDescription = player.skill?.rawValue
        isSelected = false
    }
}

// MARK: - ReloadViewModel
protocol ReloadViewModel {
    var title: String { get }
    var barButtonItemTitle: String { get }
    var actionButtonTitle: String { get }
    var actionButtonIsEnabled: Bool { get }
    var isInListViewMode: Bool { get }
}

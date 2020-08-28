//
//  PlayerListViewStateDetails.swift
//  FootballGather
//
//  Created by Radu Dan on 05/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerListViewStateDetails
protocol PlayerListViewStateDetails {
    var barButtonItemTitle: String { get }
    var actionButtonTitle: String { get }
    var segueIdentifier: String { get }
}

// MARK: - PlayerListViewState
enum PlayerListViewState {
    case list
    case selection
    
    mutating func toggle() {
        self = self == .list ? .selection : .list
    }
}

// MARK: - List State
struct PlayerListStateDetails: PlayerListViewStateDetails {
    var barButtonItemTitle: String {
        return "Select"
    }

    var segueIdentifier: String {
        return SegueIdentifier.addPlayer.rawValue
    }
    
    var actionButtonTitle: String {
        return "Add player"
    }
}

// MARK: - Selection State
struct PlayerSelectionStateDetails: PlayerListViewStateDetails {
    var barButtonItemTitle: String {
        return "Cancel"
    }
    
    var segueIdentifier: String {
        return SegueIdentifier.confirmPlayers.rawValue
    }
    
    var actionButtonTitle: String {
        return "Confirm players"
    }
}

// MARK: - Factory
enum PlayerListViewStateDetailsFactory {
    static func makeViewStateDetails(from viewState: PlayerListViewState) -> PlayerListViewStateDetails {
        switch viewState {
        case .list:
            return PlayerListStateDetails()
            
        case .selection:
            return PlayerSelectionStateDetails()
        }
    }
}

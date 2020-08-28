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
    let barButtonItemTitle = "Select"
    let actionButtonTitle = "Add player"
}

// MARK: - Selection State
struct PlayerSelectionStateDetails: PlayerListViewStateDetails {
    let barButtonItemTitle = "Cancel"
    let actionButtonTitle = "Confirm players"
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

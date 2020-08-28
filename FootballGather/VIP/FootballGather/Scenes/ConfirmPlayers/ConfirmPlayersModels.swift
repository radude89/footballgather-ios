//
//  ConfirmPlayersModels.swift
//  FootballGather
//
//  Created by Radu Dan on 31/07/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum ConfirmPlayers {
    
    // MARK: - StartGather
    enum StartGather {
        struct Request {}
        
        struct Response {
            let gather: GatherModel
            let delegate: GatherDelegate
        }
    }
    
    // MARK: - Number of sections
    enum SectionsCount {
        struct Request {}
        struct Response {}
    }
    
    // MARK: - Number of rows
    enum RowsCount {
        struct Request {
            let section: Int
        }
        
        struct Response {
            let players: [PlayerResponseModel]
        }
    }

    // MARK: - Section title
    enum SectionTitle {
        struct Request {
            let section: Int
        }
        
        struct Response {
            let section: Int
        }
        
        struct ViewModel {
            let title: String
        }
    }
    
    // MARK: - RowDetails
    enum RowDetails {
        struct Request {
            let indexPath: IndexPath
        }
        
        struct Response {
            let player: PlayerResponseModel?
        }
        
        struct ViewModel {
            let titleLabelText: String
            let descriptionLabelText: String
        }
    }
    
    // MARK: - Move
    enum Move {
        struct Request {
            let sourceIndexPath: IndexPath
            let destinationIndexPath: IndexPath
        }
        
        struct Response {
            let hasPlayersInBothTeams: Bool
        }
        
        struct ViewModel {
            let startGatherButtonIsEnabled: Bool
        }
    }
    
    // MARK: - Errors
    struct ErrorResponse {
        let error: ConfirmPlayersError
    }
    
    struct ErrorViewModel {
        let errorTitle: String
        let errorMessage: String
    }
}

// MARK: - ConfirmPlayersError
enum ConfirmPlayersError: Error {
    case startGatherError
}

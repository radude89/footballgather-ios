//
//  PlayerDetailModels.swift
//  FootballGather
//
//  Created by Radu Dan on 23/07/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum PlayerDetail {
    
    // MARK: - Title
    enum ConfigureTitle {
        struct Request {}
        
        struct Response {
            let playerName: String
        }
        
        struct ViewModel {
            let title: String
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
            let section: Int
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
    
    // MARK: - PlayerDetails
    enum RowDetails {
        struct Request {
            let indexPath: IndexPath
        }
        
        struct Response {
            let indexPath: IndexPath
        }
        
        struct ViewModel {
            let leftLabelText: String
            let rightLabelText: String
        }
    }
    
    // MARK: - Select
    enum SelectRow {
        struct Request {
            let indexPath: IndexPath
        }
        
        struct Response {
            let playerEditable: PlayerEditable
            let delegate: PlayerEditDelegate
        }
    }
    
    // MARK: - Update
    enum Update {
        struct Request {}
        
        struct Response {
            let playerName: String
            let sections: [PlayerDetailSection]
        }
    }
}

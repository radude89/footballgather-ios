//
//  PlayerEditModels.swift
//  FootballGather
//
//  Created by Radu Dan on 27/07/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum PlayerEdit {
    
    // MARK: - Field
    enum ConfigureField {
        struct Request {}
        
        struct Response {
            let rowDetailsValue: String?
            let editableItemsAreEmpty: Bool
        }
        
        struct ViewModel {
            let placeholder: String?
            let text: String?
            let isHidden: Bool
        }
    }
    
    // MARK: - Table
    enum ConfigureTable {
        struct Request {}
        
        struct Response {
            let editableItemsAreEmpty: Bool
        }
        
        struct ViewModel {
            let tableViewIsHidden: Bool
        }
    }
    
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
    
    // MARK: - Update
    enum UpdateField {
        struct Request {
            let text: String?
        }
        
        struct Response {
            let currentRowDetailsValue: String?
            let editableFieldOption: PlayerEditableFieldOption?
            let updatedValue: String?
        }
        
        struct ViewModel: PlayerEditBarButtonViewModel {
            var barButtonIsEnabled: Bool
        }
    }
    
    enum UpdatePlayer {
        struct Request {}
    }
    
    enum UpdateSelection {
        struct Request {
            let indexPath: IndexPath
        }
        
        struct Response {
            let selectedItemIndex: Int?
            let indexPath: IndexPath
        }
        
        struct ViewModel {
            let unselectedIndexPath: IndexPath?
            let selectedIndexPath: IndexPath
        }
    }
    
    // MARK: - Done
    enum Done {
        struct Request {
            let text: String?
        }
    }
    
    // MARK: - RowsCount
    enum RowsCount {
        struct Request {}
    }
    
    // MARK: - RowDetails
    enum RowDetails {
        struct Request {
            let indexPath: IndexPath
        }
        
        struct Response {
            let indexPath: IndexPath
            let editablePlayer: PlayerEditable
            let isSelected: Bool
        }
        
        struct ViewModel {
            let title: String
            let isSelected: Bool
        }
    }
    
    // MARK: - Errors
    struct ErrorResponse {
        let error: PlayerEditError
    }
    
    struct ErrorViewModel {
        let errorTitle: String
        let errorMessage: String
    }
    
    // MARK: - SelectRow
    enum SelectRow {
        struct Request {
            let indexPath: IndexPath
        }
        
        struct Response {
            let index: Int
            let editablePlayer: PlayerEditable
        }
        
        struct ViewModel: PlayerEditBarButtonViewModel {
            var barButtonIsEnabled: Bool
        }
    }
}

// MARK: - PlayerEditError
enum PlayerEditError: Error {
    case updateError
}

// MARK: - BarButton
protocol PlayerEditBarButtonViewModel {
    var barButtonIsEnabled: Bool { get set }
}

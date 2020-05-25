//
//  PlayerAddModels.swift
//  FootballGather
//
//  Created by Radu Dan on 30/07/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum PlayerAdd {
    
    // MARK: - TextDidChange
    enum TextDidChange {
        struct Request {
            let text: String?
        }
        
        struct Response {
            let textIsEmpty: Bool
        }
        
        struct ViewModel {
            let barButtonIsEnabled: Bool
        }
    }
    
    // MARK: - Done
    enum Done {
        struct Request {
            let text: String?
        }
    }
    
    // MARK: - Errors
    struct ErrorResponse {
        let error: PlayerAddError
    }
    
    struct ErrorViewModel {
        let errorTitle: String
        let errorMessage: String
    }
}

// MARK: - PlayerAddError
enum PlayerAddError: Error {
    case addError
}

//
//  GatherModels.swift
//  FootballGather
//
//  Created by Radu Dan on 04/08/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

enum Gather {
    
    // MARK: - Select
    enum SelectRows {
        struct Request {}
        
        struct Response {
            let minutes: Int?
            let seconds: Int?
            let minutesComponent: Int?
            let secondsComponent: Int?
            
            init(minutes: Int? = nil,
                 seconds: Int? = nil,
                 minutesComponent: Int? = nil,
                 secondsComponent: Int? = nil) {
                self.minutes = minutes
                self.seconds = seconds
                self.minutesComponent = minutesComponent
                self.secondsComponent = secondsComponent
            }
        }
        
        struct ViewModel {
            let pickerRow: Int
            let pickerComponent: Int
            let animated = false
        }
    }
    
    // MARK: - Format Time
    enum FormatTime {
        struct Request {}
        
        struct Response {
            let selectedTime: GatherTime
        }
        struct ViewModel {
            let formattedTime: String
        }
    }
    
    // MARK: - Action Button
    enum ConfigureActionButton {
        struct Request {}
        
        struct Response {
            let timerState: GatherTimeHandler.State
        }
        
        struct ViewModel {
            let title: String
        }
    }
    
    // MARK: - End Gather
    enum EndGather {
        struct Request {
            let winnerTeamDescription: String?
            let scoreDescription: String?
            
            init(winnerTeamDescription: String? = nil,
                 scoreDescription: String? = nil) {
                self.winnerTeamDescription = winnerTeamDescription
                self.scoreDescription = scoreDescription
            }
        }
        
        struct Response {}
    }
    
    // MARK: - Set Timer
    enum SetTimer {
        struct Request {}
        struct Response {}
        
        struct ViewModel {
            let timerViewIsVisible: Bool
        }
    }
    
    // MARK: - Cancel Timer
    enum CancelTimer {
        struct Request {}
        
        struct Response {
            let selectedTime: GatherTime
            let timerState: GatherTimeHandler.State
        }
        
        struct ViewModel {
            let formattedTime: String
            let actionTitle: String
            let timerViewIsVisible: Bool
        }
    }
    
    // MARK: - Action Timer
    enum ActionTimer {
        struct Request {}
        
        struct Response {
            let timerState: GatherTimeHandler.State
        }
    }
    
    // MARK: - Timer Did Cancel
    enum TimerDidCancel {
        struct Request {}
    }
    
    // MARK: - Timer Did Finish
    enum TimerDidFinish {
        struct Request {
            let selectedMinutes: Int
            let selectedSeconds: Int
        }
        
        struct Response {
            let selectedTime: GatherTime
            let timerState: GatherTimeHandler.State
        }
        
        struct ViewModel {
            let formattedTime: String
            let actionTitle: String
            let timerViewIsVisible: Bool
        }
    }
    
    // MARK: - Number of sections
    enum SectionsCount {
        struct Request {}
        
        struct Response {
            let teamSections: [TeamSection]
        }
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
    
    // MARK: - RowDetails
    enum RowDetails {
        struct Request {
            let indexPath: IndexPath
        }
        
        struct Response {
            let player: PlayerResponseModel
        }
        
        struct ViewModel {
            let titleLabelText: String
            let descriptionLabelText: String
        }
    }
    
    // MARK: - Section title
    enum SectionTitle {
        struct Request {
            let section: Int
        }
        
        struct Response {
            let teamSection: TeamSection
        }
        
        struct ViewModel {
            let title: String
        }
    }
    
    // MARK: - PickerComponents
    enum PickerComponents {
        struct Request {}
        
        struct Response {
            let timeComponents: [GatherTimeHandler.Component]
        }
    }
    
    // MARK: - PickerRows
    enum PickerRows {
        struct Request {
            let component: Int
        }
        
        struct Response {
            let timeComponent: GatherTimeHandler.Component
        }
    }
    
    // MARK: - PickerTitle
    enum PickerRowTitle {
        struct Request {
            let row: Int
            let component: Int
        }
        
        struct Response {
            let timeComponent: GatherTimeHandler.Component
            let row: Int
        }
        
        struct ViewModel {
            let title: String
        }
    }
    
    // MARK: - UpdateValue
    enum UpdateValue {
        struct Request {
            let teamSection: TeamSection
            let newValue: Double
        }
        
        struct Response {
            let teamSection: TeamSection
            let newValue: Double
        }
        
        struct ViewModel {
            let teamAText: String?
            let teamBText: String?
            
            init(teamAText: String? = nil, teamBText: String? = nil) {
                self.teamAText = teamAText
                self.teamBText = teamBText
            }
        }
    }
    
    // MARK: - Errors
    struct ErrorResponse {
        let error: EndGatherError
    }
    
    struct ErrorViewModel {
        let errorTitle: String
        let errorMessage: String
    }
}

// MARK: - EndGatherError
enum EndGatherError: Error {
    case endGatherError
}

//
//  GatherViewModel.swift
//  FootballGather
//
//  Created by Radu Dan on 27/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - GatherViewModelDelegate
protocol GatherViewModelDelegate: AnyObject {
    func didUpdateGatherTime()
}

// MARK: - GatherViewModel
final class GatherViewModel {
    
    // MARK: - Properties
    private let model: GatherModel
    private var timeHandler: GatherTimeHandler
    private var updateGatherService: StandardNetworkService
    
    weak var delegate: GatherViewModelDelegate?
    
    // MARK: - Public API
    init(gatherModel: GatherModel,
         timeHandler: GatherTimeHandler = GatherTimeHandler(),
         updateGatherService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)) {
        self.model = gatherModel
        self.timeHandler = timeHandler
        self.updateGatherService = updateGatherService
    }

    // MARK: - UI decorators
    var title: String { "Gather in progress" }
    
    var formattedCountdownTimerLabelText: String { "\(formattedMinutesDescription):\(formattedSecondsDescription)" }
    
    var formattedActionTitleText: String {
        switch timeHandler.state {
        case .paused:
            return "Resume"
            
        case .running:
            return "Stop"
            
        case .stopped:
            return "Start"
        }
    }
    
    private var formattedMinutesDescription: String {
        let selectedTime = timeHandler.selectedTime
        return selectedTime.minutes < 10 ? "0\(selectedTime.minutes)" : "\(selectedTime.minutes)"
    }
    
    private var formattedSecondsDescription: String {
        let selectedTime = timeHandler.selectedTime
        return selectedTime.seconds < 10 ? "0\(selectedTime.seconds)" : "\(selectedTime.seconds)"
    }
    
    // MARK: - Timer interaction
    func toggleTimer() {
        guard selectedTimeIsValid else { return }
        
        timeHandler.toggleTimer(target: self, selector: #selector(updateTimer(_:)))
    }
    
    func stopTimer() {
        timeHandler.stopTimer()
    }
    
    func resetTimer() {
        timeHandler.resetSelectedTime()
    }
    
    private var selectedTimeIsValid: Bool { timeHandler.selectedTime.minutes > 0 || timeHandler.selectedTime.seconds > 0 }
    
    @objc private func updateTimer(_ timer: Timer) {
        timeHandler.decrementTime()
        delegate?.didUpdateGatherTime()
    }
    
    var minutesComponent: Int { GatherTimeHandler.Component.minutes.rawValue }
    var selectedMinutes: Int { timeHandler.selectedTime.minutes }
    
    var secondsComponent: Int { GatherTimeHandler.Component.seconds.rawValue }
    var selectedSeconds: Int { timeHandler.selectedTime.seconds }
    
    func setTimerMinutes(_ minutes: Int) {
        timeHandler.selectedTime.minutes = minutes
    }
    
    func setTimerSeconds(_ seconds: Int) {
        timeHandler.selectedTime.seconds = seconds
    }
    
    // MARK: - TableView methods
    var numberOfSections: Int { TeamSection.allCases.filter { $0 != .bench }.count }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        if section == 0 {
            return TeamSection.teamA.headerTitle
        }
            
        return TeamSection.teamB.headerTitle
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        let team: TeamSection = makeTeamSection(from: section)
        return playerTeams(forTeamSection: team).count
    }
    
    private func makeTeamSection(from sectionIndex: Int) -> TeamSection {
        if sectionIndex == 0 {
            return .teamA
        }
        
        return .teamB
    }
    
    private func playerTeams(forTeamSection teamSection: TeamSection) -> [PlayerTeamModel] {
        model.players.filter { $0.team == teamSection }
    }
    
    // MARK: - PickerView methods
    func rowDescription(at indexPath: IndexPath) -> (title: String, details: String?) {
        let team: TeamSection = makeTeamSection(from: indexPath.section)
        let playerTeams = self.playerTeams(forTeamSection: team)
        let player = playerTeams[indexPath.row].player
        
        return (title: player.name, details: player.preferredPosition?.acronym)
    }
    
    func formatStepperValue(_ value: Double) -> String { "\(Int(value))" }
    
    func shouldUpdateTeamALabel(section: TeamSection) -> Bool { section == .teamA }
    
    func shouldUpdateTeamBLabel(section: TeamSection) -> Bool { section == .teamB }
    
    var numberOfPickerComponents: Int { GatherTimeHandler.Component.allCases.count }
    
    func numberOfRowsInPickerComponent(_ component: Int) -> Int {
        if let _ = GatherTimeHandler.Component(rawValue: component) {
            return 60
        }
        
        return 0
    }
    
    func titleForPickerRow(_ row: Int, forComponent component: Int) -> String? {
        guard let gatherCounterComponent = GatherTimeHandler.Component(rawValue: component) else {
            return nil
        }
        
        switch gatherCounterComponent {
        case .minutes:
            return "\(row) min"
        case .seconds:
            return "\(row) sec"
        }
    }
    
    // MARK: - Service
    func endGather(teamAScoreLabelText: String, teamBScoreLabelText: String, completion: @escaping (Bool) -> ()) {
        let score = scoreFormattedDescription(teamAScoreLabelText: teamAScoreLabelText, teamBScoreLabelText: teamBScoreLabelText)
        let winnerTeam = winnerTeamFormattedDescription(teamAScoreLabelText: teamAScoreLabelText, teamBScoreLabelText: teamBScoreLabelText)
        let gatherCreateModel = GatherCreateModel(score: score, winnerTeam: winnerTeam)
        
        requestUpdateGather(gatherCreateModel, completion: completion)
    }
    
    private func scoreFormattedDescription(teamAScoreLabelText: String, teamBScoreLabelText: String) -> String {
        return "\(teamAScoreLabelText)-\(teamBScoreLabelText)"
    }
    
    private func winnerTeamFormattedDescription(teamAScoreLabelText: String, teamBScoreLabelText: String) -> String {
        guard let scoreTeamA = Int(teamAScoreLabelText),
            let scoreTeamB = Int(teamBScoreLabelText) else {
                return "None"
        }
        
        var winnerTeam: String = "None"
        if scoreTeamA > scoreTeamB {
            winnerTeam = "Team A"
        } else if scoreTeamA < scoreTeamB {
            winnerTeam = "Team B"
        }
        
        return winnerTeam
    }
    
    private func requestUpdateGather(_ gather: GatherCreateModel, completion: @escaping (Bool) -> Void) {
        updateGatherService.update(gather, resourceID: ResourceID.uuid(model.gatherUUID)) { result in
            if case .success(let updated) = result {
                completion(updated)
            } else {
                completion(false)
            }
        }
    }
    
}

//
//  GatherInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 28/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - GatherInteractor
final class GatherInteractor: GatherInteractable {
    
    weak var presenter: GatherPresenterServiceHandler?
    
    private let gather: GatherModel
    private var timeHandler: GatherTimeHandler
    private var updateGatherService: StandardNetworkService
    
    private(set) var timeComponents: [GatherTimeHandler.Component]
    
    init(gather: GatherModel,
         timeHandler: GatherTimeHandler = GatherTimeHandler(),
         updateGatherService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true),
         timeComponents: [GatherTimeHandler.Component] = [.minutes, .seconds]) {
        self.gather = gather
        self.timeHandler = timeHandler
        self.updateGatherService = updateGatherService
        self.timeComponents = timeComponents
    }
    
}

// MARK: - Service Handler
extension GatherInteractor: GatherInteractorServiceHander {
    var teamSections: [TeamSection] {
        [.teamA, .teamB]
    }
    
    func teamSection(at index: Int) -> TeamSection {
        teamSections[index]
    }
    
    func players(in team: TeamSection) -> [PlayerResponseModel] {
        gather.players.filter { $0.team == team }.compactMap { $0.player }
    }
    
    func endGather(score: String, winnerTeam: String) {
        let gatherCreateModel = GatherCreateModel(score: score, winnerTeam: winnerTeam)
        
        updateGatherService.update(gatherCreateModel, resourceID: ResourceID.uuid(gather.gatherUUID)) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let updated) = result, updated {
                    self?.presenter?.gatherEnded()
                } else {
                    self?.presenter?.serviceFailedToEndGather()
                }
            }
        }
    }
}

// MARK: - Time Handler
extension GatherInteractor: GatherInteractorTimeHandler {
    var minutesComponent: GatherTimeHandler.Component? {
        timeComponents.first { $0 == .minutes }
    }
    
    var secondsComponent: GatherTimeHandler.Component? {
        timeComponents.first { $0 == .seconds }
    }
    
    var selectedTime: GatherTime {
        timeHandler.selectedTime
    }
    
    var timerState: GatherTimeHandler.State {
        timeHandler.state
    }
    
    func timeComponent(at index: Int) -> GatherTimeHandler.Component {
        timeComponents[index]
    }
    
    func stopTimer() {
        timeHandler.stopTimer()
    }
    
    func resetTimer() {
        timeHandler.resetSelectedTime()
    }
    
    func toggleTimer() {
        guard timeIsValid else {
            return
        }
        
        timeHandler.toggleTimer(target: self, selector: #selector(updateTimer(_:)))
    }
    
    private var timeIsValid: Bool {
        timeHandler.selectedTime.minutes > 0 || timeHandler.selectedTime.seconds > 0
    }
    
    @objc private func updateTimer(_ timer: Timer) {
        timeHandler.decrementTime()
        presenter?.timerDecremented()
    }
    
    func updateTime(_ gatherTime: GatherTime) {
        timeHandler.selectedTime = gatherTime
    }
}

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
    
    var presenter: GatherPresenterProtocol
    var delegate: GatherDelegate?
    
    private let gather: GatherModel
    private var timeHandler: GatherTimeHandler
    private var updateGatherService: StandardNetworkService
    private let timeComponents: [GatherTimeHandler.Component]
    private let teamSections: [TeamSection]
    
    init(presenter: GatherPresenterProtocol = GatherPresenter(),
         delegate: GatherDelegate? = nil,
         gather: GatherModel,
         timeHandler: GatherTimeHandler = GatherTimeHandler(),
         updateGatherService: StandardNetworkService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true),
         timeComponents: [GatherTimeHandler.Component] = [.minutes, .seconds],
         teamSections: [TeamSection] = [.teamA, .teamB]) {
        self.presenter = presenter
        self.delegate = delegate
        self.gather = gather
        self.timeHandler = timeHandler
        self.updateGatherService = updateGatherService
        self.timeComponents = timeComponents
        self.teamSections = teamSections
    }
    
}

// MARK: - Configure
extension GatherInteractor: GatherInteractorConfigurable {
    func selectRows(request: Gather.SelectRows.Request) {
        selectTime()
    }
    
    private func selectTime() {
        selectMinutes()
        selectSeconds()
    }
    
    private func selectMinutes() {
        guard let minutesComponent = minutesComponent?.rawValue else {
            return
        }
        
        let selectedMinutes = selectedTime.minutes
        
        let response = Gather.SelectRows.Response(minutes: selectedMinutes,
                                                  minutesComponent: minutesComponent)
        presenter.presentSelectedRows(response: response)
    }
    
    private func selectSeconds() {
        guard let secondsComponent = secondsComponent?.rawValue else {
            return
        }
        
        let selectedSeconds = selectedTime.seconds
        
        let response = Gather.SelectRows.Response(seconds: selectedSeconds,
                                                  secondsComponent: secondsComponent)
        presenter.presentSelectedRows(response: response)
    }
    
    func formatTime(request: Gather.FormatTime.Request) {
        let response = Gather.FormatTime.Response(selectedTime: selectedTime)
        presenter.formatTime(response: response)
    }
    
    func configureActionButton(request: Gather.ConfigureActionButton.Request) {
        let response = Gather.ConfigureActionButton.Response(timerState: timerState)
        presenter.presentActionButton(response: response)
    }
    
    private var timerState: GatherTimeHandler.State {
        timeHandler.state
    }
    
    func updateValue(request: Gather.UpdateValue.Request) {
        let response = Gather.UpdateValue.Response(teamSection: request.teamSection,
                                                   newValue: request.newValue)
        presenter.displayTeamScore(response: response)
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
    
    private var selectedTime: GatherTime {
        timeHandler.selectedTime
    }
    
    func setTimer(request: Gather.SetTimer.Request) {
        selectTime()
        
        let response = Gather.SetTimer.Response()
        presenter.presentTimerView(response: response)
    }
    
    func cancelTimer(request: Gather.CancelTimer.Request) {
        stopTimer()
        resetTimer()
        
        let response = Gather.CancelTimer.Response(selectedTime: selectedTime,
                                                   timerState: timerState)
        presenter.cancelTimer(response: response)
    }
    
    private func stopTimer() {
        timeHandler.stopTimer()
    }
    
    private func resetTimer() {
        timeHandler.resetSelectedTime()
    }
    
    func actionTimer(request: Gather.ActionTimer.Request) {
        toggleTimer()
        
        let response = Gather.ActionTimer.Response(timerState: timerState)
        presenter.presentToggledTimer(response: response)
    }
    
    private func toggleTimer() {
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
        formatTime(request: Gather.FormatTime.Request())
    }
    
    func timerDidCancel(request: Gather.TimerDidCancel.Request) {
        presenter.hideTimer()
    }
    
    func timerDidFinish(request: Gather.TimerDidFinish.Request) {
        stopTimer()
        updateTime(request: request)
        
        let response = Gather.TimerDidFinish.Response(selectedTime: selectedTime,
                                                      timerState: timerState)
        presenter.presentUpdatedTime(response: response)
    }
    
    private func updateTime(request: Gather.TimerDidFinish.Request) {
        let time = GatherTime(minutes: request.selectedMinutes,
                              seconds: request.selectedSeconds)
        updateTime(time)
    }
    
    private func updateTime(_ gatherTime: GatherTime) {
        timeHandler.selectedTime = gatherTime
    }
}

// MARK: - GatherInteractorActionable
extension GatherInteractor: GatherInteractorActionable {
    func requestToEndGather(request: Gather.EndGather.Request) {
        let response = Gather.EndGather.Response()
        presenter.presentEndGatherConfirmationAlert(response: response)
    }
    
    func endGather(request: Gather.EndGather.Request) {
        guard let winnerTeam = request.winnerTeamDescription,
            let score = request.scoreDescription else {
                return
        }
        
        let gatherCreateModel = GatherCreateModel(score: score, winnerTeam: winnerTeam)
        
        updateGatherService.update(gatherCreateModel, resourceID: ResourceID.uuid(gather.gatherUUID)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if case .success(let updated) = result, updated {
                    self.delegate?.didEndGather()
                    self.presenter.popToPlayerListView()
                } else {
                    let errorResponse = Gather.ErrorResponse(error: .endGatherError)
                    self.presenter.presentError(response: errorResponse)
                }
            }
        }
    }
}
    
// MARK: - Table Delegate
extension GatherInteractor: GatherInteractorTableDelegate {
    func numberOfSections(request: Gather.SectionsCount.Request) -> Int {
        let response = Gather.SectionsCount.Response(teamSections: teamSections)
        return presenter.numberOfSections(response: response)
    }
    
    func numberOfRowsInSection(request: Gather.RowsCount.Request) -> Int {
        let teamSection = self.teamSection(at: request.section)
        let players = self.players(in: teamSection)
        let response = Gather.RowsCount.Response(players: players)
        
        return presenter.numberOfRowsInSection(response: response)
    }
    
    private func teamSection(at index: Int) -> TeamSection {
        teamSections[index]
    }
    
    private func players(in team: TeamSection) -> [PlayerResponseModel] {
        gather.players.filter { $0.team == team }.compactMap { $0.player }
    }
    
    func rowDetails(request: Gather.RowDetails.Request) -> Gather.RowDetails.ViewModel {
        let teamSection = self.teamSection(at: request.indexPath.section)
        let players = self.players(in: teamSection)
        let player = players[request.indexPath.row]
        
        let response = Gather.RowDetails.Response(player: player)
        return presenter.rowDetails(response: response)
    }
    
    func titleForHeaderInSection(request: Gather.SectionTitle.Request) -> Gather.SectionTitle.ViewModel {
        let teamSection = self.teamSection(at: request.section)
        let response = Gather.SectionTitle.Response(teamSection: teamSection)
        return presenter.titleForHeaderInSection(response: response)
    }
}
 
// MARK: - Picker Delegate
extension GatherInteractor: GatherInteractorPickerDelegate {
    func numberOfPickerComponents(request: Gather.PickerComponents.Request) -> Int {
        let response = Gather.PickerComponents.Response(timeComponents: timeComponents)
        return presenter.numberOfPickerComponents(response: response)
    }
    
    func numberOfRowsInPickerComponent(request: Gather.PickerRows.Request) -> Int {
        let timeComponent = self.timeComponent(at: request.component)
        let response = Gather.PickerRows.Response(timeComponent: timeComponent)
        return presenter.numberOfPickerRows(response: response)
    }
    
    private func timeComponent(at index: Int) -> GatherTimeHandler.Component {
        timeComponents[index]
    }
    
    func titleForPickerRow(request: Gather.PickerRowTitle.Request) -> Gather.PickerRowTitle.ViewModel {
        let timeComponent = self.timeComponent(at: request.component)
        let response = Gather.PickerRowTitle.Response(timeComponent: timeComponent,
                                                      row: request.row)
        return presenter.titleForRow(response: response)
    }
}

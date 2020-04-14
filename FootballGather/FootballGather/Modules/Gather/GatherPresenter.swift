//
//  GatherPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - GatherPresenter
final class GatherPresenter: GatherPresentable {
    
    // MARK: - Properties
    weak var view: GatherViewProtocol?
    var interactor: GatherInteractorProtocol
    var router: GatherRouterProtocol
    weak var delegate: GatherDelegate?
    
    // MARK: - Init
    init(view: GatherViewProtocol? = nil,
         interactor: GatherInteractorProtocol,
         router: GatherRouterProtocol = GatherRouter(),
         delegate: GatherDelegate? = nil) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }
    
}

// MARK: - View Configuration
extension GatherPresenter: GatherPresenterViewConfiguration {
    func viewDidLoad() {
        view?.configureTitle("Gather in progress")
        view?.setTimerViewVisibility(isHidden: true)
        selectRows()
        view?.setTimerLabelText(formattedTime)
        view?.setActionButtonTitle(actionButtonTitle)
        view?.setupScoreStepper()
        view?.reloadData()
    }
    
    private func selectRows() {
        selectMinutes()
        selectSeconds()
    }
    
    private func selectMinutes() {
        guard let minutesComponent = interactor.minutesComponent?.rawValue else {
            return
        }
        
        let selectedMinutes = interactor.selectedTime.minutes
        
        view?.selectRow(selectedMinutes, inComponent: minutesComponent, animated: false)
    }
    
    private func selectSeconds() {
        guard let secondsComponent = interactor.secondsComponent?.rawValue else {
            return
        }
        
        let selectedSeconds = interactor.selectedTime.seconds
        
        view?.selectRow(selectedSeconds, inComponent: secondsComponent, animated: false)
    }
    
    private var actionButtonTitle: String {
        switch interactor.timerState {
        case .paused:
            return "Resume"
            
        case .running:
            return "Pause"
            
        case .stopped:
            return "Start"
        }
    }
}

// MARK: - Table Data Source
extension GatherPresenter: GatherTableDataSource {
    var numberOfSections: Int {
        interactor.teamSections.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        let teamSection = interactor.teamSection(at: section)
        return interactor.players(in: teamSection).count
    }
    
    func rowTitle(at indexPath: IndexPath) -> String {
        let teamSection = interactor.teamSection(at: indexPath.section)
        let players = interactor.players(in: teamSection)
        let player = players[indexPath.row]
        
        return player.name
    }
    
    func rowDescription(at indexPath: IndexPath) -> String? {
        let teamSection = interactor.teamSection(at: indexPath.section)
        let players = interactor.players(in: teamSection)
        let player = players[indexPath.row]
        
        return player.preferredPosition?.acronym
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        interactor.teamSection(at: section).headerTitle
    }
}

// MARK: - Picker Data Source
extension GatherPresenter: GatherPickerDataSource {
    var numberOfPickerComponents: Int {
        interactor.timeComponents.count
    }
    
    func numberOfRowsInPickerComponent(_ component: Int) -> Int {
        interactor.timeComponent(at: component).numberOfSteps
    }
    
    func titleForPickerRow(_ row: Int, forComponent component: Int) -> String {
        let timeComponent = interactor.timeComponent(at: component)
        return "\(row) \(timeComponent.short)"
    }
}

// MARK: - Stepper Handler
extension GatherPresenter: GatherStepperHandler {
    func updateValue(for team: TeamSection, with newValue: Double) {
        if team == .teamA {
            view?.setTeamALabelText("\(Int(newValue))")
        } else {
            view?.setTeamBLabelText("\(Int(newValue))")
        }
    }
}

// MARK: - Actions
extension GatherPresenter: GatherPresenterActionable {
    func requestToEndGather() {
        view?.displayConfirmationAlert()
    }
    
    func setTimer() {
        selectRows()
        view?.setTimerViewVisibility(isHidden: false)
    }
    
    func cancelTimer() {
        interactor.stopTimer()
        interactor.resetTimer()
        view?.setTimerLabelText(formattedTime)
        view?.setActionButtonTitle(actionButtonTitle)
        view?.setTimerViewVisibility(isHidden: true)
    }
    
    private var formattedTime: String {
        let minutes = formatTime(interactor.selectedTime.minutes)
        let seconds = formatTime(interactor.selectedTime.seconds)
        
        return "\(minutes):\(seconds)"
    }
    
    private func formatTime(_ time: Int) -> String {
        time < 10 ? "0\(time)" : "\(time)"
    }
    
    func actionTimer() {
        interactor.toggleTimer()
        view?.setActionButtonTitle(actionButtonTitle)
    }
    
    func timerCancel() {
        view?.setTimerViewVisibility(isHidden: true)
    }
    
    func timerDone() {
        interactor.stopTimer()
        
        updateTime()

        view?.setTimerLabelText(formattedTime)
        view?.setActionButtonTitle(actionButtonTitle)
        view?.setTimerViewVisibility(isHidden: true)
    }
    
    private func updateTime() {
        guard let minutesComponent = interactor.minutesComponent?.rawValue,
            let selectedMinutes = view?.selectedRow(in: minutesComponent),
            let secondsComponent = interactor.secondsComponent?.rawValue,
            let selectedSeconds = view?.selectedRow(in: secondsComponent) else {
                return
        }
        
        let time = GatherTime(minutes: selectedMinutes, seconds: selectedSeconds)
        interactor.updateTime(time)
    }
}

// MARK: - Interactor
extension GatherPresenter: GatherPresenterServiceInteractable {
    func endGather() {
        guard let winnerTeam = view?.winnerTeamDescription,
            let score = view?.scoreDescription else {
                return
        }
        
        view?.showLoadingView()
        interactor.endGather(score: score, winnerTeam: winnerTeam)
    }
}

// MARK: - Service Handler
extension GatherPresenter: GatherPresenterServiceHandler {
    func gatherEnded() {
        view?.hideLoadingView()
        delegate?.didEndGather()
        router.popToPlayerListView()
    }
    
    func serviceFailedToEndGather() {
        view?.hideLoadingView()
        view?.handleError(title: "Error", message: "Unable to end gather. Please try again.")
    }
    
    func timerDecremented() {
        view?.setTimerLabelText(formattedTime)
    }
}

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
    
    // MARK: - Init
    init(view: GatherViewProtocol? = nil) {
        self.view = view
    }
    
}

// MARK: - View Configuration
extension GatherPresenter: GatherPresenterConfigurable {
    func presentSelectedRows(response: Gather.SelectRows.Response) {
        if let selectedMinutes = response.minutes,
            let minutesComponent = response.minutesComponent {
            let viewModel = Gather.SelectRows.ViewModel(pickerRow: selectedMinutes, pickerComponent: minutesComponent)
            view?.displaySelectedRow(viewModel: viewModel)
        } else if let selectedSeconds = response.seconds,
            let secondsComponent = response.secondsComponent {
            let viewModel = Gather.SelectRows.ViewModel(pickerRow: selectedSeconds, pickerComponent: secondsComponent)
            view?.displaySelectedRow(viewModel: viewModel)
        }
    }
    
    func formatTime(response: Gather.FormatTime.Response) {
        let formattedTime = self.formattedTime(selectedMinutes: response.selectedTime.minutes,
                                               selectedSeconds: response.selectedTime.seconds)
        let viewModel = Gather.FormatTime.ViewModel(formattedTime: formattedTime)
        view?.displayTime(viewModel: viewModel)
    }
    
    private func formattedTime(selectedMinutes: Int, selectedSeconds: Int) -> String {
        let minutes = formatTime(selectedMinutes)
        let seconds = formatTime(selectedSeconds)
        
        return "\(minutes):\(seconds)"
    }
    
    private func formatTime(_ time: Int) -> String {
        time < 10 ? "0\(time)" : "\(time)"
    }
    
    func presentActionButton(response: Gather.ConfigureActionButton.Response) {
        let actionTitle = formatActionButtonTitle(timerState: response.timerState)
        let viewModel = Gather.ConfigureActionButton.ViewModel(title: actionTitle)
        view?.displayActionButtonTitle(viewModel: viewModel)
    }
    
    private func formatActionButtonTitle(timerState: GatherTimeHandler.State) -> String {
        switch timerState {
        case .paused:
            return "Resume"
            
        case .running:
            return "Pause"
            
        case .stopped:
            return "Start"
        }
    }
    
    func presentEndGatherConfirmationAlert(response: Gather.EndGather.Response) {
        view?.displayEndGatherConfirmationAlert()
    }
    
    func presentTimerView(response: Gather.SetTimer.Response) {
        let viewModel = Gather.SetTimer.ViewModel(timerViewIsVisible: true)
        view?.configureTimerViewVisibility(viewModel: viewModel)
    }
    
    func cancelTimer(response: Gather.CancelTimer.Response) {
        let formattedTime = self.formattedTime(selectedMinutes: response.selectedTime.minutes,
                                               selectedSeconds: response.selectedTime.seconds)
        let actionTitle = formatActionButtonTitle(timerState: response.timerState)
        let viewModel = Gather.CancelTimer.ViewModel(formattedTime: formattedTime,
                                                     actionTitle: actionTitle,
                                                     timerViewIsVisible: false)
        view?.displayCancelTimer(viewModel: viewModel)
    }
    
    func presentToggledTimer(response: Gather.ActionTimer.Response) {
        presentActionButton(response: Gather.ConfigureActionButton.Response(timerState: response.timerState))
    }
    
    func hideTimer() {
        let viewModel = Gather.SetTimer.ViewModel(timerViewIsVisible: false)
        view?.configureTimerViewVisibility(viewModel: viewModel)
    }
    
    func presentUpdatedTime(response: Gather.TimerDidFinish.Response) {
        let formattedTime = self.formattedTime(selectedMinutes: response.selectedTime.minutes,
                                               selectedSeconds: response.selectedTime.seconds)
        let actionTitle = formatActionButtonTitle(timerState: response.timerState)
        let viewModel = Gather.TimerDidFinish.ViewModel(formattedTime: formattedTime,
                                                        actionTitle: actionTitle,
                                                        timerViewIsVisible: false)
        view?.displayUpdatedTimer(viewModel: viewModel)
    }
    
    func popToPlayerListView() {
        view?.hideLoadingView()
        view?.popToPlayerListView()
    }
    
    func presentError(response: Gather.ErrorResponse) {
        view?.hideLoadingView()
        
        let viewModel = Gather.ErrorViewModel(errorTitle: "Error",
                                              errorMessage: "Unable to end gather. Please try again.")
        view?.displayError(viewModel: viewModel)
    }
    
    func displayTeamScore(response: Gather.UpdateValue.Response) {
        if response.teamSection == .teamA {
            let viewModel = Gather.UpdateValue.ViewModel(teamAText: "\(Int(response.newValue))")
            view?.displayTeamScore(viewModel: viewModel)
        } else if response.teamSection == .teamB {
            let viewModel = Gather.UpdateValue.ViewModel(teamBText: "\(Int(response.newValue))")
            view?.displayTeamScore(viewModel: viewModel)
        }
    }
}

// MARK: - Table Delegate
extension GatherPresenter: GatherPresenterTableDelegate {
    func numberOfSections(response: Gather.SectionsCount.Response) -> Int {
        response.teamSections.count
    }
    
    func numberOfRowsInSection(response: Gather.RowsCount.Response) -> Int {
        response.players.count
    }
    
    func rowDetails(response: Gather.RowDetails.Response) -> Gather.RowDetails.ViewModel {
        let viewModel = Gather.RowDetails.ViewModel(titleLabelText: response.player.name,
                                                    descriptionLabelText: response.player.preferredPosition?.acronym ?? "-")
        return viewModel
    }
    
    func titleForHeaderInSection(response: Gather.SectionTitle.Response) -> Gather.SectionTitle.ViewModel {
        Gather.SectionTitle.ViewModel(title: response.teamSection.headerTitle)
    }
}
    
// MARK: - Picker Delegate
extension GatherPresenter: GatherPresenterPickerDelegate {
    func numberOfPickerComponents(response: Gather.PickerComponents.Response) -> Int {
        response.timeComponents.count
    }
    
    func numberOfPickerRows(response: Gather.PickerRows.Response) -> Int {
        response.timeComponent.numberOfSteps
    }
    
    func titleForRow(response: Gather.PickerRowTitle.Response) -> Gather.PickerRowTitle.ViewModel {
        let title = "\(response.row) \(response.timeComponent.short)"
        return Gather.PickerRowTitle.ViewModel(title: title)
    }
}

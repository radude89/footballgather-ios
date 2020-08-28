//
//  GatherMocks.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 04/05/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

// MARK: - Presenter
final class GatherMockPresenter: GatherPresenterProtocol {
    var view: GatherViewProtocol?
    
    weak var expectation: XCTestExpectation? = nil
    
    var numberOfUpdateCalls = 1
    private(set) var actualUpdateCalls = 0
    
    private(set) var selectedMinutesComponent: Int?
    private(set) var selectedMinutes: Int?
    private(set) var selectedSecondsComponent: Int?
    private(set) var selectedSeconds: Int?
    
    private(set) var timeWasFormatted = false
    private(set) var timerViewWasPresented = false
    private(set) var timerWasCancelled = false
    private(set) var timerWasToggled = false
    private(set) var timerIsHidden = false
    private(set) var timeWasUpdated = false
    private(set) var alertWasPresented = false
    private(set) var poppedToPlayerListView = false
    private(set) var errorWasPresented = false
    
    private(set) var timerState: GatherTimeHandler.State?
    private(set) var score: [TeamSection: Double] = [:]
    private(set) var error: Error?
    private(set) var numberOfSections = 0
    private(set) var numberOfRows = 0
    
    func presentSelectedRows(response: Gather.SelectRows.Response) {
        if let minutes = response.minutes {
            selectedMinutes = minutes
        }
        
        if let minutesComponent = response.minutesComponent {
            selectedMinutesComponent = minutesComponent
        }
        
        if let seconds = response.seconds {
            selectedSeconds = seconds
        }
        
        if let secondsComponent = response.secondsComponent {
            selectedSecondsComponent = secondsComponent
        }
    }
    
    func formatTime(response: Gather.FormatTime.Response) {
        selectedMinutes = response.selectedTime.minutes
        selectedSeconds = response.selectedTime.seconds
        timeWasFormatted = true
        
        actualUpdateCalls += 1
        
        if let expectation = expectation,
            numberOfUpdateCalls == actualUpdateCalls {
            expectation.fulfill()
        }
    }
    
    func presentActionButton(response: Gather.ConfigureActionButton.Response) {
        timerState = response.timerState
    }
    
    func displayTeamScore(response: Gather.UpdateValue.Response) {
        score[response.teamSection] = response.newValue
    }
    
    func presentTimerView(response: Gather.SetTimer.Response) {
        timerViewWasPresented = true
    }
    
    func cancelTimer(response: Gather.CancelTimer.Response) {
        selectedMinutes = response.selectedTime.minutes
        selectedSeconds = response.selectedTime.seconds
        timerState = response.timerState
        
        timerWasCancelled = true
    }
    
    func presentToggledTimer(response: Gather.ActionTimer.Response) {
        timerState = response.timerState
        timerWasToggled = true
    }
    
    func hideTimer() {
        timerIsHidden = true
    }
    
    func presentUpdatedTime(response: Gather.TimerDidFinish.Response) {
        selectedMinutes = response.selectedTime.minutes
        selectedSeconds = response.selectedTime.seconds
        timerState = response.timerState
        
        timeWasUpdated = true
    }
    
    func presentEndGatherConfirmationAlert(response: Gather.EndGather.Response) {
        alertWasPresented = true
    }
    
    func popToPlayerListView() {
        poppedToPlayerListView = true
        expectation?.fulfill()
    }
    
    func presentError(response: Gather.ErrorResponse) {
        errorWasPresented = true
        error = response.error
        expectation?.fulfill()
    }
    
    func numberOfSections(response: Gather.SectionsCount.Response) -> Int {
        numberOfSections = response.teamSections.count
        return numberOfSections
    }
    
    func numberOfRowsInSection(response: Gather.RowsCount.Response) -> Int {
        numberOfRows = response.players.count
        return numberOfRows
    }
    
    func rowDetails(response: Gather.RowDetails.Response) -> Gather.RowDetails.ViewModel {
        Gather.RowDetails.ViewModel(titleLabelText: response.player.name,
                                    descriptionLabelText: response.player.preferredPosition?.acronym ?? "-")
    }
    
    func titleForHeaderInSection(response: Gather.SectionTitle.Response) -> Gather.SectionTitle.ViewModel {
        Gather.SectionTitle.ViewModel(title: response.teamSection.headerTitle)
    }
    
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

// MARK: - Delegate
final class GatherMockDelegate: GatherDelegate {
    private(set) var gatherWasEnded = false
    
    func didEndGather() {
        gatherWasEnded = true
    }
    
}

// MARK: - View
final class GatherMockView: GatherViewProtocol {
    var interactor: GatherInteractorProtocol!
    var router: GatherRouterProtocol = GatherRouter()
    var loadingView = LoadingView()
    
    private(set) var pickerComponent: Int?
    private(set) var pickerRow: Int?
    private(set) var animated: Bool?
    private(set) var formattedTime: String?
    private(set) var actionButtonTitle: String?
    private(set) var timerViewIsVisible: Bool?
    private(set) var teamAText: String?
    private(set) var teamBText: String?
    
    private(set) var selectedRowWasDisplayed = false
    private(set) var timeWasFormatted = false
    private(set) var confirmationAlertDisplayed = false
    private(set) var updatedTimerIsDisplayed = false
    private(set) var cancelTimerIsDisplayed = false
    private(set) var loadingViewIsVisible = false
    private(set) var poppedToPlayerListView = false
    private(set) var errorWasHandled = true
    
    func displaySelectedRow(viewModel: Gather.SelectRows.ViewModel) {
        pickerComponent = viewModel.pickerComponent
        pickerRow = viewModel.pickerRow
        animated = viewModel.animated
        
        selectedRowWasDisplayed = true
    }
    
    func displayTime(viewModel: Gather.FormatTime.ViewModel) {
        formattedTime = viewModel.formattedTime
        timeWasFormatted = true
    }
    
    func displayActionButtonTitle(viewModel: Gather.ConfigureActionButton.ViewModel) {
        actionButtonTitle = viewModel.title
    }
    
    func displayEndGatherConfirmationAlert() {
        confirmationAlertDisplayed = true
    }
    
    func configureTimerViewVisibility(viewModel: Gather.SetTimer.ViewModel) {
        timerViewIsVisible = viewModel.timerViewIsVisible
    }
    
    func displayUpdatedTimer(viewModel: Gather.TimerDidFinish.ViewModel) {
        actionButtonTitle = viewModel.actionTitle
        formattedTime = viewModel.formattedTime
        timerViewIsVisible = viewModel.timerViewIsVisible
        
        updatedTimerIsDisplayed = true
    }
    
    func showLoadingView() {
        loadingViewIsVisible = true
    }
    
    func hideLoadingView() {
        loadingViewIsVisible = false
    }
    
    func popToPlayerListView() {
        poppedToPlayerListView = true
    }
    
    func handleError(title: String, message: String) {
        errorWasHandled = true
    }
    
    func displayTeamScore(viewModel: Gather.UpdateValue.ViewModel) {
        if let teamAText = viewModel.teamAText {
            self.teamAText = teamAText
        }
        
        if let teamBText = viewModel.teamBText {
            self.teamBText = teamBText
        }
    }
    
    func displayCancelTimer(viewModel: Gather.CancelTimer.ViewModel) {
        actionButtonTitle = viewModel.actionTitle
        formattedTime = viewModel.formattedTime
        timerViewIsVisible = viewModel.timerViewIsVisible
        
        cancelTimerIsDisplayed = true
    }
    
}

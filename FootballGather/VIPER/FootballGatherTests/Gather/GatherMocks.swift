//
//  GatherMocks.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 04/05/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

// MARK: - View
final class GatherMockView: GatherViewProtocol {
    var presenter: GatherPresenterProtocol!
    var loadingView = LoadingView()
    
    private(set) var title: String?
    private(set) var timerViewIsHidden = false
    private(set) var selectionDictionary: [Int: Int] = [:]
    private(set) var timerLabelText: String?
    private(set) var actionButtonTitle: String?
    private(set) var scoreStepperWasSetup = false
    private(set) var viewWasReloaded = false
    private(set) var teamALabelText: String?
    private(set) var teamBLabelText: String?
    private(set) var confirmationAlertWasDisplayed = false
    private(set) var loadingViewWasShown = false
    private(set) var loadingViewWasHidden = false
    private(set) var errorWasHandled = false
    
    var scoreDescription: String { "" }
    
    var winnerTeamDescription: String { "" }
    
    func configureTitle(_ title: String) {
        self.title = title
    }
    
    func setTimerViewVisibility(isHidden: Bool) {
        timerViewIsHidden = isHidden
    }
    
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool) {
        selectionDictionary[component] = row
    }
    
    func setTimerLabelText(_ text: String) {
        timerLabelText = text
    }
    
    func setActionButtonTitle(_ title: String) {
        actionButtonTitle = title
    }
    
    func setupScoreStepper() {
        scoreStepperWasSetup = true
    }
    
    func reloadData() {
        viewWasReloaded = true
    }
    
    func setTeamALabelText(_ text: String) {
        teamALabelText = text
    }
    
    func setTeamBLabelText(_ text: String) {
        teamBLabelText = text
    }
    
    func displayConfirmationAlert() {
        confirmationAlertWasDisplayed = true
    }
    
    func showLoadingView() {
        loadingViewWasShown = true
    }
    
    func hideLoadingView() {
        loadingViewWasHidden = true
    }
    
    func handleError(title: String, message: String) {
        errorWasHandled = true
    }
    
    func selectedRow(in component: Int) -> Int { 0 }
}

// MARK: - Interactor
final class GatherMockInteractor: GatherInteractorProtocol {
    
    var presenter: GatherPresenterServiceHandler?
    var teamSections: [TeamSection] = TeamSection.allCases
    
    private(set) var timerState: GatherTimeHandler.State
    private(set) var timerWasStopped = false
    private(set) var timerWasResetted = false
    private(set) var timerWasToggled = false
    private(set) var timeWasUpdated = false
    private(set) var gatherWasEnded = false
    
    init(timerState: GatherTimeHandler.State = .stopped) {
        self.timerState = timerState
    }
    
    func stopTimer() {
        timerWasStopped = true
    }
    
    func resetTimer() {
        timerWasResetted = true
    }
    
    func teamSection(at index: Int) -> TeamSection {
        teamSections[index]
    }
    
    func toggleTimer() {
        timerWasToggled = true
    }
    
    func updateTime(_ gatherTime: GatherTime) {
        timeWasUpdated = true
    }
    
    func endGather(score: String, winnerTeam: String) {
        gatherWasEnded = true
    }
        
    var selectedTime: GatherTime { .defaultTime }
    
    var minutesComponent: GatherTimeHandler.Component? { .minutes }
    
    var secondsComponent: GatherTimeHandler.Component? { .seconds }
    
    var timeComponents: [GatherTimeHandler.Component] = GatherTimeHandler.Component.allCases
    
    func timeComponent(at index: Int) -> GatherTimeHandler.Component {
        timeComponents[index]
    }
    
    func players(in team: TeamSection) -> [PlayerResponseModel] { [] }
    
}

// MARK: - Delegate
final class GatherMockDelegate: GatherDelegate {
    private(set) var gatherWasEnded = false
    
    func didEndGather() {
        gatherWasEnded = true
    }
    
}

// MARK: - Router
final class GatherMockRouter: GatherRouterProtocol {
    private(set) var poppedToPlayerList = false
    
    func popToPlayerListView() {
        poppedToPlayerList = true
    }
    
}

// MARK: - Presenter
final class GatherMockPresenter: GatherPresenterServiceHandler {
    private(set) var gatherEndedCalled = false
    private(set) var serviceFailedCalled = false
    private(set) var timerDecrementedCalled = false
    
    weak var expectation: XCTestExpectation? = nil
    
    var numberOfUpdateCalls = 1
    private(set) var actualUpdateCalls = 0
    
    func gatherEnded() {
        gatherEndedCalled = true
        expectation?.fulfill()
    }
    
    func serviceFailedToEndGather() {
        serviceFailedCalled = true
        expectation?.fulfill()
    }
    
    func timerDecremented() {
        timerDecrementedCalled = true
        
        actualUpdateCalls += 1
        
        if expectation != nil && numberOfUpdateCalls == actualUpdateCalls {
            expectation?.fulfill()
        }
    }
    
}

//
//  GatherPresenterTests.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 04/05/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class GatherPresenterTests: XCTestCase {

    // MARK: - GatherPresenterViewConfiguration
    func testViewDidLoad_whenPresenterIsAllocated_configuresView() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertEqual(mockView.title, "Gather in progress")
        XCTAssertTrue(mockView.timerViewIsHidden)
        XCTAssertEqual(mockView.selectionDictionary[mockInteractor.minutesComponent!.rawValue], mockInteractor.selectedTime.minutes)
        XCTAssertEqual(mockView.selectionDictionary[mockInteractor.secondsComponent!.rawValue], mockInteractor.selectedTime.seconds)
        XCTAssertEqual(mockView.timerLabelText, "10:00")
        XCTAssertEqual(mockView.actionButtonTitle, "Start")
        XCTAssertTrue(mockView.scoreStepperWasSetup)
        XCTAssertTrue(mockView.viewWasReloaded)
    }
    
    func testViewDidLoad_whenTimeComponentsAreEmpty_minutesComponentIsNil() {
        // given
        let mockView = GatherMockView()
        let mockGather = GatherModel(players: [], gatherUUID: UUID())
        let mockInteractor = GatherInteractor(gather: mockGather, timeComponents: [])
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.viewDidLoad()
        
        // then
        XCTAssertNil(mockView.selectionDictionary[0])
        XCTAssertNil(mockView.selectionDictionary[1])
    }
    
    // MARK: - Table Data Source
    func testNumberOfSections_whenPresenterIsAllocated_equalsTeamSectionsCount() {
        // given
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let numberOfSections = sut.numberOfSections
        
        // then
        XCTAssertEqual(mockInteractor.teamSections.count, numberOfSections)
    }
    
    func testNumberOfRowsInSection_whenSectionIsZero_equalsNumberOfPlayersInTeamSection() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let expectedNumberOfPlayers = mockGather.players.filter { $0.team == .teamA }.count
        let mockInteractor = GatherInteractor(gather: mockGather)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let numberOfRowsInSection = sut.numberOfRowsInSection(0)
        
        // then
        XCTAssertEqual(numberOfRowsInSection, expectedNumberOfPlayers)
    }
    
    func testNumberOfRowsInSection_whenSectionIsOne_equalsNumberOfPlayersInTeamSection() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 5)
        let expectedNumberOfPlayers = mockGather.players.filter { $0.team == .teamB }.count
        let mockInteractor = GatherInteractor(gather: mockGather)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let numberOfRowsInSection = sut.numberOfRowsInSection(1)
        
        // then
        XCTAssertEqual(numberOfRowsInSection, expectedNumberOfPlayers)
    }
    
    func testRowTitle_whenInteractorHasPlayers_equalsPlayerName() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let expectedRowTitle = mockGather.players.filter { $0.team == .teamA }.first?.player.name
        let mockInteractor = GatherInteractor(gather: mockGather)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let rowTitle = sut.rowTitle(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertEqual(rowTitle, expectedRowTitle)
    }
    
    func testRowDescription_whenInteractorHasPlayers_equalsPlayerPreferredPositionAcronym() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 1)
        let expectedRowDescription = mockGather.players.filter { $0.team == .teamB }.first?.player.preferredPosition?.acronym
        let mockInteractor = GatherInteractor(gather: mockGather)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let rowDescription = sut.rowDescription(at: IndexPath(row: 0, section: 1))
        
        // then
        XCTAssertEqual(rowDescription, expectedRowDescription)
    }
    
    func testTitleForHeaderInSection_whenSectionIsTeamA_equalsTeamSectionHeaderTitle() {
        // given
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let expectedTitle = TeamSection.teamA.headerTitle
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let titleForHeader = sut.titleForHeaderInSection(0)
        
        // then
        XCTAssertEqual(titleForHeader, expectedTitle)
    }
    
    func testTitleForHeaderInSection_whenSectionIsTeamB_equalsTeamSectionHeaderTitle() {
        // given
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let expectedTitle = TeamSection.teamB.headerTitle
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let titleForHeader = sut.titleForHeaderInSection(1)
        
        // then
        XCTAssertEqual(titleForHeader, expectedTitle)
    }

    // MARK: - Picker Data Source
    func testNumberOfPickerComponents_whenTimeComponentsAreGiven_equalsInteractorTimeComponents() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.minutes]
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeComponents: mockTimeComponents)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let numberOfPickerComponents = sut.numberOfPickerComponents
        
        // then
        XCTAssertEqual(numberOfPickerComponents, mockTimeComponents.count)
    }
    
    func testNumberOfRowsInPickerComponent_whenComponentIsMinutes_equalsNumberOfSteps() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.minutes]
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeComponents: mockTimeComponents)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let numberOfRowsInPickerComponent = sut.numberOfRowsInPickerComponent(0)
        
        // then
        XCTAssertEqual(numberOfRowsInPickerComponent, GatherTimeHandler.Component.minutes.numberOfSteps)
    }
    
    func testNumberOfRowsInPickerComponent_whenComponentIsSeconds_equalsNumberOfSteps() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.seconds]
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeComponents: mockTimeComponents)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let numberOfRowsInPickerComponent = sut.numberOfRowsInPickerComponent(0)
        
        // then
        XCTAssertEqual(numberOfRowsInPickerComponent, GatherTimeHandler.Component.seconds.numberOfSteps)
    }
    
    func testTitleForPickerRow_whenComponentsAreNotEmpty_containsTimeComponentShort() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.seconds]
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeComponents: mockTimeComponents)
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        let titleForPickerRow = sut.titleForPickerRow(0, forComponent: 0)
        
        // then
        XCTAssertTrue(titleForPickerRow.contains(GatherTimeHandler.Component.seconds.short))
    }
    
    // MARK: - Stepper Handler
    func testUpdateValue_whenTeamIsA_viewSetsTeamALabelTextWithNewValue() {
        // given
        let mockValue = 15.0
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.updateValue(for: .teamA, with: mockValue)
        
        // then
        XCTAssertEqual(mockView.teamALabelText, "\(Int(mockValue))")
    }
    
    func testUpdateValue_whenTeamIsB_viewSetsTeamBLabelTextWithNewValue() {
        // given
        let mockValue = 15.0
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.updateValue(for: .teamB, with: mockValue)
        
        // then
        XCTAssertEqual(mockView.teamBLabelText, "\(Int(mockValue))")
    }
    
    // MARK: - Actions
    func testRequestToEndGather_whenPresenterIsAllocated_viewDisplaysConfirmationAlert() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.requestToEndGather()
        
        // then
        XCTAssertTrue(mockView.confirmationAlertWasDisplayed)
    }
    
    func testSetTimer_whenPresenterIsAllocated_selectsRowAndSetsTimerViewVisibile() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.setTimer()
        
        // then
        XCTAssertNotNil(mockView.selectionDictionary[0])
        XCTAssertNotNil(mockView.selectionDictionary[1])
        XCTAssertFalse(mockView.timerViewIsHidden)
    }
    
    func testCancelTimer_whenPresenterIsAllocated_resetsTimerAndUpdatesView() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherMockInteractor()
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.cancelTimer()
        
        // then
        XCTAssertTrue(mockInteractor.timerWasStopped)
        XCTAssertTrue(mockInteractor.timerWasResetted)
        XCTAssertNotNil(mockView.timerLabelText)
        XCTAssertNotNil(mockView.actionButtonTitle)
        XCTAssertTrue(mockView.timerViewIsHidden)
    }
    
    func testActionTimer_whenPresenterIsAllocated_togglesTimerAndUpdatesActionButtonTitle() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherMockInteractor()
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.actionTimer()
        
        // then
        XCTAssertTrue(mockInteractor.timerWasToggled)
        XCTAssertNotNil(mockView.actionButtonTitle)
    }
    
    func testTimerCancel_whenPresenterIsAllocated_timerViewIsHidden() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.timerCancel()
        
        // then
        XCTAssertTrue(mockView.timerViewIsHidden)
    }
    
    func testTimerDone_whenPresenterIsAllocated_stopsTimerUpdatesTimeAndConfiguresView() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherMockInteractor()
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.timerDone()
        
        // then
        XCTAssertTrue(mockInteractor.timerWasStopped)
        XCTAssertTrue(mockInteractor.timeWasUpdated)
        XCTAssertNotNil(mockView.timerLabelText)
        XCTAssertNotNil(mockView.actionButtonTitle)
        XCTAssertTrue(mockView.timerViewIsHidden)
    }
    
    func testTimerDone_whenViewIsNil_stopsTimerUpdatesTimeAndConfiguresView() {
        // given
        let mockInteractor = GatherMockInteractor()
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        sut.timerDone()
        
        // then
        XCTAssertFalse(mockInteractor.timeWasUpdated)
    }
    
    func testEndGather_whenViewIsNotNil_showsLoadingViewAndEndsGather() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherMockInteractor()
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.endGather()
        
        // then
        XCTAssertTrue(mockView.loadingViewWasShown)
        XCTAssertTrue(mockInteractor.gatherWasEnded)
    }
    
    func testEndGather_whenViewIsNil_returns() {
        // given
        let mockInteractor = GatherMockInteractor()
        let sut = GatherPresenter(interactor: mockInteractor)
        
        // when
        sut.endGather()
        
        // then
        XCTAssertFalse(mockInteractor.gatherWasEnded)
    }
    
    func testGatherEnded_whenPresenterIsAllocated_hidesLoadingViewEndGathersAndPopsToPlayerList() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherMockInteractor()
        let mockDelegate = GatherMockDelegate()
        let mockRouter = GatherMockRouter()
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor, router: mockRouter, delegate: mockDelegate)
        
        // when
        sut.gatherEnded()
        
        // then
        XCTAssertTrue(mockView.loadingViewWasHidden)
        XCTAssertTrue(mockDelegate.gatherWasEnded)
        XCTAssertTrue(mockRouter.poppedToPlayerList)
    }
    
    func testServiceFailedToEndGather_whenPresenterIsAllocated_hidesLoadingViewAndHandlesError() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.serviceFailedToEndGather()
        
        // then
        XCTAssertTrue(mockView.loadingViewWasHidden)
        XCTAssertTrue(mockView.errorWasHandled)
    }
    
    func testTimerDecremented_whenPresenterIsAllocated_setsTimerLabelText() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.timerDecremented()
        
        // then
        XCTAssertNotNil(mockView.timerLabelText)
    }
    
    func testActionButtonTitle_whenTimerStateIsPaused_isResume() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherMockInteractor(timerState: .paused)
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.actionTimer()
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Resume")
    }
    
    func testActionButtonTitle_whenTimerStateIsRunning_isPause() {
        // given
        let mockView = GatherMockView()
        let mockInteractor = GatherMockInteractor(timerState: .running)
        let sut = GatherPresenter(view: mockView, interactor: mockInteractor)
        
        // when
        sut.actionTimer()
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Pause")
    }
    
}

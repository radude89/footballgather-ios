//
//  GatherInteractorTests.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 11/08/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class GatherInteractorTests: XCTestCase {
    
    // MARK: - Configure
    func testSelectRows_whenRequestIsGiven_presentsSelectedTime() {
        // given
        let mockSelectedTime = GatherTime(minutes: 25, seconds: 54)
        let mockTimeHandler = GatherTimeHandler(selectedTime: mockSelectedTime)
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeHandler: mockTimeHandler)
        
        // when
        sut.selectRows(request: Gather.SelectRows.Request())
        
        // then
        XCTAssertEqual(mockPresenter.selectedMinutes, mockSelectedTime.minutes)
        XCTAssertEqual(mockPresenter.selectedMinutesComponent, sut.minutesComponent?.rawValue)
        XCTAssertEqual(mockPresenter.selectedSeconds, mockSelectedTime.seconds)
        XCTAssertEqual(mockPresenter.selectedSecondsComponent, sut.secondsComponent?.rawValue)
    }
    
    func testSelectRows_whenComponentsAreNil_selectedTimeIsNil() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeComponents: [])
        
        // when
        sut.selectRows(request: Gather.SelectRows.Request())
        
        // then
        XCTAssertNil(mockPresenter.selectedMinutes)
        XCTAssertNil(mockPresenter.selectedMinutesComponent)
        XCTAssertNil(mockPresenter.selectedSeconds)
        XCTAssertNil(mockPresenter.selectedSecondsComponent)
    }
    
    func testFormatTime_whenRequestIsGiven_formatsTime() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.formatTime(request: Gather.FormatTime.Request())
        
        // then
        XCTAssertNotNil(mockPresenter.selectedMinutes)
        XCTAssertNotNil(mockPresenter.selectedSeconds)
        XCTAssertTrue(mockPresenter.timeWasFormatted)
    }
    
    func testConfigureActionButton_whenRequestIsGiven_() {
        // given
        let mockState = GatherTimeHandler.State.running
        let mockTimeHandler = GatherTimeHandler(state: mockState)
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeHandler: mockTimeHandler)
        
        // when
        sut.configureActionButton(request: Gather.ConfigureActionButton.Request())
        
        // then
        XCTAssertEqual(mockPresenter.timerState, mockState)
    }
    
    func testUpdateValue_whenRequestIsGiven_displaysTeamScore() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.updateValue(request: Gather.UpdateValue.Request(teamSection: .teamA, newValue: 15))
        sut.updateValue(request: Gather.UpdateValue.Request(teamSection: .teamB, newValue: 16))
        
        // then
        XCTAssertEqual(mockPresenter.score[.teamA], 15)
        XCTAssertEqual(mockPresenter.score[.teamB], 16)
    }
    
    // MARK: - Time Handler
    func testSetTimer_whenRequestIsGiven_selectsTime() {
        // given
        let mockSelectedTime = GatherTime(minutes: 5, seconds: 0)
        let mockTimeHandler = GatherTimeHandler(selectedTime: mockSelectedTime)
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeHandler: mockTimeHandler)
        
        // when
        sut.setTimer(request: Gather.SetTimer.Request())
        
        // then
        XCTAssertEqual(mockPresenter.selectedMinutes, mockSelectedTime.minutes)
        XCTAssertEqual(mockPresenter.selectedMinutesComponent, sut.minutesComponent?.rawValue)
        XCTAssertEqual(mockPresenter.selectedSeconds, mockSelectedTime.seconds)
        XCTAssertEqual(mockPresenter.selectedSecondsComponent, sut.secondsComponent?.rawValue)
    }
    
    func testSetTimer_whenRequestIsGiven_presentsTimerView() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.setTimer(request: Gather.SetTimer.Request())
        
        // then
        XCTAssertTrue(mockPresenter.timerViewWasPresented)
    }
    
    func testCancelTimer_whenRequestIsGiven_cancelsTimer() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.cancelTimer(request: Gather.CancelTimer.Request())
        
        // then
        XCTAssertNotNil(mockPresenter.selectedMinutes)
        XCTAssertNotNil(mockPresenter.selectedSeconds)
        XCTAssertNotNil(mockPresenter.timerState)
        XCTAssertTrue(mockPresenter.timerWasCancelled)
    }
    
    func testActionTimer_whenRequestIsGiven_presentsToggledTime() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.actionTimer(request: Gather.ActionTimer.Request())
        
        // then
        XCTAssertNotNil(mockPresenter.timerState)
        XCTAssertTrue(mockPresenter.timerWasToggled)
    }
    
    func testActionTimer_whenTimeIsInvalid_presentsToggledTime() {
        // given
        let mockSelectedTime = GatherTime(minutes: -1, seconds: -1)
        let mockTimeHandler = GatherTimeHandler(selectedTime: mockSelectedTime)
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeHandler: mockTimeHandler)
        
        // when
        sut.actionTimer(request: Gather.ActionTimer.Request())
        
        // then
        XCTAssertNotNil(mockPresenter.timerState)
        XCTAssertTrue(mockPresenter.timerWasToggled)
    }
    
    func testActionTimer_whenTimeIsValid_updatesTimer() {
        // given
        let numberOfUpdateCalls = 2
        let mockSelectedTime = GatherTime(minutes: 0, seconds: numberOfUpdateCalls)
        let mockTimeHandler = GatherTimeHandler(selectedTime: mockSelectedTime)
        
        let exp = expectation(description: "Update timer expectation")
        let mockPresenter = GatherMockPresenter()
        mockPresenter.expectation = exp
        mockPresenter.numberOfUpdateCalls = numberOfUpdateCalls
        
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeHandler: mockTimeHandler)
        
        // when
        sut.actionTimer(request: Gather.ActionTimer.Request())
        
        // then
        waitForExpectations(timeout: 5) { _ in
            XCTAssertEqual(mockPresenter.actualUpdateCalls, numberOfUpdateCalls)
            sut.cancelTimer(request: Gather.CancelTimer.Request())
        }
    }
    
    func testTimerDidCancel_whenRequestIsGiven_hidesTimer() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.timerDidCancel(request: Gather.TimerDidCancel.Request())
        
        // then
        XCTAssertTrue(mockPresenter.timerIsHidden)
    }
    
    func testTimerDidFinish_whenRequestIsGiven_updatesTime() {
        // given
        let mockSelectedTime = GatherTime(minutes: 1, seconds: 13)
        let mockTimeHandler = GatherTimeHandler(selectedTime: mockSelectedTime)
        let mockRequest = Gather.TimerDidFinish.Request(selectedMinutes: 0, selectedSeconds: 25)
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeHandler: mockTimeHandler)
        
        // when
        sut.timerDidFinish(request: mockRequest)
        
        // then
        XCTAssertEqual(mockPresenter.selectedMinutes, mockRequest.selectedMinutes)
        XCTAssertEqual(mockPresenter.selectedSeconds, mockRequest.selectedSeconds)
        XCTAssertNotNil(mockPresenter.timerState)
        XCTAssertTrue(mockPresenter.timeWasUpdated)
    }
    
    // MARK: - GatherInteractorActionable
    func testRequestToEndGather_whenRequestIsGiven_presentsAlert() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.requestToEndGather(request: Gather.EndGather.Request())
        
        // then
        XCTAssertTrue(mockPresenter.alertWasPresented)
    }
    
    func testEndGather_whenScoreDescriptionIsNil_returns() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.endGather(request: Gather.EndGather.Request(winnerTeamDescription: "win"))
        
        // then
        XCTAssertFalse(mockPresenter.poppedToPlayerListView)
        XCTAssertFalse(mockPresenter.errorWasPresented)
    }
    
    func testEndGather_whenWinnerTeamDescriptionIsNil_returns() {
        // given
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.endGather(request: Gather.EndGather.Request(scoreDescription: "score"))
        
        // then
        XCTAssertFalse(mockPresenter.poppedToPlayerListView)
        XCTAssertFalse(mockPresenter.errorWasPresented)
    }
    
    func testEndGather_whenScoreIsSet_updatesGather() {
        // given
        let appKeychain = AppKeychainMockFactory.makeKeychain()
        appKeychain.token = ModelsMock.token
        let session = URLSessionMockFactory.makeSession()
        
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let mockEndpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: "/api/gathers")
        let mockService = StandardNetworkService(session: session,
                                                 urlRequest: AuthURLRequestFactory(endpoint: mockEndpoint,
                                                                                   keychain: appKeychain))
        
        let mockPresenter = GatherMockPresenter()
        let exp = expectation(description: "Update gather expectation")
        mockPresenter.expectation = exp
        
        let mockDelegate = GatherMockDelegate()
        
        let sut = GatherInteractor(presenter: mockPresenter,
                                   delegate: mockDelegate,
                                   gather: mockGatherModel,
                                   updateGatherService: mockService)
        
        // when
        sut.endGather(request: Gather.EndGather.Request(winnerTeamDescription: "None", scoreDescription: "1-1"))
        
        // then
        waitForExpectations(timeout: 5) { _ in
            XCTAssertTrue(mockPresenter.poppedToPlayerListView)
            XCTAssertTrue(mockDelegate.gatherWasEnded)
            
            appKeychain.storage.removeAll()
        }
    }
    
    func testEndGather_whenScoreIsNotSet_errorIsPresented() {
        // given
        let appKeychain = AppKeychainMockFactory.makeKeychain()
        appKeychain.token = ModelsMock.token
        let session = URLSessionMockFactory.makeSession()
        
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let mockEndpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: "/api/gathers")
        let mockService = StandardNetworkService(session: session,
                                                 urlRequest: AuthURLRequestFactory(endpoint: mockEndpoint,
                                                                                   keychain: appKeychain))
        
        let mockPresenter = GatherMockPresenter()
        let exp = expectation(description: "Update gather expectation")
        mockPresenter.expectation = exp
        
        let mockDelegate = GatherMockDelegate()
        
        let sut = GatherInteractor(presenter: mockPresenter,
                                   delegate: mockDelegate,
                                   gather: mockGatherModel,
                                   updateGatherService: mockService)
        
        // when
        sut.endGather(request: Gather.EndGather.Request(winnerTeamDescription: "", scoreDescription: ""))
        
        // then
        waitForExpectations(timeout: 5) { _ in
            XCTAssertTrue(mockPresenter.errorWasPresented)
            XCTAssertTrue(mockPresenter.error is EndGatherError)
            appKeychain.storage.removeAll()
        }
    }
    
    // MARK: - Table Delegate
    func testNumberOfSections_whenRequestIsGiven_returnsNumberOfTeamSections() {
        // given
        let mockTeamSections: [TeamSection] = [.teamA]
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   teamSections: mockTeamSections)
        
        // when
        let numberOfSections = sut.numberOfSections(request: Gather.SectionsCount.Request())
        
        // then
        XCTAssertEqual(mockPresenter.numberOfSections, mockTeamSections.count)
        XCTAssertEqual(mockPresenter.numberOfSections, numberOfSections)
    }
    
    func testNumberOfRowsInSection_whenSectionIsZero_equalsNumberOfPlayersInTeamSection() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let expectedNumberOfPlayers = mockGather.players.filter { $0.team == .teamA }.count
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter, gather: mockGather)
        
        // when
        let numberOfRowsInSection = sut.numberOfRowsInSection(request: Gather.RowsCount.Request(section: 0))
        
        // then
        XCTAssertEqual(mockPresenter.numberOfRows, expectedNumberOfPlayers)
        XCTAssertEqual(numberOfRowsInSection, expectedNumberOfPlayers)
    }
    
    func testNumberOfRowsInSection_whenSectionIsOne_equalsNumberOfPlayersInTeamSection() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 5)
        let expectedNumberOfPlayers = mockGather.players.filter { $0.team == .teamB }.count
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter, gather: mockGather)
        
        // when
        let numberOfRowsInSection = sut.numberOfRowsInSection(request: Gather.RowsCount.Request(section: 1))
        
        // then
        XCTAssertEqual(mockPresenter.numberOfRows, expectedNumberOfPlayers)
        XCTAssertEqual(numberOfRowsInSection, expectedNumberOfPlayers)
    }
    
    func testRowDetails_whenInteractorHasPlayers_equalsPlayerNameAndPreferredPositionAcronym() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        
        let firstTeamAPlayer = mockGather.players.filter { $0.team == .teamA }.first?.player
        let expectedRowTitle = firstTeamAPlayer?.name
        let expectedRowDescription = firstTeamAPlayer?.preferredPosition?.acronym
        
        let mockIndexPath = IndexPath(row: 0, section: 0)
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter, gather: mockGather)
        
        // when
        let rowDetails = sut.rowDetails(request: Gather.RowDetails.Request(indexPath: mockIndexPath))
        
        // then
        XCTAssertEqual(rowDetails.titleLabelText, expectedRowTitle)
        XCTAssertEqual(rowDetails.descriptionLabelText, expectedRowDescription)
    }
    
    func testTitleForHeaderInSection_whenSectionIsTeamA_equalsTeamSectionHeaderTitle() {
        // given
        let expectedTitle = TeamSection.teamA.headerTitle
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let titleForHeader = sut.titleForHeaderInSection(request: Gather.SectionTitle.Request(section: 0)).title
        
        // then
        XCTAssertEqual(titleForHeader, expectedTitle)
    }
    
    func testTitleForHeaderInSection_whenSectionIsTeamB_equalsTeamSectionHeaderTitle() {
        // given
        let expectedTitle = TeamSection.teamB.headerTitle
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let titleForHeader = sut.titleForHeaderInSection(request: Gather.SectionTitle.Request(section: 1)).title
        
        // then
        XCTAssertEqual(titleForHeader, expectedTitle)
    }
    
    // MARK: - Picker Delegate
    func testNumberOfPickerComponents_whenTimeComponentsAreGiven_equalsInteractorTimeComponents() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.minutes]
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeComponents: mockTimeComponents)
        
        // when
        let numberOfPickerComponents = sut.numberOfPickerComponents(request: Gather.PickerComponents.Request())
        
        // then
        XCTAssertEqual(numberOfPickerComponents, mockTimeComponents.count)
    }
    
    func testNumberOfRowsInPickerComponent_whenComponentIsMinutes_equalsNumberOfSteps() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.minutes]
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeComponents: mockTimeComponents)
        
        // when
        let numberOfRowsInPickerComponent = sut.numberOfRowsInPickerComponent(request: Gather.PickerRows.Request(component: 0))
        
        // then
        XCTAssertEqual(numberOfRowsInPickerComponent, GatherTimeHandler.Component.minutes.numberOfSteps)
    }
    
    func testNumberOfRowsInPickerComponent_whenComponentIsSeconds_equalsNumberOfSteps() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.seconds]
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeComponents: mockTimeComponents)
        
        // when
        let numberOfRowsInPickerComponent = sut.numberOfRowsInPickerComponent(request: Gather.PickerRows.Request(component: 0))
        
        // then
        XCTAssertEqual(numberOfRowsInPickerComponent, GatherTimeHandler.Component.seconds.numberOfSteps)
    }
    
    func testTitleForPickerRow_whenComponentsAreNotEmpty_containsTimeComponentShort() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.seconds]
        let mockPresenter = GatherMockPresenter()
        let sut = GatherInteractor(presenter: mockPresenter,
                                   gather: GatherModel(players: [], gatherUUID: UUID()),
                                   timeComponents: mockTimeComponents)
        
        // when
        let titleForPickerRow = sut.titleForPickerRow(request: Gather.PickerRowTitle.Request(row: 0, component: 0)).title
        
        // then
        XCTAssertTrue(titleForPickerRow.contains(GatherTimeHandler.Component.seconds.short))
    }
    
}

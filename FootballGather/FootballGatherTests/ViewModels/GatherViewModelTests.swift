//
//  GatherViewModelTests.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 28/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class GatherViewModelTests: XCTestCase {
    
    private let session = URLSessionMockFactory.makeSession()
    private let resourcePath = "/api/gathers"
    private let appKeychain = AppKeychainMockFactory.makeKeychain()
    
    override func setUp() {
        super.setUp()
        appKeychain.token = ModelsMock.token
    }
    
    override func tearDown() {
        appKeychain.storage.removeAll()
        super.tearDown()
    }
    
    func testTitle_whenViewModelIsAllocated_isNotEmpty() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let title = sut.title
        
        // then
        XCTAssertFalse(title.isEmpty)
    }
    
    func testFormattedCountdownTimerLabelText_whenViewModelIsAllocated_returnsDefaultTime() {
        // given
        let gatherTime = GatherTime.defaultTime
        let expectedFormattedMinutes = gatherTime.minutes < 10 ? "0\(gatherTime.minutes)" : "\(gatherTime.minutes)"
        let expectedFormattedSeconds = gatherTime.seconds < 10 ? "0\(gatherTime.seconds)" : "\(gatherTime.seconds)"
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let formattedCountdownTimerLabelText = sut.formattedCountdownTimerLabelText
        
        // then
        XCTAssertEqual(formattedCountdownTimerLabelText, "\(expectedFormattedMinutes):\(expectedFormattedSeconds)")
    }
    
    func testFormattedCountdownTimerLabelText_whenTimeIsZero_returnsZeroSecondsZeroMinutes() {
        // given
        let mockGatherTime = GatherTime(minutes: 0, seconds: 0)
        let mockGatherTimeHandler = GatherTimeHandler(selectedTime: mockGatherTime)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        let formattedCountdownTimerLabelText = sut.formattedCountdownTimerLabelText
        
        // then
        XCTAssertEqual(formattedCountdownTimerLabelText, "00:00")
    }
    
    func testFormattedCountdownTimerLabelText_whenTimeHasMinutesAndZeroSeconds_returnsMinutesAndZeroSeconds() {
        // given
        let mockGatherTime = GatherTime(minutes: 10, seconds: 0)
        let mockGatherTimeHandler = GatherTimeHandler(selectedTime: mockGatherTime)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        let formattedCountdownTimerLabelText = sut.formattedCountdownTimerLabelText
        
        // then
        XCTAssertEqual(formattedCountdownTimerLabelText, "10:00")
    }
    
    func testFormattedCountdownTimerLabelText_whenTimeHasSecondsAndZeroMinutes_returnsSecondsAndZeroMinutes() {
        // given
        let mockGatherTime = GatherTime(minutes: 0, seconds: 10)
        let mockGatherTimeHandler = GatherTimeHandler(selectedTime: mockGatherTime)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        let formattedCountdownTimerLabelText = sut.formattedCountdownTimerLabelText
        
        // then
        XCTAssertEqual(formattedCountdownTimerLabelText, "00:10")
    }
    
    func testFormattedActionTitleText_whenStateIsPaused_returnsResume() {
        // given
        let mockGatherTimeHandler = GatherTimeHandler(state: .paused)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        let formattedActionTitleText = sut.formattedActionTitleText
        
        // then
        XCTAssertEqual(formattedActionTitleText, "Resume")
    }
    
    func testFormattedActionTitleText_whenStateIsRunning_returnsStop() {
        // given
        let mockGatherTimeHandler = GatherTimeHandler(state: .running)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        let formattedActionTitleText = sut.formattedActionTitleText
        
        // then
        XCTAssertEqual(formattedActionTitleText, "Stop")
    }
    
    func testFormattedActionTitleText_whenStateIsStopped_returnsStart() {
        // given
        let mockGatherTimeHandler = GatherTimeHandler(state: .stopped)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        let formattedActionTitleText = sut.formattedActionTitleText
        
        // then
        XCTAssertEqual(formattedActionTitleText, "Start")
    }
    
    func testToggleTimer_whenSelectedTimeIsNotValid_returns() {
        // given
        let mockGatherTime = GatherTime(minutes: -1, seconds: -1)
        let mockGatherTimeHandler = GatherTimeHandler(selectedTime: mockGatherTime)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let mockDelegate = MockViewModelDelegate()
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        sut.delegate = mockDelegate
        
        // when
        sut.toggleTimer()
        
        // then
        XCTAssertFalse(mockDelegate.gatherTimeWasUpdated)
    }
    
    func testToggleTimer_whenSelectedTimeIsValid_updatesTime() {
        // given
        let numberOfUpdateCalls = 2
        let mockGatherTime = GatherTime(minutes: 0, seconds: numberOfUpdateCalls)
        let mockGatherTimeHandler = GatherTimeHandler(selectedTime: mockGatherTime)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        
        let exp = expectation(description: "Waiting timer expectation")
        let mockDelegate = MockViewModelDelegate()
        mockDelegate.numberOfUpdateCalls = numberOfUpdateCalls
        mockDelegate.expectation = exp

        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        sut.delegate = mockDelegate
        sut.toggleTimer()
        
        // then
        waitForExpectations(timeout: 5) { _ in
            XCTAssertTrue(mockDelegate.gatherTimeWasUpdated)
            XCTAssertEqual(mockDelegate.actualUpdateCalls, numberOfUpdateCalls)
            sut.stopTimer()
        }
    }
    
    func testStopTimer_whenStateIsRunning_updatesStateToStopped() {
        // given
        let mockGatherTimeHandler = GatherTimeHandler(state: .running)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        sut.stopTimer()
        
        // then
        let formattedActionTitleText = sut.formattedActionTitleText
        XCTAssertEqual(formattedActionTitleText, "Start")
    }
    
    func testResetTimer_whenTimeIsSet_returnsDefaultTime() {
        // given
        let mockMinutes = 12
        let mockSeconds = 13
        let mockGatherTime = GatherTime(minutes: mockMinutes, seconds: mockSeconds)
        let mockGatherTimeHandler = GatherTimeHandler(selectedTime: mockGatherTime)
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel, timeHandler: mockGatherTimeHandler)
        
        // when
        sut.resetTimer()
        
        // then
        XCTAssertNotEqual(sut.selectedMinutes, mockMinutes)
        XCTAssertNotEqual(sut.selectedSeconds, mockSeconds)
        XCTAssertEqual(sut.selectedMinutes, GatherTime.defaultTime.minutes)
        XCTAssertEqual(sut.selectedSeconds, GatherTime.defaultTime.seconds)
    }
    
    func testMinutesComponent_whenViewModelIsAllocated_returnsComponentMinutes() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let minutesComponent = sut.minutesComponent
        
        // then
        XCTAssertEqual(minutesComponent, GatherTimeHandler.Component.minutes.rawValue)
    }
    
    func testSecondsComponent_whenViewModelIsAllocated_returnsComponentSeconds() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let secondsComponent = sut.secondsComponent
        
        // then
        XCTAssertEqual(secondsComponent, GatherTimeHandler.Component.seconds.rawValue)
    }
    
    func testSetTimerMinutes_whenMinutesAreGiven_updatesSelectedTime() {
        // given
        let mockMinutes = 10
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        sut.setTimerMinutes(mockMinutes)
        
        // then
        let selectedMinutes = sut.selectedMinutes
        XCTAssertEqual(selectedMinutes, mockMinutes)
    }
    
    func testSetTimerSeconds_whenSecondsAreGiven_updatesSelectedTime() {
        // given
        let mockSeconds = 10
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        sut.setTimerSeconds(mockSeconds)
        
        // then
        let selectedSeconds = sut.selectedMinutes
        XCTAssertEqual(selectedSeconds, mockSeconds)
    }
    
    func testNumberOfSections_whenViewModelIsAllocated_returnsTeamSectionCasesMinusBench() {
        // given
        let expectedNumberOfSections = TeamSection.allCases.filter { $0 != .bench }.count
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let numberOfSections = sut.numberOfSections
        
        // then
        XCTAssertEqual(numberOfSections, expectedNumberOfSections)
    }
    
    func testNumberOfRowsInSection_whenViewModelHasPlayers_returnsCorrectNumberOfPlayers() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 5)
        let teamAPlayersCount = mockGatherModel.players.filter { $0.team == .teamA}.count
        let teamBPlayersCount = mockGatherModel.players.filter { $0.team == .teamB}.count
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let numberOfRowsInSection0 = sut.numberOfRowsInSection(0)
        let numberOfRowsInSection1 = sut.numberOfRowsInSection(1)
        
        // then
        XCTAssertEqual(numberOfRowsInSection0, teamAPlayersCount)
        XCTAssertEqual(numberOfRowsInSection1, teamBPlayersCount)
    }
    
    func testTitleForHeaderInSection_whenSectionIsZero_returnsTeamAHeader() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let titleForHeaderInSection = sut.titleForHeaderInSection(0)
        
        // then
        XCTAssertEqual(titleForHeaderInSection, TeamSection.teamA.headerTitle)
    }
    
    func testTitleForHeaderInSection_whenSectionIsOne_returnsTeamBHeader() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let titleForHeaderInSection = sut.titleForHeaderInSection(1)
        
        // then
        XCTAssertEqual(titleForHeaderInSection, TeamSection.teamB.headerTitle)
    }
    
    func testRowDescription_whenViewModelHasPlayers_returnsPlayerDetails() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let expectedPlayer = mockGatherModel.players.filter { $0.team == .teamA }.first?.player
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let rowDescription = sut.rowDescription(at: IndexPath(row: 0, section: 0))
        
        // then
        XCTAssertEqual(rowDescription.title, expectedPlayer?.name)
        XCTAssertEqual(rowDescription.details, expectedPlayer?.preferredPosition?.acronym)
    }
    
    func testFormatStepperValue_whenValueIsNotNil_returnsValueAsString() {
        // given
        let mockDoubleValue = 10.0
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let stepperValue = sut.formatStepperValue(mockDoubleValue)
        
        // then
        XCTAssertEqual(stepperValue, "\(Int(mockDoubleValue))")
    }
    
    func testShouldUpdateTeamALabel_whenSectionIsTeamA_isTrue() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let shouldUpdateTeamALabel = sut.shouldUpdateTeamALabel(section: .teamA)
        
        // then
        XCTAssertTrue(shouldUpdateTeamALabel)
    }
    
    func testShouldUpdateTeamALabel_whenSectionIsTeamB_isFalse() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let shouldUpdateTeamALabel = sut.shouldUpdateTeamALabel(section: .teamB)
        
        // then
        XCTAssertFalse(shouldUpdateTeamALabel)
    }
    
    func testShouldUpdateTeamBLabel_whenSectionIsTeamB_isTrue() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let shouldUpdateTeamBLabel = sut.shouldUpdateTeamBLabel(section: .teamB)
        
        // then
        XCTAssertTrue(shouldUpdateTeamBLabel)
    }
    
    func testShouldUpdateTeamBLabel_whenSectionIsTeamA_isFalse() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let shouldUpdateTeamBLabel = sut.shouldUpdateTeamBLabel(section: .teamA)
        
        // then
        XCTAssertFalse(shouldUpdateTeamBLabel)
    }
    
    func testNumberOfPickerComponents_whenViewModelIsAllocated_isEqualToTimeHandlerComponents() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let numberOfPickerComponents = sut.numberOfPickerComponents
        
        // then
        XCTAssertEqual(numberOfPickerComponents, GatherTimeHandler.Component.allCases.count)
    }
    
    func testNumberOfRowsInPickerComponent_whenComponentIsMinutes_returns60() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let numberOfRowsInPickerComponent = sut.numberOfRowsInPickerComponent(GatherTimeHandler.Component.minutes.rawValue)
        
        // then
        XCTAssertEqual(numberOfRowsInPickerComponent, 60)
    }
    
    func testNumberOfRowsInPickerComponent_whenComponentIsSeconds_returns60() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let numberOfRowsInPickerComponent = sut.numberOfRowsInPickerComponent(GatherTimeHandler.Component.seconds.rawValue)
        
        // then
        XCTAssertEqual(numberOfRowsInPickerComponent, 60)
    }
    
    func testNumberOfRowsInPickerComponent_whenComponentIsInvalid_returnsZero() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let numberOfRowsInPickerComponent = sut.numberOfRowsInPickerComponent(-1)
        
        // then
        XCTAssertEqual(numberOfRowsInPickerComponent, 0)
    }
    
    func testTitleForPickerRow_whenComponentIsInvalid_isNil() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let titleForPickerRow = sut.titleForPickerRow(0, forComponent: -1)
        
        // then
        XCTAssertNil(titleForPickerRow)
    }
    
    func testTitleForPickerRow_whenComponentIsMinutes_returnsRowAndMinutes() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let titleForPickerRow = sut.titleForPickerRow(15, forComponent: GatherTimeHandler.Component.minutes.rawValue)
        
        // then
        XCTAssertEqual(titleForPickerRow, "15 min")
    }
    
    func testTitleForPickerRow_whenComponentIsSeconds_returnsRowAndSeconds() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let sut = GatherViewModel(gatherModel: mockGatherModel)
        
        // when
        let titleForPickerRow = sut.titleForPickerRow(15, forComponent: GatherTimeHandler.Component.seconds.rawValue)
        
        // then
        XCTAssertEqual(titleForPickerRow, "15 sec")
    }
    
    func testEndGather_whenScoreIsSet_updatesGather() {
        // given
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let mockEndpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: resourcePath)
        let mockService = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: mockEndpoint, keychain: appKeychain))
        let sut = GatherViewModel(gatherModel: mockGatherModel, updateGatherService: mockService)
        let exp = expectation(description: "Update gather expectation")
        
        // when
        sut.endGather(teamAScoreLabelText: "1", teamBScoreLabelText: "1") { gatherUpdated in
            XCTAssertTrue(gatherUpdated)
            exp.fulfill()
        }
        
        // then
        waitForExpectations(timeout: 5, handler: nil)
    }
    
}

// MARK: - Mocks
private extension GatherViewModelTests {
    final class MockViewModelDelegate: GatherViewModelDelegate {
        private(set) var gatherTimeWasUpdated = false
        
        weak var expectation: XCTestExpectation? = nil
        var numberOfUpdateCalls = 1
        private(set) var actualUpdateCalls = 0
        
        func didUpdateGatherTime() {
            gatherTimeWasUpdated = true
            actualUpdateCalls += 1
            
            if expectation != nil && numberOfUpdateCalls == actualUpdateCalls {
                expectation?.fulfill()
            }
        }
    }
}

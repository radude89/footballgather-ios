//
//  GatherInteractorTests.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 05/05/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class GatherInteractorTests: XCTestCase {
    
    
    func testTeamSections_whenInteractorIsAllocated_equalsTeamAandTeamB() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let teamSections = sut.teamSections
        
        // then
        XCTAssertEqual(teamSections, [.teamA, .teamB])
    }
    
    func testTeamSection_whenIndexIsZero_equalsTeamA() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let teamSection = sut.teamSection(at: 0)
        
        // then
        XCTAssertEqual(teamSection, .teamA)
    }
    
    func testTeamSection_whenIndexIsOne_equalsTeamB() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let teamSection = sut.teamSection(at: 1)
        
        // then
        XCTAssertEqual(teamSection, .teamB)
    }
    
    func testPlayersInTeam_whenInteractorHasPlayers_returnsPlayersForTheGivenTeam() {
        // given
        let mockGather = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let expectedPlayers = mockGather.players.filter { $0.team == .teamA }.compactMap { $0.player }
        let sut = GatherInteractor(gather: mockGather)
        
        // when
        let players = sut.players(in: .teamA)
        
        // then
        XCTAssertEqual(players, expectedPlayers)
    }

    func testEndGather_whenScoreIsSet_updatesGather() {
        // given
        let appKeychain = AppKeychainMockFactory.makeKeychain()
        appKeychain.token = ModelsMock.token
        let session = URLSessionMockFactory.makeSession()
        
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let mockEndpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: "/api/gathers")
        let mockService = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: mockEndpoint, keychain: appKeychain))
        let mockPresenter = GatherMockPresenter()
        let exp = expectation(description: "Update gather expectation")
        mockPresenter.expectation = exp
        let sut = GatherInteractor(gather: mockGatherModel, updateGatherService: mockService)
        sut.presenter = mockPresenter
        
        // when
        sut.endGather(score: "1-1", winnerTeam: "None")
        
        // then
        waitForExpectations(timeout: 5) { _ in
            XCTAssertTrue(mockPresenter.gatherEndedCalled)
            appKeychain.storage.removeAll()
        }
    }
    
    func testEndGather_whenScoreIsNotSet_updatesGather() {
        // given
        let appKeychain = AppKeychainMockFactory.makeKeychain()
        appKeychain.token = ModelsMock.token
        let session = URLSessionMockFactory.makeSession()
        
        let mockGatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 2)
        let mockEndpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: "/api/gathers")
        let mockService = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: mockEndpoint, keychain: appKeychain))
        let mockPresenter = GatherMockPresenter()
        let exp = expectation(description: "Update gather expectation")
        mockPresenter.expectation = exp
        let sut = GatherInteractor(gather: mockGatherModel, updateGatherService: mockService)
        sut.presenter = mockPresenter
        
        // when
        sut.endGather(score: "", winnerTeam: "")
        
        // then
        waitForExpectations(timeout: 5) { _ in
            XCTAssertTrue(mockPresenter.serviceFailedCalled)
            appKeychain.storage.removeAll()
        }
    }
    
    func testMinutesComponent_whenInteractorIsAllocated_isMinutes() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let minutesComponent = sut.minutesComponent
        
        // then
        XCTAssertEqual(minutesComponent, .minutes)
    }
    
    func testSecondsComponent_whenInteractorIsAllocated_isSeconds() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let secondsComponent = sut.secondsComponent
        
        // then
        XCTAssertEqual(secondsComponent, .seconds)
    }
    
    func testSelectedTime_whenInteractorIsAllocated_isDefaultTime() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let selectedTime = sut.selectedTime
        
        // then
        XCTAssertEqual(selectedTime.minutes, GatherTime.defaultTime.minutes)
        XCTAssertEqual(selectedTime.seconds, GatherTime.defaultTime.seconds)
    }
    
    func testTimerState_whenInteractorIsAllocated_isStopped() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let timerState = sut.timerState
        
        // then
        XCTAssertEqual(timerState, .stopped)
    }
    
    func testTimeComponent_whenIndexIsZero_isMinutes() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let timeComponent = sut.timeComponent(at: 0)
        
        // then
        XCTAssertEqual(timeComponent, .minutes)
    }
    
    func testTimeComponent_whenIndexIsOne_isSeconds() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        let timeComponent = sut.timeComponent(at: 1)
        
        // then
        XCTAssertEqual(timeComponent, .seconds)
    }
    
    func testStopTimer_whenStateIsRunning_isStopped() {
        // given
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeHandler: GatherTimeHandler(state: .running))
        
        // when
        sut.stopTimer()
        
        // then
        XCTAssertEqual(sut.timerState, .stopped)
    }
    
    func testUpdateTimer_whenGatherTimeIsDifferent_updatesSelectedTime() {
        // given
        let mockSelectedTime = GatherTime(minutes: 99, seconds: 101)
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()))
        
        // when
        sut.updateTime(mockSelectedTime)
        
        // then
        XCTAssertEqual(sut.selectedTime.minutes, mockSelectedTime.minutes)
        XCTAssertEqual(sut.selectedTime.seconds, mockSelectedTime.seconds)
    }
    
    func testToggleTimer_whenTimeIsValid_decrementsTime() {
        // given
        let numberOfUpdateCalls = 2
        let mockSelectedTime = GatherTime(minutes: 0, seconds: numberOfUpdateCalls)
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeHandler: GatherTimeHandler(selectedTime: mockSelectedTime))
        
        let mockPresenter = GatherMockPresenter()
        let exp = expectation(description: "Update gather expectation")
        mockPresenter.expectation = exp
        mockPresenter.numberOfUpdateCalls = numberOfUpdateCalls
        
        sut.presenter = mockPresenter
        
        // when
        sut.toggleTimer()
        
        // then
        waitForExpectations(timeout: 5) { _ in
            XCTAssertTrue(mockPresenter.timerDecrementedCalled)
            XCTAssertEqual(mockPresenter.actualUpdateCalls, numberOfUpdateCalls)
            sut.stopTimer()
        }
    }
    
    func testToggleTimer_whenTimeIsInvalid_returns() {
        // given
        let mockSelectedTime = GatherTime(minutes: -1, seconds: -1)
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeHandler: GatherTimeHandler(selectedTime: mockSelectedTime))
        let mockPresenter = GatherMockPresenter()
        sut.presenter = mockPresenter
        
        // when
        sut.toggleTimer()
        
        // then
        XCTAssertFalse(mockPresenter.timerDecrementedCalled)
    }
    
    func testResetTimer_whenInteractorIsAllocated_resetsTime() {
        // given
        let numberOfUpdateCalls = 1
        let mockSelectedTime = GatherTime(minutes: 0, seconds: numberOfUpdateCalls)
        let sut = GatherInteractor(gather: GatherModel(players: [], gatherUUID: UUID()), timeHandler: GatherTimeHandler(selectedTime: mockSelectedTime))
        
        let mockPresenter = GatherMockPresenter()
        let exp = expectation(description: "Update gather expectation")
        mockPresenter.expectation = exp
        mockPresenter.numberOfUpdateCalls = numberOfUpdateCalls
        
        sut.presenter = mockPresenter
        
        // when
        sut.toggleTimer()
        waitForExpectations(timeout: 5) { _ in
            XCTAssertTrue(mockPresenter.timerDecrementedCalled)
            XCTAssertEqual(mockPresenter.actualUpdateCalls, numberOfUpdateCalls)
            XCTAssertEqual(sut.selectedTime.minutes, mockSelectedTime.minutes)
            XCTAssertNotEqual(sut.selectedTime.seconds, mockSelectedTime.seconds)
            sut.resetTimer()
            
            // then
            XCTAssertEqual(sut.selectedTime.minutes, mockSelectedTime.minutes)
            XCTAssertEqual(sut.selectedTime.seconds, mockSelectedTime.seconds)
            sut.stopTimer()
        }
    }
 
}

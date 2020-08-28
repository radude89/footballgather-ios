//
//  GatherPresenterTests.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 11/08/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
@testable import FootballGather

final class GatherPresenterTests: XCTestCase {
    
    // MARK: - View Configuration
    func testPresentSelectedRows_whenResponseHasMinutes_displaysSelectedRow() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentSelectedRows(response: Gather.SelectRows.Response(minutes: 1, minutesComponent: 1))
        
        // then
        XCTAssertTrue(mockView.selectedRowWasDisplayed)
        XCTAssertEqual(mockView.pickerRow, 1)
        XCTAssertEqual(mockView.pickerComponent, 1)
    }
    
    func testPresentSelectedRows_whenResponseHasSeconds_displaysSelectedRow() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentSelectedRows(response: Gather.SelectRows.Response(seconds: 15, secondsComponent: 45))
        
        // then
        XCTAssertTrue(mockView.selectedRowWasDisplayed)
        XCTAssertEqual(mockView.pickerRow, 15)
        XCTAssertEqual(mockView.pickerComponent, 45)
    }

    func testFormatTime_whenResponseIsGiven_formatsTime() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.formatTime(response: Gather.FormatTime.Response(selectedTime: GatherTime(minutes: 1, seconds: 21)))
        
        // then
        XCTAssertTrue(mockView.timeWasFormatted)
        XCTAssertEqual(mockView.formattedTime, "01:21")
    }
    
    func testPresentActionButton_whenStateIsPaused_displaysResumeActionButtonTitle() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentActionButton(response: Gather.ConfigureActionButton.Response(timerState: .paused))
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Resume")
    }
    
    func testPresentActionButton_whenStateIsRunning_displaysPauseActionButtonTitle() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentActionButton(response: Gather.ConfigureActionButton.Response(timerState: .running))
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Pause")
    }
    
    func testPresentActionButton_whenStateIsStopped_displaysStartActionButtonTitle() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentActionButton(response: Gather.ConfigureActionButton.Response(timerState: .stopped))
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Start")
    }
    
    func testPresentEndGatherConfirmationAlert_whenResponseIsGiven_alertIsDisplayed() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentEndGatherConfirmationAlert(response: Gather.EndGather.Response())
        
        // then
        XCTAssertTrue(mockView.confirmationAlertDisplayed)
    }
    
    func testPresentTimerView_whenResponseIsGive_timerViewIsVisible() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentTimerView(response: Gather.SetTimer.Response())
        
        // then
        XCTAssertTrue(mockView.timerViewIsVisible!)
    }
 
    func testDisplayCancelTimer_whenSelectedTimeIsGiven_displaysCancelledTimer() {
        // given
        let mockGatherTime = GatherTime(minutes: 21, seconds: 32)
        let mockResponse = Gather.CancelTimer.Response(selectedTime: mockGatherTime,
                                                       timerState: .paused)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.cancelTimer(response: mockResponse)
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Resume")
        XCTAssertEqual(mockView.formattedTime, "21:32")
        XCTAssertFalse(mockView.timerViewIsVisible!)
        XCTAssertTrue(mockView.cancelTimerIsDisplayed)
    }
    
    func testPresentToggleTimer_whenResponseIsGiven_displaysActionButtonTitle() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentToggledTimer(response: Gather.ActionTimer.Response(timerState: .running))
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Pause")
    }
    
    func testHideTimer_whenPresenterIsAllocated_timerViewIsNotVisible() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.hideTimer()
        
        // then
        XCTAssertFalse(mockView.timerViewIsVisible!)
    }
    
    func testPresentUpdatedTime_whenSelectedTimeIsGiven_displaysUpdatedTimer() {
        // given
        let mockGatherTime = GatherTime(minutes: 1, seconds: 5)
        let mockResponse = Gather.TimerDidFinish.Response(selectedTime: mockGatherTime,
                                                          timerState: .stopped)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentUpdatedTime(response: mockResponse)
        
        // then
        XCTAssertEqual(mockView.actionButtonTitle, "Start")
        XCTAssertEqual(mockView.formattedTime, "01:05")
        XCTAssertFalse(mockView.timerViewIsVisible!)
        XCTAssertTrue(mockView.updatedTimerIsDisplayed)
    }
    
    func testPopToPlayerListView_whenPresenterIsAllocated_hidesLoadingViewAndPopsToPlayerListView() {
        // given
        let mockView = GatherMockView()
        mockView.showLoadingView()
        
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.popToPlayerListView()
        
        // then
        XCTAssertFalse(mockView.loadingViewIsVisible)
        XCTAssertTrue(mockView.poppedToPlayerListView)
    }
    
    func testPresentError_whenResponseIsGiven_displaysError() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.presentError(response: Gather.ErrorResponse(error: .endGatherError))
                
        // then
        XCTAssertTrue(mockView.errorWasHandled)
    }
    
    func testDisplayTeamScore_when_displaysScore() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        sut.displayTeamScore(response: Gather.UpdateValue.Response(teamSection: .teamA, newValue: 1))
        sut.displayTeamScore(response: Gather.UpdateValue.Response(teamSection: .teamB, newValue: 15))
                
        // then
        XCTAssertEqual(mockView.teamAText, "1")
        XCTAssertEqual(mockView.teamBText, "15")
    }
    
    // MARK: - Table Delegate
    func testNumberOfSections_whenResponseIsGiven_returnsTeamSectionsCount() {
        // given
        let mockTeamSections: [TeamSection] = [.bench, .teamB, .teamA]
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let numberOfSections = sut.numberOfSections(response: Gather.SectionsCount.Response(teamSections: mockTeamSections))
                
        // then
        XCTAssertEqual(numberOfSections, mockTeamSections.count)
    }
    
    func testNumberOfRowsInSection_whenResponseIsGiven_returnsPlayersCount() {
        // given
        let mockPlayerResponseModel = PlayerResponseModel(id: -1, name: "mock-name")
        let mockResponse = Gather.RowsCount.Response(players: [mockPlayerResponseModel])
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let numberOfRows = sut.numberOfRowsInSection(response: mockResponse)
                
        // then
        XCTAssertEqual(numberOfRows, 1)
    }
    
    func testRowDetails_whenResponseIsGiven_returnsPlayerNameAndPreferredPositionAcronym() {
        // given
        let mockPlayerResponseModel = PlayerResponseModel(id: -1,
                                                          name: "mock-name",
                                                          preferredPosition: .goalkeeper)
        let mockResponse = Gather.RowDetails.Response(player: mockPlayerResponseModel)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let rowDetails = sut.rowDetails(response: mockResponse)
                
        // then
        XCTAssertEqual(rowDetails.titleLabelText, mockPlayerResponseModel.name)
        XCTAssertEqual(rowDetails.descriptionLabelText, mockPlayerResponseModel.preferredPosition!.acronym)
    }
    
    func testRowDetails_whenPositionIsNil_descriptionLabelIsDash() {
        // given
        let mockPlayerResponseModel = PlayerResponseModel(id: -1,
                                                          name: "mock-name")
        let mockResponse = Gather.RowDetails.Response(player: mockPlayerResponseModel)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let rowDetails = sut.rowDetails(response: mockResponse)
                
        // then
        XCTAssertEqual(rowDetails.descriptionLabelText, "-")
    }
    
    func testTitleForHeaderInSection_whenTeamSectionIsA_returnsTeamAHeaderTitle() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let title = sut.titleForHeaderInSection(response: Gather.SectionTitle.Response(teamSection: .teamA)).title
                
        // then
        XCTAssertEqual(title, TeamSection.teamA.headerTitle)
    }
    
    func testTitleForHeaderInSection_whenTeamSectionIsB_returnsTeamBHeaderTitle() {
        // given
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let title = sut.titleForHeaderInSection(response: Gather.SectionTitle.Response(teamSection: .teamB)).title
                
        // then
        XCTAssertEqual(title, TeamSection.teamB.headerTitle)
    }

    // MARK: - Picker Delegate
    func testNumberOfPickerComponents_whenResponseIsGiven_returnsTimeComponentsCount() {
        // given
        let mockTimeComponents: [GatherTimeHandler.Component] = [.minutes, .seconds]
        let mockResponse = Gather.PickerComponents.Response(timeComponents: mockTimeComponents)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let numberOfPickerComponents = sut.numberOfPickerComponents(response: mockResponse)
                
        // then
        XCTAssertEqual(numberOfPickerComponents, mockTimeComponents.count)
    }
    
    func testNumberOfPickerRows_whenComponentIsMinutes_returnsNumberOfSteps() {
        // given
        let mockResponse = Gather.PickerRows.Response(timeComponent: .minutes)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let numberOfPickerRows = sut.numberOfPickerRows(response: mockResponse)
                
        // then
        XCTAssertEqual(numberOfPickerRows, GatherTimeHandler.Component.minutes.numberOfSteps)
    }
    
    func testNumberOfPickerRows_whenComponentIsSeconds_returnsNumberOfSteps() {
        // given
        let mockResponse = Gather.PickerRows.Response(timeComponent: .seconds)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let numberOfPickerRows = sut.numberOfPickerRows(response: mockResponse)
                
        // then
        XCTAssertEqual(numberOfPickerRows, GatherTimeHandler.Component.seconds.numberOfSteps)
    }
    
    func testTitleForRow_whenTimeComponentIsMinutes_containsRowAndTimeComponentShort() {
        // given
        let mockResponse = Gather.PickerRowTitle.Response(timeComponent: .minutes, row: 5)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let titleForRow = sut.titleForRow(response: mockResponse).title
                
        // then
        XCTAssertTrue(titleForRow.contains("\(mockResponse.row)"))
        XCTAssertTrue(titleForRow.contains("\(mockResponse.timeComponent.short)"))
    }
    
    func testTitleForRow_whenTimeComponentIsSeconds_containsRowAndTimeComponentShort() {
        // given
        let mockResponse = Gather.PickerRowTitle.Response(timeComponent: .seconds, row: 11)
        let mockView = GatherMockView()
        let sut = GatherPresenter(view: mockView)
        
        // when
        let titleForRow = sut.titleForRow(response: mockResponse).title
                
        // then
        XCTAssertTrue(titleForRow.contains("\(mockResponse.row)"))
        XCTAssertTrue(titleForRow.contains("\(mockResponse.timeComponent.short)"))
    }

}

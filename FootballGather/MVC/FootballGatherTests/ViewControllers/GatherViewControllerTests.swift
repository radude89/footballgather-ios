//
//  GatherViewControllerTests.swift
//  FootballGatherTests
//
//  Created by Radu Dan on 13/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import XCTest
import UIKit
@testable import FootballGather

final class GatherViewControllerTests: XCTestCase {
    
    var sut: GatherViewController!
    
    private let gatherModel = ModelsMockFactory.makeGatherModel(numberOfPlayers: 4)
    private let session = URLSessionMockFactory.makeSession()
    private let resourcePath = "/api/gathers"
    private let appKeychain = AppKeychainMockFactory.makeKeychain()
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(identifier: "GatherViewController") as? GatherViewController {
            sut = viewController
            sut.model = gatherModel
            _ = sut.view
        } else {
            XCTFail("Unable to instantiate GatherViewController")
        }
        
        appKeychain.token = ModelsMock.token
    }
    
    override func tearDown() {
        sut.timeHandler.stopTimer()
        appKeychain.storage.removeAll()
        super.tearDown()
    }
    
    func testOutlets_whenViewControllerIsLoadedFromStoryboard_areNotNil() {
        XCTAssertNotNil(sut.playerTableView)
        XCTAssertNotNil(sut.scoreLabelView)
        XCTAssertNotNil(sut.scoreStepper)
        XCTAssertNotNil(sut.timerLabel)
        XCTAssertNotNil(sut.timerView)
        XCTAssertNotNil(sut.timePickerView)
        XCTAssertNotNil(sut.actionTimerButton)
    }
    
    func testViewDidLoad_whenViewControllerIsLoadedFromStoryboard_setsVariables() {
        XCTAssertNotNil(sut.title)
        XCTAssertTrue(sut.timerView.isHidden)
        XCTAssertNotNil(sut.timePickerView.delegate)
    }
    
    func testNumberOfSections_whenGatherModelIsSet_returnsTwoTeams() {
        XCTAssert(sut.playerTableView?.numberOfSections == TeamSection.allCases.count - 1)
    }
    
    func testTitleForHeaderInSection_whenSectionIsTeamAAndGatherModelIsSet_returnsTeamATitleHeader() {
        let teamASectionTitle = sut.tableView(sut.playerTableView, titleForHeaderInSection: 0)
        XCTAssertEqual(teamASectionTitle, TeamSection.teamA.headerTitle)
    }
    
    func testTitleForHeaderInSection_whenSectionIsTeamBAndGatherModelIsSet_returnsTeamBTitleHeader() {
        let teamBSectionTitle = sut.tableView(sut.playerTableView, titleForHeaderInSection: 1)
        XCTAssertEqual(teamBSectionTitle, TeamSection.teamB.headerTitle)
    }
    
    func testNumberOfRowsInSection_whenTeamIsA_returnsNumberOfPlayersInTeamA() {
        let expectedTeamAPlayersCount = gatherModel.players.filter { $0.team == .teamA }.count
        XCTAssertEqual(sut.playerTableView.numberOfRows(inSection: 0), expectedTeamAPlayersCount)
    }
    
    func testNumberOfRowsInSection_whenTeamIsB_returnsNumberOfPlayersInTeamB() {
        let expectedTeamBPlayersCount = gatherModel.players.filter { $0.team == .teamB }.count
        XCTAssertEqual(sut.playerTableView.numberOfRows(inSection: 1), expectedTeamBPlayersCount)
    }
    
    func testNumberOfRowsInSection_whenGatherModelIsNil_returnsZero() {
        sut.model = nil
        XCTAssertEqual(sut.tableView(sut.playerTableView, numberOfRowsInSection: -1), 0)
    }
    
    func testCellForRowAtIndexPath_whenSectionIsTeamA_setsCellDetails() {
        let indexPath = IndexPath(row: 0, section: 0)
        let playerTeams = gatherModel.players.filter({ $0.team == .teamA })
        let player = playerTeams[indexPath.row].player
        
        let cell = sut.playerTableView.cellForRow(at: indexPath)
        
        XCTAssertEqual(cell?.textLabel?.text, player.name)
        XCTAssertEqual(cell?.detailTextLabel?.text, player.preferredPosition?.acronym)
    }
    
    func testCellForRowAtIndexPath_whenSectionIsTeamB_setsCellDetails() {
        let indexPath = IndexPath(row: 0, section: 1)
        let playerTeams = gatherModel.players.filter({ $0.team == .teamB })
        let player = playerTeams[indexPath.row].player
        
        let cell = sut.playerTableView.cellForRow(at: indexPath)
        
        XCTAssertEqual(cell?.textLabel?.text, player.name)
        XCTAssertEqual(cell?.detailTextLabel?.text, player.preferredPosition?.acronym)
    }
    
    func testPickerViewNumberOfComponents_returnsAllCountDownCases() {
        XCTAssertEqual(sut.timePickerView.numberOfComponents, GatherTimeHandler.Component.allCases.count)
    }
    
    func testPickerViewNumberOfRowsInComponent_whenComponentIsInvalid_returnsZero() {
        let numberOfRows = sut.pickerView(sut.timePickerView, numberOfRowsInComponent: -1)
        
        XCTAssertEqual(numberOfRows, 0)
    }
    
    func testPickerViewNumberOfRowsInComponent_whenComponentIsMinutes_returns60() {
        let minutesComponent = GatherTimeHandler.Component.minutes.rawValue
        let numberOfRows = sut.pickerView(sut.timePickerView, numberOfRowsInComponent: minutesComponent)
        
        XCTAssertEqual(numberOfRows, 60)
    }
    
    func testPickerViewNumberOfRowsInComponent_whenComponentIsSecounds() {
        let secondsComponent = GatherTimeHandler.Component.seconds.rawValue
        let numberOfRows = sut.pickerView(sut.timePickerView, numberOfRowsInComponent: secondsComponent)
        
        XCTAssertEqual(numberOfRows, 60)
    }
    
    func testPickerViewTitleForRow_whenComponentIsInvalid_isNil() {
        let title = sut.pickerView(sut.timePickerView, titleForRow: 0, forComponent: -1)
        
        XCTAssertNil(title)
    }
    
    func testPickerViewTitleForRow_whenComponentIsMinutes_containsMin() {
        let minutesComponent = GatherTimeHandler.Component.minutes.rawValue
        let title = sut.pickerView(sut.timePickerView, titleForRow: 0, forComponent: minutesComponent)
        
        XCTAssertTrue(title!.contains("min"))
    }
    
    func testPickerViewTitleForRow_whenComponentIsSeconds_containsSec() {
        let secondsComponent = GatherTimeHandler.Component.seconds.rawValue
        let title = sut.pickerView(sut.timePickerView, titleForRow: 0, forComponent: secondsComponent)
        
        XCTAssertTrue(title!.contains("sec"))
    }
    
    func testSetTimer_whenActionIsSent_showsTimerView() {
        sut.setTimer(UIButton())
        XCTAssertFalse(sut.timerView.isHidden)
    }
    
    func testCancelTimer_whenActionIsSent_hidesTimerView() {
        sut.cancelTimer(UIButton())
        XCTAssertTrue(sut.timerView.isHidden)
    }
    
    func testTimerCancel_whenActionIsSent_hidesTimerView() {
        sut.timerCancel(UIButton())
        XCTAssertTrue(sut.timerView.isHidden)
    }
    
    func testTimerDone_whenActionIsSent_hidesTimerViewAndSetsMinutesAndSeconds() {
        sut.timerDone(UIButton())        
        
        let minutes = sut.timePickerView.selectedRow(inComponent: GatherTimeHandler.Component.minutes.rawValue)
        let seconds = sut.timePickerView.selectedRow(inComponent: GatherTimeHandler.Component.seconds.rawValue)

        XCTAssertTrue(sut.timerView.isHidden)
        XCTAssertGreaterThan(minutes, 0)
        XCTAssertEqual(seconds, 0)
    }
    
    func testActionTimer_whenSelectedTimeIsZero_returns() {
        let minutesComponent = GatherTimeHandler.Component.minutes.rawValue
        let secondsComponent = GatherTimeHandler.Component.seconds.rawValue
        
        sut.timePickerView.selectRow(0, inComponent: minutesComponent, animated: false)
        sut.timePickerView.selectRow(0, inComponent: secondsComponent, animated: false)
        sut.timerDone(UIButton())
        sut.actionTimer(UIButton())
        
        XCTAssertEqual(sut.timePickerView.selectedRow(inComponent: minutesComponent), 0)
        XCTAssertEqual(sut.timePickerView.selectedRow(inComponent: secondsComponent), 0)
    }
    
    func testActionTimer_whenSelectedTimeIsSet_updatesTimer() {
        // given
        let minutesComponent = GatherTimeHandler.Component.minutes.rawValue
        let secondsComponent = GatherTimeHandler.Component.seconds.rawValue
        
        sut.timePickerView.selectRow(0, inComponent: minutesComponent, animated: false)
        // set to 1 second
        sut.timePickerView.selectRow(1, inComponent: secondsComponent, animated: false)
        
        // initial state
        sut.timerDone(UIButton())
        XCTAssertEqual(sut.actionTimerButton.title(for: .normal), "Start")
        
        // when
        sut.actionTimer(UIButton())
        
        // then
        XCTAssertEqual(sut.actionTimerButton.title(for: .normal), "Pause")
        
        // make sure timer is resetted
        let exp = expectation(description: "Timer expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            XCTAssertEqual(self.sut.actionTimerButton.title(for: .normal), "Start")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testActionTimer_whenTimerIsSetAndRunning_isPaused() {
        // given
        let sender = UIButton()
        let minutesComponent = GatherTimeHandler.Component.minutes.rawValue
        let secondsComponent = GatherTimeHandler.Component.seconds.rawValue
        
        sut.timePickerView.selectRow(0, inComponent: minutesComponent, animated: false)
        sut.timePickerView.selectRow(3, inComponent: secondsComponent, animated: false)
        
        // initial state
        sut.timerDone(sender)
        XCTAssertEqual(sut.actionTimerButton.title(for: .normal), "Start")
        sut.actionTimer(sender)
        
        // when
        let exp = expectation(description: "Timer expectation")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.sut.actionTimer(sender)
            XCTAssertEqual(self.sut.actionTimerButton.title(for: .normal), "Resume")
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testUpdateTimer_whenSecondsReachZero_decrementsMinuteComponent() {
        let sender = UIButton()
        let timer = Timer()
        let minutesComponent = GatherTimeHandler.Component.minutes.rawValue
        let secondsComponent = GatherTimeHandler.Component.seconds.rawValue
        
        sut.timePickerView.selectRow(1, inComponent: minutesComponent, animated: false)
        sut.timePickerView.selectRow(0, inComponent: secondsComponent, animated: false)
        sut.timerDone(sender)
        XCTAssertEqual(sut.timerLabel.text, "01:00")
        
        sut.updateTimer(timer)
        
        XCTAssertEqual(sut.timerLabel.text, "00:59")
    }
    
    func testStepperDidChangeValue_whenTeamAScores_updatesTeamAScoreLabel() {
        sut.scoreStepper.teamAStepper.value = 1
        sut.scoreStepper.teamAStepperValueChanged(UIButton())
        
        XCTAssertEqual(sut.scoreLabelView.teamAScoreLabel.text, "1")
        XCTAssertEqual(sut.scoreLabelView.teamBScoreLabel.text, "0")
    }
    
    func testStepperDidChangeValue_whenTeamBScores_updatesTeamBScoreLabel() {
        sut.scoreStepper.teamBStepper.value = 1
        sut.scoreStepper.teamBStepperValueChanged(UIButton())
        
        XCTAssertEqual(sut.scoreLabelView.teamAScoreLabel.text, "0")
        XCTAssertEqual(sut.scoreLabelView.teamBScoreLabel.text, "1")
    }
    
    func testStepperDidChangeValue_whenTeamIsBench_scoreIsNotUpdated() {
        sut.stepper(UIStepper(), didChangeValueForTeam: .bench, newValue: 1)
        
        XCTAssertEqual(sut.scoreLabelView.teamAScoreLabel.text, "0")
        XCTAssertEqual(sut.scoreLabelView.teamBScoreLabel.text, "0")
    }
    
    func testEndGather_whenActionIsTriggered_confirmationAlertIsPresented() {
        let window = UIWindow()
        window.addSubview(sut.view)
        
        sut.endGather(UIButton())
        
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
    }
    
    func testEndGather_whenScoreIsSet_updatesGather() {
        let playerListViewController = MockPlayerTogglableViewController()
        let window = UIWindow()
        let navController = UINavigationController(rootViewController: playerListViewController)
        window.rootViewController = navController
        window.makeKeyAndVisible()
        
        _ = playerListViewController.view
        XCTAssertTrue(playerListViewController.viewState)
        
        let exp = expectation(description: "Timer expectation")
        playerListViewController.viewStateExpectation = exp
        
        navController.pushViewController(sut, animated: false)
        
        // mocked endpoint expects a 1-1 score
        sut.scoreLabelView.teamAScoreLabel.text = "1"
        sut.scoreLabelView.teamBScoreLabel.text = "1"

        let endpoint = EndpointMockFactory.makeSuccessfulEndpoint(path: resourcePath)
        sut.updateGatherService = StandardNetworkService(session: session, urlRequest: AuthURLRequestFactory(endpoint: endpoint, keychain: appKeychain))

        sut.endGather(UIButton())
        let alertController = (sut.presentedViewController as! UIAlertController)
        alertController.tapButton(atIndex: 0)
        
        waitForExpectations(timeout: 5) { _ in
            XCTAssertFalse(playerListViewController.viewState)
        }
    }
}

private extension GatherViewControllerTests {
    final class MockPlayerTogglableViewController: UIViewController, PlayerListTogglable {
        weak var viewStateExpectation: XCTestExpectation?
        private(set) var viewState = true
        
        func toggleViewState() {
            viewState = !viewState
            viewStateExpectation?.fulfill()
        }
    }
}

private extension UIAlertController {
    typealias AlertHandler = @convention(block) (UIAlertAction) -> Void

    func tapButton(atIndex index: Int) {
        guard let block = actions[index].value(forKey: "handler") else { return }
        
        let handler = unsafeBitCast(block as AnyObject, to: AlertHandler.self)
        handler(actions[index])
    }
}

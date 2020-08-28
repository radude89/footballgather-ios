//
//  GatherProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 28/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol GatherRouterProtocol: AnyObject {
    func popToPlayerListView()
}

// MARK: - View
typealias GatherViewProtocol = GatherViewable & GatherViewConfigurable & GatherViewReloadable & GatherViewConfirmable & Loadable & ErrorHandler

protocol GatherViewable: AnyObject {
    var presenter: GatherPresenterProtocol! { get set }
}

protocol GatherViewConfigurable: AnyObject {
    var scoreDescription: String { get }
    var winnerTeamDescription: String { get }
    
    func configureTitle(_ title: String)
    func setupScoreStepper()
    func setActionButtonTitle(_ title: String)
    func setTimerViewVisibility(isHidden: Bool)
    func setTimerLabelText(_ text: String)
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool)
    func selectedRow(in component: Int) -> Int
    func setTeamALabelText(_ text: String)
    func setTeamBLabelText(_ text: String)
}

protocol GatherViewReloadable: AnyObject {
    func reloadData()
}

protocol GatherViewConfirmable: AnyObject {
    func displayConfirmationAlert()
}

protocol GatherTableViewCellProtocol: AnyObject {
    func setTextLabel(_ text: String?)
    func setDetailLabel(_ text: String?)
}

// MARK: - Delegate
protocol GatherDelegate: AnyObject {
    func didEndGather()
}

// MARK: - Presenter
typealias GatherPresenterProtocol = GatherPresentable & GatherPresenterViewConfiguration & GatherTableDataSource & GatherPickerDataSource & GatherStepperHandler & GatherPresenterActionable & GatherPresenterServiceInteractable & GatherPresenterServiceHandler

protocol GatherPresentable: AnyObject {
    var view: GatherViewProtocol? { get set }
    var interactor: GatherInteractorProtocol { get set }
    var router: GatherRouterProtocol { get set }
}

protocol GatherPresenterViewConfiguration: AnyObject {
    func viewDidLoad()
}

protocol GatherTableDataSource: AnyObject {
    var numberOfSections: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func rowTitle(at indexPath: IndexPath) -> String
    func rowDescription(at indexPath: IndexPath) -> String?
    func titleForHeaderInSection(_ section: Int) -> String?
}

protocol GatherPickerDataSource: AnyObject {
    var numberOfPickerComponents: Int { get }
    
    func numberOfRowsInPickerComponent(_ component: Int) -> Int
    func titleForPickerRow(_ row: Int, forComponent component: Int) -> String
}

protocol GatherStepperHandler: AnyObject {
    func updateValue(for team: TeamSection, with newValue: Double)
}

protocol GatherPresenterActionable: AnyObject {
    func requestToEndGather()
    func setTimer()
    func cancelTimer()
    func actionTimer()
    func timerCancel()
    func timerDone()
}

protocol GatherPresenterServiceInteractable: AnyObject {
    func endGather()
}

protocol GatherPresenterServiceHandler: AnyObject {
    func gatherEnded()
    func serviceFailedToEndGather()
    func timerDecremented()
}

protocol GatherTableViewCellPresenterProtocol {
    var view: GatherTableViewCellProtocol? { get set }
    
    func configure(title: String, descriptionDetails: String?)
}

// MARK: - Interactor
typealias GatherInteractorProtocol = GatherInteractable & GatherInteractorServiceHander & GatherInteractorTimeHandler

protocol GatherInteractable: AnyObject {
    var presenter: GatherPresenterServiceHandler? { get set }
}

protocol GatherInteractorServiceHander: AnyObject {
    var teamSections: [TeamSection] { get }
    
    func teamSection(at index: Int) -> TeamSection
    func players(in team: TeamSection) -> [PlayerResponseModel]
    func endGather(score: String, winnerTeam: String)
}

protocol GatherInteractorTimeHandler: AnyObject {
    var selectedTime: GatherTime { get }
    var timerState: GatherTimeHandler.State { get }
    var timeComponents: [GatherTimeHandler.Component] { get }
    var minutesComponent: GatherTimeHandler.Component? { get }
    var secondsComponent: GatherTimeHandler.Component? { get }
    
    func timeComponent(at index: Int) -> GatherTimeHandler.Component
    func stopTimer()
    func resetTimer()
    func toggleTimer()
    func updateTime(_ gatherTime: GatherTime)
}

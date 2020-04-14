//
//  ConfirmPlayersProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 27/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol ConfirmPlayersRouterProtocol: AnyObject {
    func showGatherView(for gather: GatherModel, delegate: GatherDelegate)
}

// MARK: - View
typealias ConfirmPlayersViewProtocol = ConfirmPlayersViewable & ConfirmPlayersViewConfigurable & Loadable & ErrorHandler

protocol ConfirmPlayersViewable: AnyObject {
    var presenter: ConfirmPlayersPresenterProtocol { get set }
}

protocol ConfirmPlayersViewConfigurable: AnyObject {
    func configureTitle(_ title: String)
    func tableViewIsEditing(_ isEditing: Bool)
    func setStartGatherButtonState(isEnabled: Bool)
}

protocol ConfirmPlayersTableViewCellProtocol: AnyObject {
    func setTextLabel(_ text: String?)
    func setDetailLabel(_ text: String?)
}

// MARK: - Delegate
protocol ConfirmPlayersDelegate: AnyObject {
    func didEndGather()
}

// MARK: - Presenter
typealias ConfirmPlayersPresenterProtocol = ConfirmPlayersPresentable & ConfirmPlayersPresenterViewConfiguration & ConfirmPlayersDataSource & ConfirmPlayersPresenterServiceInteractable & ConfirmPlayersPresenterServiceHandler

protocol ConfirmPlayersPresentable: AnyObject {
    var view: ConfirmPlayersViewProtocol? { get set }
    var interactor: ConfirmPlayersInteractorProtocol { get set }
    var router: ConfirmPlayersRouterProtocol { get set }
}

protocol ConfirmPlayersPresenterViewConfiguration: AnyObject {
    func viewDidLoad()
}

protocol ConfirmPlayersDataSource: AnyObject {
    var numberOfSections: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func titleForHeaderInSection(_ section: Int) -> String?
    func rowTitle(at indexPath: IndexPath) -> String?
    func rowDescription(at indexPath: IndexPath) -> String?
    func moveRowAt(sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

protocol ConfirmPlayersTableViewCellPresenterProtocol {
    var view: ConfirmPlayersTableViewCellProtocol? { get set }
    
    func configure(title: String?, descriptionDetails: String?)
}

protocol ConfirmPlayersPresenterServiceInteractable: AnyObject {
    func startGather()
}

protocol ConfirmPlayersPresenterServiceHandler: AnyObject {
    func createdGather(_ gather: GatherModel)
    func serviceFailedToStartGather()
}

// MARK: - Interactor
typealias ConfirmPlayersInteractorProtocol = ConfirmPlayersInteractable & ConfirmPlayersInteractorServiceHander

protocol ConfirmPlayersInteractable: AnyObject {
    var presenter: ConfirmPlayersPresenterProtocol? { get set }
}

protocol ConfirmPlayersInteractorServiceHander: AnyObject {
    var teamSections: [TeamSection] { get }
    var hasPlayersInBothTeams: Bool { get }
    
    func players(for teamSection: TeamSection) -> [PlayerResponseModel]
    func removePlayer(from sourceTeam: TeamSection, index: Int)
    func insertPlayer(_ player: PlayerResponseModel, at destinationTeam: TeamSection, index: Int)
    func startGather()
}

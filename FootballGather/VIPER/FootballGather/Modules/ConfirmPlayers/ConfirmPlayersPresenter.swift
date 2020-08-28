//
//  ConfirmPlayersPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - ConfirmPlayersPresenter
final class ConfirmPlayersPresenter: ConfirmPlayersPresentable {
    
    // MARK: - Properties
    weak var view: ConfirmPlayersViewProtocol?
    var interactor: ConfirmPlayersInteractorProtocol
    var router: ConfirmPlayersRouterProtocol
    weak var delegate: ConfirmPlayersDelegate?
    
    // MARK: - Init
    init(view: ConfirmPlayersViewProtocol? = nil,
         interactor: ConfirmPlayersInteractorProtocol = ConfirmPlayersInteractor(),
         router: ConfirmPlayersRouterProtocol = ConfirmPlayersRouter(),
         delegate: ConfirmPlayersDelegate? = nil) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }
    
}

// MARK: - View Configuration
extension ConfirmPlayersPresenter: ConfirmPlayersPresenterViewConfiguration {
    func viewDidLoad() {
        view?.configureTitle("Confirm Players")
        view?.tableViewIsEditing(true)
        view?.setStartGatherButtonState(isEnabled: false)
    }
}

// MARK: - Data Source
extension ConfirmPlayersPresenter: ConfirmPlayersDataSource {
    var numberOfSections: Int {
        interactor.teamSections.count
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        let teamSection = interactor.teamSections[section]
        return teamSection.headerTitle
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard let teamSection = TeamSection(rawValue: section) else {
            return 0
        }
        
        let players = interactor.players(for: teamSection)
        return players.count
    }
    
    func rowTitle(at indexPath: IndexPath) -> String? {
        guard let player = player(at: indexPath) else {
            return nil
        }
        
        return player.name
    }
    
    private func player(at indexPath: IndexPath) -> PlayerResponseModel? {
        guard let teamSection = TeamSection(rawValue: indexPath.section) else {
            return nil
        }
        
        let players = interactor.players(for: teamSection)
        
        if players.isEmpty {
            return nil
        }
        
        return players[indexPath.row]
    }
    
    func rowDescription(at indexPath: IndexPath) -> String? {
        guard let player = player(at: indexPath) else {
            return nil
        }
        
        return player.preferredPosition?.acronym
    }
    
    func moveRowAt(sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let sourceTeam = TeamSection(rawValue: sourceIndexPath.section),
            let player = player(at: sourceIndexPath),
            let destinationTeam = TeamSection(rawValue: destinationIndexPath.section) else {
                fatalError("Unable to move players")
        }
        
        interactor.removePlayer(from: sourceTeam, index: sourceIndexPath.row)
        interactor.insertPlayer(player, at: destinationTeam, index: destinationIndexPath.row)
        view?.setStartGatherButtonState(isEnabled: interactor.hasPlayersInBothTeams)
    }
}

// MARK: - Interactor
extension ConfirmPlayersPresenter: ConfirmPlayersPresenterServiceInteractable {
    func startGather() {
        view?.showLoadingView()
        interactor.startGather()
    }
}

// MARK: - Service Handler
extension ConfirmPlayersPresenter: ConfirmPlayersPresenterServiceHandler {
    func createdGather(_ gather: GatherModel) {
        view?.hideLoadingView()
        router.showGatherView(for: gather, delegate: self)
    }
    
    func serviceFailedToStartGather() {
        view?.hideLoadingView()
        view?.handleError(title: "Error", message: "Unable to create gather.")
    }
}

// MARK: - GatherDelegate
extension ConfirmPlayersPresenter: GatherDelegate {
    func didEndGather() {
        delegate?.didEndGather()
    }
}

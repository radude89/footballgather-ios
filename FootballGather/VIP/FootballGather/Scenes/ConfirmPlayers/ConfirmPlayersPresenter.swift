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
    
    private let teamSections: [TeamSection]
    
    // MARK: - Init
    init(view: ConfirmPlayersViewProtocol? = nil,
         teamSections: [TeamSection] = TeamSection.allCases) {
        self.view = view
        self.teamSections = teamSections
    }
    
}

// MARK: - Actionable
extension ConfirmPlayersPresenter: ConfirmPlayersPresenterActionable {
    func showGatherView(response: ConfirmPlayers.StartGather.Response) {
        view?.hideLoadingView()
        view?.showGatherView(gather: response.gather, delegate: response.delegate)
    }
    
    func presentError(response: ConfirmPlayers.ErrorResponse) {
        view?.hideLoadingView()
        
        let viewModel = ConfirmPlayers.ErrorViewModel(errorTitle: "Error",
                                                 errorMessage: "Unable to create gather.")
        view?.displayError(viewModel: viewModel)
    }
}

// MARK: - Table Delegate
extension ConfirmPlayersPresenter: ConfirmPlayersTableDelegate {
    func numberOfSections(response: ConfirmPlayers.SectionsCount.Response) -> Int {
        teamSections.count
    }
    
    func numberOfRowsInSection(response: ConfirmPlayers.RowsCount.Response) -> Int {
        response.players.count
    }
    
    func titleForHeaderInSection(response: ConfirmPlayers.SectionTitle.Response) -> ConfirmPlayers.SectionTitle.ViewModel {
        let headerTitle = teamSections[response.section].headerTitle
        let viewModel = ConfirmPlayers.SectionTitle.ViewModel(title: headerTitle)
        return viewModel
    }
    
    func rowDetails(response: ConfirmPlayers.RowDetails.Response) -> ConfirmPlayers.RowDetails.ViewModel? {
        guard let player = response.player else {
            return nil
        }
        
        let playerName = player.name
        let preferredPosition = player.preferredPosition?.acronym
        
        return ConfirmPlayers.RowDetails.ViewModel(titleLabelText: playerName,
                                                   descriptionLabelText: preferredPosition ?? "-")
    }
    
    func move(response: ConfirmPlayers.Move.Response) {
        let startGatherButtonIsEnabled = response.hasPlayersInBothTeams
        let viewModel = ConfirmPlayers.Move.ViewModel(startGatherButtonIsEnabled: startGatherButtonIsEnabled)
        view?.configureStartGatherButton(viewModel: viewModel)
    }
}

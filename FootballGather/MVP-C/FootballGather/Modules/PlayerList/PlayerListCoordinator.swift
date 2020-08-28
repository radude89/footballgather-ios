//
//  PlayerListCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 19/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerListCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    private let navController: UINavigationController
    private var playerListViewController: PlayerListViewController?
    
    init(navController: UINavigationController, parent: Coordinator? = nil) {
        self.navController = navController
        self.parent = parent
    }
    
    func start() {
        let viewController: PlayerListViewController = Storyboard.defaultStoryboard.instantiateViewController()
        viewController.coordinator = self
        playerListViewController = viewController
        navController.pushViewController(viewController, animated: true)
    }
    
    func navigateToPlayerDetails(player: PlayerResponseModel) {
        let playerDetailCoordinator = PlayerDetailCoordinator(navController: navController, parent: self, player: player)
        playerDetailCoordinator.delegate = self
        playerDetailCoordinator.start()
        childCoordinators.append(playerDetailCoordinator)
    }
    
    func navigateToPlayerAddScreen() {
        let playerAddCoordinator = PlayerAddCoordinator(navController: navController, parent: self)
        playerAddCoordinator.delegate = self
        playerAddCoordinator.start()
        childCoordinators.append(playerAddCoordinator)
    }
    
    func navigateToConfirmPlayersScreen(with playersDictionary: [TeamSection: [PlayerResponseModel]]) {
        let confirmPlayersCoordinator = ConfirmPlayersCoordinator(navController: navController, parent: self, playersDictionary: playersDictionary)
        confirmPlayersCoordinator.delegate = self
        confirmPlayersCoordinator.start()
        childCoordinators.append(confirmPlayersCoordinator)
    }
    
}

extension PlayerListCoordinator: PlayerAddCoordinatorDelegate {
    func playerWasAdded() {
        playerListViewController?.reloadView()
    }
}

extension PlayerListCoordinator: PlayerDetailCoordinatorDelegate {
    func didEdit(player: PlayerResponseModel) {
        playerListViewController?.didEdit(player: player)
    }
}

extension PlayerListCoordinator: ConfirmPlayersCoordinatorDelegate {
    func didEndGather() {
        playerListViewController?.toggleViewState()
        
        if let playerListViewController = playerListViewController {
            navController.popToViewController(playerListViewController, animated: true)
        }
    }
}

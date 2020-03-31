//
//  ConfirmPlayersCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 23/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

protocol ConfirmPlayersCoordinatorDelegate: AnyObject {
    func didEndGather()
}

final class ConfirmPlayersCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    weak var delegate: ConfirmPlayersCoordinatorDelegate?
    
    private let navController: UINavigationController
    private let playersDictionary: [TeamSection: [PlayerResponseModel]]
    
    init(navController: UINavigationController, parent: Coordinator? = nil, playersDictionary: [TeamSection: [PlayerResponseModel]] = [:]) {
        self.navController = navController
        self.parent = parent
        self.playersDictionary = playersDictionary
    }
    
    func start() {
        let viewController: ConfirmPlayersViewController = Storyboard.defaultStoryboard.instantiateViewController()
        viewController.coordinator = self
        viewController.playersDictionary = playersDictionary
        navController.pushViewController(viewController, animated: true)
    }
    
    func navigateToGatherScreen(with gatherModel: GatherModel) {
        let gatherCoordinator = GatherCoordinator(navController: navController, parent: self, gather: gatherModel)
        gatherCoordinator.delegate = self
        gatherCoordinator.start()
        childCoordinators.append(gatherCoordinator)
    }
}

extension ConfirmPlayersCoordinator: GatherCoordinatorDelegate {
    func didEndGather() {
        delegate?.didEndGather()
    }
}

//
//  PlayerDetailCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 20/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

protocol PlayerDetailCoordinatorDelegate: AnyObject {
    func didEdit(player: PlayerResponseModel)
}

final class PlayerDetailCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    weak var delegate: PlayerDetailCoordinatorDelegate?
    
    private let navController: UINavigationController
    private let player: PlayerResponseModel
    private var detailViewController: PlayerDetailViewController?
    
    init(navController: UINavigationController, parent: Coordinator? = nil, player: PlayerResponseModel) {
        self.navController = navController
        self.parent = parent
        self.player = player
    }
    
    func start() {
        let viewController: PlayerDetailViewController = Storyboard.defaultStoryboard.instantiateViewController()
        viewController.coordinator = self
        viewController.player = player
        detailViewController = viewController
        navController.pushViewController(viewController, animated: true)
    }
    
    func navigateToEditScreen(viewType: PlayerEditViewType,
                              playerEditModel: PlayerEditModel?,
                              playerItemsEditModel: PlayerItemsEditModel?) {
        let editCoordinator = PlayerEditCoordinator(navController: navController,
                                                    viewType: viewType,
                                                    playerEditModel: playerEditModel,
                                                    playerItemsEditModel: playerItemsEditModel)
        editCoordinator.delegate = self
        editCoordinator.start()
        childCoordinators.append(editCoordinator)
    }
}

extension PlayerDetailCoordinator: PlayerEditCoordinatorDelegate {
    func didFinishEditing(player: PlayerResponseModel) {
        detailViewController?.setupTitle()
        detailViewController?.updateData(player: player)
        detailViewController?.reloadData()
        delegate?.didEdit(player: player)
    }
}

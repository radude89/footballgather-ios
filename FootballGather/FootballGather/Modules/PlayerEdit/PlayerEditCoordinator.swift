//
//  PlayerEditCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 20/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

protocol PlayerEditCoordinatorDelegate: AnyObject {
    func didFinishEditing(player: PlayerResponseModel)
}

final class PlayerEditCoordinator: Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    weak var delegate: PlayerEditCoordinatorDelegate?
    
    private let navController: UINavigationController
    private let viewType: PlayerEditViewType
    private let playerEditModel: PlayerEditModel?
    private let playerItemsEditModel: PlayerItemsEditModel?
    
    init(navController: UINavigationController,
         parent: Coordinator? = nil,
         viewType: PlayerEditViewType,
         playerEditModel: PlayerEditModel?,
         playerItemsEditModel: PlayerItemsEditModel?) {
        self.navController = navController
        self.parent = parent
        self.viewType = viewType
        self.playerEditModel = playerEditModel
        self.playerItemsEditModel = playerItemsEditModel
    }
    
    func start() {
        let viewController: PlayerEditViewController = Storyboard.defaultStoryboard.instantiateViewController()
        viewController.coordinator = self
        viewController.viewType = viewType
        viewController.playerEditModel = playerEditModel
        viewController.playerItemsEditModel = playerItemsEditModel
        navController.pushViewController(viewController, animated: true)
    }
    
    func didFinishEditingPlayer(_ player: PlayerResponseModel) {
        delegate?.didFinishEditing(player: player)
        navController.popViewController(animated: true)
    }
}

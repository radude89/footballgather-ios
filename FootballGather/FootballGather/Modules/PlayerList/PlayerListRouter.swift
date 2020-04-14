//
//  PlayerListRouter.swift
//  FootballGather
//
//  Created by Radu Dan on 15/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerListRouter {
    
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
}

extension PlayerListRouter: PlayerListRouterProtocol {
    func showDetails(for player: PlayerResponseModel, delegate: PlayerDetailDelegate) {
        let module = moduleFactory.makePlayerDetails(using: navigationController, for: player, delegate: delegate)
        
        if let viewController = module.assemble() {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func showAddPlayer(delegate: PlayerAddDelegate) {
        let module = moduleFactory.makePlayerAdd(using: navigationController, delegate: delegate)
        
        if let viewController = module.assemble() {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
    
    func showConfirmPlayers(with playersDictionary: [TeamSection: [PlayerResponseModel]], delegate: ConfirmPlayersDelegate) {
        let module = moduleFactory.makeConfirmPlayers(using: navigationController, playersDictionary: playersDictionary, delegate: delegate)
        
        if let viewController = module.assemble() {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

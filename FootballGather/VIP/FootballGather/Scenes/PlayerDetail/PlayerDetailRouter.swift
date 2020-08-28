//
//  PlayerDetailRouter.swift
//  FootballGather
//
//  Created by Radu Dan on 21/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class PlayerDetailRouter {
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
}

extension PlayerDetailRouter: PlayerDetailRouterProtocol {
    func showEditView(with editablePlayerDetails: PlayerEditable, delegate: PlayerEditDelegate) {
        let module = moduleFactory.makePlayerEdit(using: navigationController, for: editablePlayerDetails, delegate: delegate)
        
        if let viewController = module.assemble() {
            navigationController.pushViewController(viewController, animated: true)
        }
    }
}

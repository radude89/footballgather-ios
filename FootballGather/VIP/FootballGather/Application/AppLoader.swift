//
//  AppLoader.swift
//  FootballGather
//
//  Created by Radu Dan on 20/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

struct AppLoader {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let moduleFactory: ModuleFactoryProtocol
    
    init(window: UIWindow = UIWindow(frame: UIScreen.main.bounds),
         navigationController: UINavigationController = UINavigationController(),
         moduleFactory: ModuleFactoryProtocol = ModuleFactory()) {
        self.window = window
        self.navigationController = navigationController
        self.moduleFactory = moduleFactory
    }
    
    func build() {
        let module = moduleFactory.makeLogin(using: navigationController)
        let viewController = module.assemble()
        setRootViewController(viewController)
    }
    
    private func setRootViewController(_ viewController: UIViewController?) {
        window.rootViewController = navigationController
        
        if let viewController = viewController {
            navigationController.pushViewController(viewController, animated: true)
        }
        
        window.makeKeyAndVisible()
    }
}

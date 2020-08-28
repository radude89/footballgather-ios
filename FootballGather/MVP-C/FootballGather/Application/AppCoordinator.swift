//
//  AppCoordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 19/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

final class AppCoordinator: NSObject, Coordinator {
    
    weak var parent: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    private let navController: UINavigationController
    private let window: UIWindow
    
    init(navController: UINavigationController = UINavigationController(),
         window: UIWindow = UIWindow(frame: UIScreen.main.bounds)) {
        self.navController = navController
        self.window = window
    }
    
    func start() {
        navController.delegate = self
        window.rootViewController = navController
        
        let loginCoordinator = LoginCoordinator(navController: navController, parent: self)
        loginCoordinator.start()
        
        window.makeKeyAndVisible()
        
        childCoordinators.append(loginCoordinator)
    }
    
}

extension AppCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(fromViewController) else {
                return
        }
        
        if let viewController = fromViewController as? Coordinatable {
            let parent = viewController.coordinator?.parent
            parent?.childCoordinators.removeAll { $0 === viewController.coordinator }
        }
    }
}

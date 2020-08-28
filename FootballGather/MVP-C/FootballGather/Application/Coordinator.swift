//
//  Coordinator.swift
//  FootballGather
//
//  Created by Radu Dan on 19/03/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var parent: Coordinator? { get set }
    
    func start()
}

protocol Coordinatable: AnyObject {
    var coordinator: Coordinator? { get set }
}

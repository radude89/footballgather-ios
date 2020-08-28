//
//  PlayerAddInteractor.swift
//  FootballGather
//
//  Created by Radu Dan on 24/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerAddInteractor
final class PlayerAddInteractor: PlayerAddInteractable {
    
    weak var presenter: PlayerAddPresenterProtocol?
    
    private let service: StandardNetworkService
    
    init(service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.service = service
    }
    
}

// MARK: - Service Handler
extension PlayerAddInteractor: PlayerAddInteractorServiceHander {
    func addPlayer(name: String) {
        let player = PlayerCreateModel(name: name)
        service.create(player) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(_) = result {
                    self?.presenter?.playerWasAdded()
                } else {
                    self?.presenter?.serviceFailedToAddPlayer()
                }
            }
        }
    }
}

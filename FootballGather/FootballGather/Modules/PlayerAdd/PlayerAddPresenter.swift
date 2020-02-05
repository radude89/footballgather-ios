//
//  PlayerAddPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerAddPresenterProtocol
protocol PlayerAddPresenterProtocol: AnyObject {
    func addPlayer(withName name: String?)
    func doneButtonIsEnabled(forText text: String?) -> Bool
}

// MARK: - PlayerAddPresenter
final class PlayerAddPresenter: PlayerAddPresenterProtocol {
    
    private weak var view: PlayerAddViewProtocol?
    private let service: StandardNetworkService
    
    init(view: PlayerAddViewProtocol? = nil,
         service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.view = view
        self.service = service
    }
    
    func addPlayer(withName name: String?) {
        guard let name = name else { return }
        
        view?.showLoadingView()
        
        let player = PlayerCreateModel(name: name)
        service.create(player) { [weak self] result in
            DispatchQueue.main.async {
                self?.view?.hideLoadingView()
                
                if case .success(_) = result {
                    self?.view?.handlePlayerAddedSuccessfully()
                } else {
                    self?.view?.handleError(title: "Error update", message: "Unable to create player. Please try again.")
                }
            }
        }
    }
    
    func doneButtonIsEnabled(forText text: String?) -> Bool {
        return text?.isEmpty == false
    }
    
}

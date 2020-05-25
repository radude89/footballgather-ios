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
    
    var presenter: PlayerAddPresenterProtocol
    weak var delegate: PlayerAddDelegate?
    
    private let service: StandardNetworkService
    
    init(presenter: PlayerAddPresenterProtocol = PlayerAddPresenter(),
         delegate: PlayerAddDelegate? = nil,
         service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.presenter = presenter
        self.delegate = delegate
        self.service = service
    }
    
}

// MARK: - Actionable
extension PlayerAddInteractor: PlayerAddInteractorActionable {
    func endEditing(request: PlayerAdd.Done.Request) {
        guard let name = request.text else {
            return
        }
        
        let player = PlayerCreateModel(name: name)
        service.create(player) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if case .success(_) = result {
                    self.delegate?.didAddPlayer()
                    self.presenter.dismissAddView()
                } else {
                    let errorResponse = PlayerAdd.ErrorResponse(error: .addError)
                    self.presenter.presentError(response: errorResponse)
                }
            }
        }
    }
    
    func updateValue(request: PlayerAdd.TextDidChange.Request) {
        let textIsEmpty = request.text?.isEmpty == true
        let response = PlayerAdd.TextDidChange.Response(textIsEmpty: textIsEmpty)
        presenter.updateView(response: response)
    }
}

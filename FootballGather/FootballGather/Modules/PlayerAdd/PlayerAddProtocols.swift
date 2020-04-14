//
//  PlayerAddProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 24/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol PlayerAddRouterProtocol: AnyObject {
    func dismissAddView()
}

// MARK: - View
typealias PlayerAddViewProtocol = PlayerAddViewable & PlayerAddViewConfigurable & Loadable & ErrorHandler

protocol PlayerAddViewable: AnyObject {
    var presenter: PlayerAddPresenterProtocol! { get set }
}

protocol PlayerAddViewConfigurable: AnyObject {
    var textFieldText: String? { get }
    
    func configureTitle(_ title: String)
    func setupBarButtonItem(title: String)
    func setBarButtonState(isEnabled: Bool)
    func setupTextField(placeholder: String)
}

// MARK: - Delegate
protocol PlayerAddDelegate: AnyObject {
    func didAddPlayer()
}

// MARK: - Presenter
typealias PlayerAddPresenterProtocol = PlayerAddPresentable & PlayerAddPresenterViewConfiguration & PlayerAddPresenterTextFieldHandler & PlayerAddPresenterServiceInteractable & PlayerAddPresenterServiceHandler

protocol PlayerAddPresentable: AnyObject {
    var view: PlayerAddViewProtocol? { get set }
    var interactor: PlayerAddInteractorProtocol { get set }
    var router: PlayerAddRouterProtocol { get set }
    var delegate: PlayerAddDelegate? { get set }
}

protocol PlayerAddPresenterViewConfiguration: AnyObject {
    func viewDidLoad()
}

protocol PlayerAddPresenterTextFieldHandler: AnyObject {
    func textFieldDidChange()
}

protocol PlayerAddPresenterServiceInteractable: AnyObject {
    func endEditing()
}

protocol PlayerAddPresenterServiceHandler: AnyObject {
    func playerWasAdded()
    func serviceFailedToAddPlayer()
}

// MARK: - Interactor
typealias PlayerAddInteractorProtocol = PlayerAddInteractable & PlayerAddInteractorServiceHander

protocol PlayerAddInteractable: AnyObject {
    var presenter: PlayerAddPresenterProtocol? { get set }
}

protocol PlayerAddInteractorServiceHander: AnyObject {
    func addPlayer(name: String)
}

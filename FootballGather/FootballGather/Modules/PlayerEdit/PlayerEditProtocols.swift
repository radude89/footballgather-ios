//
//  PlayerEditProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 23/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol PlayerEditRouterProtocol: AnyObject {
    func dismissEditView()
}

// MARK: - View
typealias PlayerEditViewProtocol = PlayerEditViewable & Loadable & PlayerEditViewConfigurable & ErrorHandler

protocol PlayerEditViewable: AnyObject {
    var presenter: PlayerEditPresenterProtocol! { get set }
}

protocol PlayerEditViewConfigurable: AnyObject {
    var textFieldText: String? { get }
    
    func configureTitle(_ title: String)
    func setupBarButtonItem(title: String)
    func setupTextField()
    func setTextField(text: String?, placeholder: String?, isHidden: Bool)
    func setTableViewVisibility(isHidden: Bool)
    func setBarButtonState(isEnabled: Bool)
    func setSelected(_ selected: Bool, at indexPath: IndexPath)
}

// MARK: - Delegate
protocol PlayerEditDelegate: AnyObject {
    func didUpdate(player: PlayerResponseModel)
}

// MARK: - Presenter
typealias PlayerEditPresenterProtocol = PlayerEditPresentable & PlayerEditPresenterViewConfiguration & PlayerEditDataSource & PlayerEditPresenterTextFieldHandler & PlayerEditPresenterServiceInteractable & PlayerEditPresenterServiceHandler

protocol PlayerEditPresentable: AnyObject {
    var view: PlayerEditViewProtocol? { get set }
    var interactor: PlayerEditInteractorProtocol { get set }
    var router: PlayerEditRouterProtocol { get set }
    var delegate: PlayerEditDelegate? { get set }
}

protocol PlayerEditPresenterViewConfiguration: AnyObject {
    func viewDidLoad()
}

protocol PlayerEditDataSource: AnyObject {
    var numberOfRows: Int { get }
    
    func itemRow(at index: Int) -> PlayerEditRow?
    func selectRow(at index: Int)
}

protocol PlayerEditPresenterTextFieldHandler: AnyObject {
    func textFieldDidChange()
}

protocol PlayerEditPresenterServiceInteractable: AnyObject {
    func endEditing()
}

protocol PlayerEditPresenterServiceHandler: AnyObject {
    func playerWasUpdated()
    func serviceFailedToUpdatePlayer()
}

// MARK: - Interactor
typealias PlayerEditInteractorProtocol = PlayerEditInteractable & PlayerEditInteractorServiceHander

protocol PlayerEditInteractable: AnyObject {
    var presenter: PlayerEditPresenterProtocol? { get set }
}

protocol PlayerEditInteractorServiceHander: AnyObject {
    var playerEditable: PlayerEditable { get }
    
    func updateSelectedItemIndex(_ index: Int)
    func commitUpdates(with enteredText: String?)
    func updatePlayer()
}

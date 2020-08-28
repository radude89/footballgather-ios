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
typealias PlayerEditViewProtocol = PlayerEditViewable & Loadable & PlayerEditViewDisplayable & PlayerEditViewErrorHandler

protocol PlayerEditViewable: AnyObject {
    var interactor: PlayerEditInteractorProtocol! { get set }
    var router: PlayerEditRouterProtocol { get set }
}

protocol PlayerEditViewDisplayable: AnyObject {
    func displayTitle(viewModel: PlayerEdit.ConfigureTitle.ViewModel)
    func displayField(viewModel: PlayerEdit.ConfigureField.ViewModel)
    func displayTable(viewModel: PlayerEdit.ConfigureTable.ViewModel)
    func displayBarButton(viewModel: PlayerEditBarButtonViewModel)
    func setSelected(viewModel: PlayerEdit.UpdateSelection.ViewModel)
    func dismissEditView()
}

protocol PlayerEditViewErrorHandler: ErrorHandler {
    func displayError(viewModel: PlayerEdit.ErrorViewModel)
}

extension PlayerEditViewErrorHandler {
    func displayError(viewModel: PlayerEdit.ErrorViewModel) {
        handleError(title: viewModel.errorTitle, message: viewModel.errorMessage)
    }
}

// MARK: - Delegate
protocol PlayerEditDelegate: AnyObject {
    func didUpdate(player: PlayerResponseModel)
}

// MARK: - Interactor
typealias PlayerEditInteractorProtocol = PlayerEditInteractable & PlayerEditInteractorConfigurable & PlayerEditInteractorTableDelegate & PlayerEditInteractorActionable

protocol PlayerEditInteractable: AnyObject {
    var presenter: PlayerEditPresenterProtocol { get set }
    var delegate: PlayerEditDelegate? { get set }
}

protocol PlayerEditInteractorConfigurable: AnyObject {
    func configureField(request: PlayerEdit.ConfigureField.Request)
    func configureTitle(request: PlayerEdit.ConfigureTitle.Request)
    func configureTable(request: PlayerEdit.ConfigureTable.Request)
}

protocol PlayerEditInteractorTableDelegate: AnyObject {
    func numberOfRows(request: PlayerEdit.RowsCount.Request) -> Int
    func rowDetails(request: PlayerEdit.RowDetails.Request) -> PlayerEdit.RowDetails.ViewModel
    func updateSelection(request: PlayerEdit.UpdateSelection.Request)
    func selectRow(request: PlayerEdit.SelectRow.Request)
}

protocol PlayerEditInteractorActionable: AnyObject {
    func updateValue(request: PlayerEdit.UpdateField.Request)
    func endEditing(request: PlayerEdit.Done.Request)
}

// MARK: - Presenter
typealias PlayerEditPresenterProtocol = PlayerEditPresentable & PlayerEditPresenterConfigurable & PlayerEditPresenterActionable & PlayerEditPresenterTableDelegate

protocol PlayerEditPresentable: AnyObject {
    var view: PlayerEditViewProtocol? { get set }
}

protocol PlayerEditPresenterConfigurable: AnyObject {
    func presentField(response: PlayerEdit.ConfigureField.Response)
    func presentTitle(response: PlayerEdit.ConfigureTitle.Response)
    func presentTable(response: PlayerEdit.ConfigureTable.Response)
}

protocol PlayerEditPresenterActionable: AnyObject {
    func updateView(response: PlayerEdit.UpdateField.Response)
    func dismissEditView()
    func presentError(response: PlayerEdit.ErrorResponse)
}

protocol PlayerEditPresenterTableDelegate: AnyObject {
    func rowDetails(response: PlayerEdit.RowDetails.Response) -> PlayerEdit.RowDetails.ViewModel
    func updateViewSelection(response: PlayerEdit.UpdateSelection.Response)
    func updateSelectedPlayer(response: PlayerEdit.SelectRow.Response)
}

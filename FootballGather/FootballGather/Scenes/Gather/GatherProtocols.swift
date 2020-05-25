//
//  GatherProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 28/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol GatherRouterProtocol: AnyObject {
    func popToPlayerListView()
}

// MARK: - View
typealias GatherViewProtocol = GatherViewable & GatherViewDisplayable & GatherViewRoutable & Loadable & GatherViewErrorHandler

protocol GatherViewable: AnyObject {
    var interactor: GatherInteractorProtocol! { get set }
    var router: GatherRouterProtocol { get set }
}

protocol GatherViewDisplayable: AnyObject {
    func displaySelectedRow(viewModel: Gather.SelectRows.ViewModel)
    func displayTime(viewModel: Gather.FormatTime.ViewModel)
    func displayActionButtonTitle(viewModel: Gather.ConfigureActionButton.ViewModel)
    func displayEndGatherConfirmationAlert()
    func configureTimerViewVisibility(viewModel: Gather.SetTimer.ViewModel)
    func displayCancelTimer(viewModel: Gather.CancelTimer.ViewModel)
    func displayUpdatedTimer(viewModel: Gather.TimerDidFinish.ViewModel)
    func displayTeamScore(viewModel: Gather.UpdateValue.ViewModel)
}

protocol GatherViewRoutable: AnyObject {
    func popToPlayerListView()
}

protocol GatherViewErrorHandler: ErrorHandler {
    func displayError(viewModel: Gather.ErrorViewModel)
}

extension GatherViewErrorHandler {
    func displayError(viewModel: Gather.ErrorViewModel) {
        handleError(title: viewModel.errorTitle, message: viewModel.errorMessage)
    }
}

// MARK: - Delegate
protocol GatherDelegate: AnyObject {
    func didEndGather()
}

// MARK: - Interactor
typealias GatherInteractorProtocol = GatherInteractable & GatherInteractorConfigurable & GatherInteractorTimeHandler & GatherInteractorActionable & GatherInteractorTableDelegate & GatherInteractorPickerDelegate

protocol GatherInteractable: AnyObject {
    var presenter: GatherPresenterProtocol { get set }
}

protocol GatherInteractorConfigurable: AnyObject {
    func selectRows(request: Gather.SelectRows.Request)
    func formatTime(request: Gather.FormatTime.Request)
    func configureActionButton(request: Gather.ConfigureActionButton.Request)
    func updateValue(request: Gather.UpdateValue.Request)
}

protocol GatherInteractorTimeHandler: AnyObject {
    var minutesComponent: GatherTimeHandler.Component? { get }
    var secondsComponent: GatherTimeHandler.Component? { get }
    
    func setTimer(request: Gather.SetTimer.Request)
    func cancelTimer(request: Gather.CancelTimer.Request)
    func actionTimer(request: Gather.ActionTimer.Request)
    func timerDidCancel(request: Gather.TimerDidCancel.Request)
    func timerDidFinish(request: Gather.TimerDidFinish.Request)
}

protocol GatherInteractorActionable: AnyObject {
    func requestToEndGather(request: Gather.EndGather.Request)
    func endGather(request: Gather.EndGather.Request)
}

protocol GatherInteractorTableDelegate: AnyObject {
    func numberOfSections(request: Gather.SectionsCount.Request) -> Int
    func numberOfRowsInSection(request: Gather.RowsCount.Request) -> Int
    func rowDetails(request: Gather.RowDetails.Request) -> Gather.RowDetails.ViewModel
    func titleForHeaderInSection(request: Gather.SectionTitle.Request) -> Gather.SectionTitle.ViewModel
}

protocol GatherInteractorPickerDelegate: AnyObject {
    func numberOfPickerComponents(request: Gather.PickerComponents.Request) -> Int
    func numberOfRowsInPickerComponent(request: Gather.PickerRows.Request) -> Int
    func titleForPickerRow(request: Gather.PickerRowTitle.Request) -> Gather.PickerRowTitle.ViewModel
}

// MARK: - Presenter
typealias GatherPresenterProtocol = GatherPresentable & GatherPresenterConfigurable & GatherPresenterTableDelegate & GatherPresenterPickerDelegate

protocol GatherPresentable: AnyObject {
    var view: GatherViewProtocol? { get set }
}

protocol GatherPresenterConfigurable: AnyObject {
    func presentSelectedRows(response: Gather.SelectRows.Response)
    func formatTime(response: Gather.FormatTime.Response)
    func presentActionButton(response: Gather.ConfigureActionButton.Response)
    func presentEndGatherConfirmationAlert(response: Gather.EndGather.Response)
    func presentTimerView(response: Gather.SetTimer.Response)
    func cancelTimer(response: Gather.CancelTimer.Response)
    func presentToggledTimer(response: Gather.ActionTimer.Response)
    func hideTimer()
    func presentUpdatedTime(response: Gather.TimerDidFinish.Response)
    func popToPlayerListView()
    func presentError(response: Gather.ErrorResponse)
    func displayTeamScore(response: Gather.UpdateValue.Response)
}

protocol GatherPresenterTableDelegate: AnyObject {
    func numberOfSections(response: Gather.SectionsCount.Response) -> Int
    func numberOfRowsInSection(response: Gather.RowsCount.Response) -> Int
    func rowDetails(response: Gather.RowDetails.Response) -> Gather.RowDetails.ViewModel
    func titleForHeaderInSection(response: Gather.SectionTitle.Response) -> Gather.SectionTitle.ViewModel
}

protocol GatherPresenterPickerDelegate: AnyObject {
    func numberOfPickerComponents(response: Gather.PickerComponents.Response) -> Int
    func numberOfPickerRows(response: Gather.PickerRows.Response) -> Int
    func titleForRow(response: Gather.PickerRowTitle.Response) -> Gather.PickerRowTitle.ViewModel
}

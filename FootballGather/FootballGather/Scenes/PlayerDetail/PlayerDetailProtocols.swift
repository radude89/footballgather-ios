//
//  PlayerDetailProtocols.swift
//  FootballGather
//
//  Created by Radu Dan on 23/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - Router
protocol PlayerDetailRouterProtocol: AnyObject {
    func showEditView(with editablePlayerDetails: PlayerEditable, delegate: PlayerEditDelegate)
}

// MARK: - View
typealias PlayerDetailViewProtocol = PlayerDetailViewable & PlayerDetailViewConfigurable & PlayerDetailRoutable & PlayerDetailReloadable

protocol PlayerDetailViewable: AnyObject {
    var interactor: PlayerDetailInteractorProtocol! { get set }
    var router: PlayerDetailRouterProtocol { get set }
}

protocol PlayerDetailViewConfigurable: AnyObject {
    func displayTitle(viewModel: PlayerDetail.ConfigureTitle.ViewModel)
}

protocol PlayerDetailRoutable: AnyObject {
    func showEditView(playerEditable: PlayerEditable, delegate: PlayerEditDelegate)
}

protocol PlayerDetailReloadable: AnyObject {
    func reloadData()
}

// MARK: - Delegate
protocol PlayerDetailDelegate: AnyObject {
    func didUpdate(player: PlayerResponseModel)
}

// MARK: - Interactor
typealias PlayerDetailInteractorProtocol = PlayerDetailInteractable & PlayerDetailInteractorConfigurable & PlayerDetailInteractorTableDelegate

protocol PlayerDetailInteractable: AnyObject {
    var presenter: PlayerDetailPresenterProtocol { get set }
}

protocol PlayerDetailInteractorConfigurable: AnyObject {
    func configureTitle(request: PlayerDetail.ConfigureTitle.Request)
}

protocol PlayerDetailInteractorTableDelegate: AnyObject {
    func numberOfSections(request: PlayerDetail.SectionsCount.Request) -> Int
    func numberOfRowsInSection(request: PlayerDetail.RowsCount.Request) -> Int
    func rowDetails(request: PlayerDetail.RowDetails.Request) -> PlayerDetail.RowDetails.ViewModel
    func titleForHeaderInSection(request: PlayerDetail.SectionTitle.Request) -> PlayerDetail.SectionTitle.ViewModel
    func selectRow(request: PlayerDetail.SelectRow.Request)
}

// MARK: - Presenter
typealias PlayerDetailPresenterProtocol = PlayerDetailPresentable & PlayerDetailPresenterConfigurable & PlayerDetailPresenterTableDelegate & PlayerDetailPresenterUpdatable

protocol PlayerDetailPresentable: AnyObject {
    var view: PlayerDetailViewProtocol? { get set }
    var sections: [PlayerDetailSection] { get set }
}

protocol PlayerDetailPresenterConfigurable: AnyObject {
    func presentTitle(response: PlayerDetail.ConfigureTitle.Response)
    func presentEditView(response: PlayerDetail.SelectRow.Response)
}

protocol PlayerDetailPresenterTableDelegate: AnyObject {
    func numberOfSections(response: PlayerDetail.SectionsCount.Response) -> Int
    func numberOfRowsInSection(response: PlayerDetail.RowsCount.Response) -> Int
    func rowDetails(response: PlayerDetail.RowDetails.Response) -> PlayerDetail.RowDetails.ViewModel
    func titleForHeaderInSection(response: PlayerDetail.SectionTitle.Response) -> PlayerDetail.SectionTitle.ViewModel
    func rowDetails(at indexPath: IndexPath) -> PlayerDetailRow
    func titleForHeaderInSection(_ section: Int) -> String?
}

protocol PlayerDetailPresenterUpdatable: AnyObject {
    func updateView(response: PlayerDetail.Update.Response)
}

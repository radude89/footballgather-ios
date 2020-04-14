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
typealias PlayerDetailViewProtocol = PlayerDetailViewable & PlayerDetailViewConfigurable & PlayerDetailViewReloadable

protocol PlayerDetailViewable: AnyObject {
    var presenter: PlayerDetailPresenterProtocol! { get set }
}

protocol PlayerDetailViewConfigurable: AnyObject {
    func configureTitle(_ title: String)
}

protocol PlayerDetailViewReloadable: AnyObject {
    func reloadData()
}

protocol PlayerDetailTableViewCellProtocol: AnyObject {
    func setLeftLabelText(_ text: String)
    func setRightLabelText(_ text: String)
}

// MARK: - Delegate
protocol PlayerDetailDelegate: AnyObject {
    func didUpdate(player: PlayerResponseModel)
}

// MARK: - Presenter
typealias PlayerDetailPresenterProtocol = PlayerDetailPresentable & PlayerDetailDataSource & PlayerDetailPresenterViewConfiguration & PlayerDetailPresenterServiceHandler

protocol PlayerDetailPresentable: AnyObject {
    var view: PlayerDetailViewProtocol? { get set }
    var interactor: PlayerDetailInteractorProtocol { get set }
    var router: PlayerDetailRouterProtocol { get set }
    var delegate: PlayerDetailDelegate? { get set }
}

protocol PlayerDetailDataSource: AnyObject {
    var numberOfSections: Int { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func rowDetails(at indexPath: IndexPath) -> PlayerDetailRow
    func titleForHeaderInSection(_ section: Int) -> String?
    func selectRow(at indexPath: IndexPath)
}

protocol PlayerDetailPresenterViewConfiguration: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
}

protocol PlayerDetailPresenterServiceHandler: AnyObject {
    func playerWasUpdated()
}

protocol PlayerDetailTableViewCellPresenterProtocol {
    var view: PlayerDetailTableViewCellProtocol? { get set }
    
    func configure(with rowDetail: PlayerDetailRow)
}

// MARK: - Interactor
typealias PlayerDetailInteractorProtocol = PlayerDetailInteractable & PlayerDetailInteractorServiceHander

protocol PlayerDetailInteractable: AnyObject {
    var presenter: PlayerDetailPresenterProtocol? { get set }
}

protocol PlayerDetailInteractorServiceHander: AnyObject {
    var player: PlayerResponseModel { get }
    
    func updatePlayer(_ player: PlayerResponseModel)
}

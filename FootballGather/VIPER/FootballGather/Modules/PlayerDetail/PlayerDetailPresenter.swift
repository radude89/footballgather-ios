//
//  PlayerDetailPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerDetailPresenter
final class PlayerDetailPresenter: PlayerDetailPresentable {
    
    // MARK: - Properties
    weak var view: PlayerDetailViewProtocol?
    var interactor: PlayerDetailInteractorProtocol
    var router: PlayerDetailRouterProtocol
    weak var delegate: PlayerDetailDelegate?
    
    private lazy var sections = makeSections()
    
    // MARK: - Init
    init(view: PlayerDetailViewProtocol? = nil,
         interactor: PlayerDetailInteractorProtocol,
         router: PlayerDetailRouterProtocol = PlayerDetailRouter(),
         delegate: PlayerDetailDelegate? = nil) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.delegate = delegate
    }
    
    private func makeSections() -> [PlayerDetailSection] {
        [
            PlayerDetailSection(
                title: "Personal",
                rows: [
                    PlayerDetailRow(title: "Name",
                                    value: interactor.player.name,
                                    editableField: .name),
                    PlayerDetailRow(title: "Age",
                                    value: interactor.player.age != nil ? "\(interactor.player.age!)" : "",
                                    editableField: .age)
                ]
            ),
            PlayerDetailSection(
                title: "Play",
                rows: [
                    PlayerDetailRow(title: "Preferred position",
                                    value: interactor.player.preferredPosition?.rawValue.capitalized ?? "",
                                    editableField: .position),
                    PlayerDetailRow(title: "Skill",
                                    value: interactor.player.skill?.rawValue.capitalized ?? "",
                                    editableField: .skill)
                ]
            ),
            PlayerDetailSection(
                title: "Likes",
                rows: [
                    PlayerDetailRow(title: "Favourite team",
                                    value: interactor.player.favouriteTeam ?? "",
                                    editableField: .favouriteTeam)
                ]
            )
        ]
    }
    
}

// MARK: - View Configuration
extension PlayerDetailPresenter: PlayerDetailPresenterViewConfiguration {
    func viewDidLoad() {
        let title = interactor.player.name
        view?.configureTitle(title)
    }
    
    func viewWillAppear() {
        view?.reloadData()
    }
}

// MARK: - Data Source
extension PlayerDetailPresenter: PlayerDetailDataSource {
    var numberOfSections: Int {
        sections.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        sections[section].rows.count
    }
    
    func rowDetails(at indexPath: IndexPath) -> PlayerDetailRow {
        sections[indexPath.section].rows[indexPath.row]
    }
    
    func titleForHeaderInSection(_ section: Int) -> String? {
        sections[section].title.uppercased()
    }
    
    func selectRow(at indexPath: IndexPath) {
        let player = interactor.player
        let rowDetails = sections[indexPath.section].rows[indexPath.row]
        let items = self.items(for: rowDetails.editableField)
        let selectedItemIndex = items.firstIndex(of: rowDetails.value.lowercased())
        let editablePlayerDetails = PlayerEditable(player: player,
                                                   items: items,
                                                   selectedItemIndex: selectedItemIndex,
                                                   rowDetails: rowDetails)
        
        router.showEditView(with: editablePlayerDetails, delegate: self)
    }
    
    private func items(for editableField: PlayerEditableFieldOption) -> [String] {
        switch editableField {
        case .position:
            return PlayerPosition.allCases.map { $0.rawValue }
            
        case .skill:
            return PlayerSkill.allCases.map { $0.rawValue }
            
        default:
            return []
        }
    }
}

// MARK: - Service Handler
extension PlayerDetailPresenter: PlayerDetailPresenterServiceHandler {
    func playerWasUpdated() {
        sections = makeSections()
        view?.configureTitle(interactor.player.name)
        view?.reloadData()
    }
}

// MARK: - PlayerEditDelegate
extension PlayerDetailPresenter: PlayerEditDelegate {
    func didUpdate(player: PlayerResponseModel) {
        interactor.updatePlayer(player)
        delegate?.didUpdate(player: player)
    }
}

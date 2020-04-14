//
//  PlayerTableViewCellPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 15/04/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

final class PlayerTableViewCellPresenter: PlayerTableViewCellPresenterProtocol {
    
    var view: PlayerTableViewCellProtocol?
    var viewState: PlayerListViewState
    var isSelected = false
    
    init(view: PlayerTableViewCellProtocol? = nil,
         viewState: PlayerListViewState = .list) {
        self.view = view
        self.viewState = viewState
    }
    
    func setupView() {
        if viewState == .list {
            view?.setupDefaultView()
        } else {
            view?.setupViewForSelection(isSelected: isSelected)
        }
    }
    
    func toggle() {
        isSelected.toggle()
        
        if viewState == .selection {
            view?.setupCheckBoxImage(isSelected: isSelected)
        }
    }
    
    func configure(with player: PlayerResponseModel) {
        view?.set(nameDescription: player.name)
        setPositionDescription(for: player)
        setSkillDescription(for: player)
    }
    
    private func setPositionDescription(for player: PlayerResponseModel) {
        let position = player.preferredPosition?.rawValue
        view?.set(positionDescription: "Position: \(position ?? "-")")
    }
    
    private func setSkillDescription(for player: PlayerResponseModel) {
        let skill = player.skill?.rawValue
        view?.set(skillDescription: "Skill: \(skill ?? "-")")
    }
    
}

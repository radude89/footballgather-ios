//
//  PlayerDetailPresenter.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - PlayerDetailPresenterProtocol
protocol PlayerDetailPresenterProtocol: AnyObject {
    var player: PlayerResponseModel { get }
    var title: String { get }
    var numberOfSections: Int { get }
    var destinationViewType: PlayerEditViewType { get }
    var playerEditModel: PlayerEditModel? { get }
    var playerItemsEditModel: PlayerItemsEditModel? { get }
    
    func numberOfRowsInSection(_ section: Int) -> Int
    func rowTitleDescription(for indexPath: IndexPath) -> String
    func rowValueDescription(for indexPath: IndexPath) -> String
    func titleForHeaderInSection(_ section: Int) -> String?
    func selectPlayerRow(at indexPath: IndexPath)
    func updatePlayer(_ player: PlayerResponseModel)
    func reloadSections()
}

// MARK: - PlayerDetailPresenter
final class PlayerDetailPresenter: PlayerDetailPresenterProtocol {
    
    // MARK: - Properties
    private(set) var player: PlayerResponseModel
    private lazy var sections = makeSections()
    private(set) var selectedPlayerRow: PlayerRow?
    
    // MARK: - Public API
    init(player: PlayerResponseModel) {
        self.player = player
    }
    
    var title: String {
        return player.name
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func rowTitleDescription(for indexPath: IndexPath) -> String {
        let row = sections[indexPath.section].rows[indexPath.row]
        return row.title
    }
    
    func rowValueDescription(for indexPath: IndexPath) -> String  {
        let row = sections[indexPath.section].rows[indexPath.row]
        return row.value
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        return sections[section].title.uppercased()
    }
    
    func selectPlayerRow(at indexPath: IndexPath) {
        selectedPlayerRow = sections[indexPath.section].rows[indexPath.row]
    }

    func updatePlayer(_ player: PlayerResponseModel) {
        self.player = player
    }
    
    func reloadSections() {
        sections = makeSections()
    }
    
    // MARK: - Edit methods
    var destinationViewType: PlayerEditViewType {
        if shouldEditSelectionTypeField {
            return .selection
        }
        
        return .text
    }
    
    var playerEditModel: PlayerEditModel? {
        guard let selectedPlayerRow = selectedPlayerRow else { return nil }
        
        return PlayerEditModel(player: player, playerRow: selectedPlayerRow)
    }
    
    var playerItemsEditModel: PlayerItemsEditModel? {
        guard shouldEditSelectionTypeField else { return nil }
        
        return PlayerItemsEditModel(items: editableItems, selectedItemIndex: indexOfSelectedItem ?? -1)
    }
    
    // MARK: - Private methods
    private var shouldEditSelectionTypeField: Bool {
        guard let selectedPlayerRow = selectedPlayerRow else { return false }
        
        return  selectedPlayerRow.editableField == .position || selectedPlayerRow.editableField == .skill
    }
    
    private var editableItems: [String] {
        guard let selectedPlayerRow = selectedPlayerRow else { return [] }
        
        if selectedPlayerRow.editableField == .position {
            return PlayerPosition.allCases.map { $0.rawValue }
        }
        
        return PlayerSkill.allCases.map { $0.rawValue }
    }
    
    private var indexOfSelectedItem: Int? {
        guard let selectedPlayerRow = selectedPlayerRow else { return nil }
        
        return editableItems.firstIndex(of: selectedPlayerRow.value.lowercased())
    }
    
    private func makeSections() -> [PlayerSection] {
        return [
            PlayerSection(
                title: "Personal",
                rows: [
                    PlayerRow(title: "Name",
                              value: player.name,
                              editableField: .name),
                    PlayerRow(title: "Age",
                              value: player.age != nil ? "\(player.age!)" : "",
                              editableField: .age)
                ]
            ),
            PlayerSection(
                title: "Play",
                rows: [
                    PlayerRow(title: "Preferred position",
                              value: player.preferredPosition?.rawValue.capitalized ?? "",
                              editableField: .position),
                    PlayerRow(title: "Skill",
                              value: player.skill?.rawValue.capitalized ?? "",
                              editableField: .skill)
                ]
            ),
            PlayerSection(
                title: "Likes",
                rows: [
                    PlayerRow(title: "Favourite team",
                              value: player.favouriteTeam ?? "",
                              editableField: .favouriteTeam)
                ]
            )
        ]
    }
}

// MARK: - Models
struct PlayerSection {
    let title: String
    let rows: [PlayerRow]
}

struct PlayerRow {
    let title: String
    let value: String
    let editableField: PlayerEditableFieldOption
}

enum PlayerEditableFieldOption {
    case name, age, skill, position, favouriteTeam
}

extension PlayerResponseModel {
    mutating func update(usingField field: PlayerEditableFieldOption, value: String) {
        switch field {
        case .name:
            name = value
        case .age:
            age = Int(value)
        case .position:
            if let position = PlayerPosition(rawValue: value) {
                preferredPosition = position
            }
        case .skill:
            if let skill = PlayerSkill(rawValue: value) {
                self.skill = skill
            }
        case .favouriteTeam:
            favouriteTeam = value
        }
    }
}

//
//  PlayerDetailViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerDetailViewControllerDelegate
protocol PlayerDetailViewControllerDelegate: AnyObject {
    func didEdit(player: PlayerResponseModel)
}

// MARK: - PlayerDetailViewController
final class PlayerDetailViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playerDetailTableView: UITableView!

    weak var delegate: PlayerDetailViewControllerDelegate?
    
    var player: PlayerResponseModel?
    private lazy var sections = makeSections()
    private var selectedPlayerRow: PlayerRow?

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func setupTitle() {
        title = player?.name ?? ""
    }

    private func reloadData() {
        playerDetailTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == SegueIdentifier.editPlayer.rawValue,
            let destinationViewController = segue.destination as? PlayerEditViewController,
            let player = player,
            let selectedPlayerRow = selectedPlayerRow else {
                return
        }
        
        destinationViewController.delegate = self
        destinationViewController.viewType = shouldEditSelectionTypeField ? .selection : .text
        destinationViewController.playerEditModel = PlayerEditModel(player: player, playerRow: selectedPlayerRow)
        
        if shouldEditSelectionTypeField {
            let itemsEditModel = PlayerItemsEditModel(items: editableItems, selectedItemIndex: indexOfSelectedItem ?? -1)
            destinationViewController.playerItemsEditModel = itemsEditModel
        }
        
    }

    private var shouldEditSelectionTypeField: Bool {
        guard let selectedPlayerRow = selectedPlayerRow else { return false }
        
        return  selectedPlayerRow.editableField == .position || selectedPlayerRow.editableField == .skill
    }
    
    private var indexOfSelectedItem: Int? {
        guard let selectedPlayerRow = selectedPlayerRow else { return nil }
        
        return editableItems.firstIndex(of: selectedPlayerRow.value.lowercased())
    }
    
    private var editableItems: [String] {
        guard let selectedPlayerRow = selectedPlayerRow else { return [] }
        
        if selectedPlayerRow.editableField == .position {
            return PlayerPosition.allCases.map { $0.rawValue }
        }
        
        return PlayerSkill.allCases.map { $0.rawValue }
    }
    
    private func makeSections() -> [PlayerSection] {
        return [
            PlayerSection(
                title: "Personal",
                rows: [
                    PlayerRow(title: "Name",
                              value: player?.name ?? "",
                              editableField: .name),
                    PlayerRow(title: "Age",
                              value: player?.age != nil ? "\(player!.age!)" : "",
                              editableField: .age)
                ]
            ),
            PlayerSection(
                title: "Play",
                rows: [
                    PlayerRow(title: "Preferred position",
                              value: player?.preferredPosition?.rawValue.capitalized ?? "",
                              editableField: .position),
                    PlayerRow(title: "Skill",
                              value: player?.skill?.rawValue.capitalized ?? "",
                              editableField: .skill)
                ]
            ),
            PlayerSection(
                title: "Likes",
                rows: [
                    PlayerRow(title: "Favourite team",
                              value: player?.favouriteTeam ?? "",
                              editableField: .favouriteTeam)
                ]
            )
        ]
    }

}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerDetailTableViewCell") as? PlayerDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let row = sections[indexPath.section].rows[indexPath.row]

        cell.leftLabel.text = row.title
        cell.rightLabel.text = row.value

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title.uppercased()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlayerRow = sections[indexPath.section].rows[indexPath.row]
        performSegue(withIdentifier: SegueIdentifier.editPlayer.rawValue, sender: nil)
    }
}

// MARK: - PlayerEditViewControllerDelegate
extension PlayerDetailViewController: PlayerEditViewControllerDelegate {
    func didFinishEditing(player: PlayerResponseModel) {
        setupTitle()
        self.player = player
        sections = makeSections()
        reloadData()
        delegate?.didEdit(player: player)
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

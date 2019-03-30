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
class PlayerDetailViewController: UIViewController {
    @IBOutlet weak var playerDetailTableView: UITableView!
    
    weak var delegate: PlayerDetailViewControllerDelegate?
    var player: PlayerResponseModel?
    
    private enum SegueIdentifiers: String {
        case editPlayer = "EditPlayerSegueIdentifier"
    }
    
    private lazy var sections = makeSections()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = player?.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        playerDetailTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.editPlayer.rawValue{
            guard let destinationViewController = segue.destination as? PlayerEditViewController,
                let selectedPlayerRow = sender as? PlayerRow else {
                    return
            }
            
            destinationViewController.delegate = self
            destinationViewController.playerRow = selectedPlayerRow
            destinationViewController.player = player
            
            if selectedPlayerRow.editableField == .position || selectedPlayerRow.editableField == .skill {
                let items = selectedPlayerRow.editableField == .position ?
                    PlayerPosition.allCases.map { $0.rawValue } :
                    PlayerSkill.allCases.map { $0.rawValue }
                let selectedIndex = items.firstIndex(of: selectedPlayerRow.value.lowercased())
                
                destinationViewController.selectedItemIndex = selectedIndex ?? -1
                destinationViewController.items = items
                destinationViewController.viewType = .selection
            } else {
                destinationViewController.viewType = .text
            }
        }
    }
    
    private func makeSections() -> [PlayerSection] {
        return [
            PlayerSection(
                title: "Personal",
                rows: [
                    PlayerRow(title: "Name",
                              value: self.player?.name ?? "",
                              editableField: .name),
                    PlayerRow(title: "Age",
                              value: self.player?.age != nil ? "\(self.player!.age!)" : "",
                              editableField: .age)
                ]
            ),
            PlayerSection(
                title: "Play",
                rows: [
                    PlayerRow(title: "Preferred position",
                              value: self.player?.preferredPosition?.rawValue.capitalized ?? "",
                              editableField: .position),
                    PlayerRow(title: "Skill",
                              value: self.player?.skill?.rawValue.capitalized ?? "",
                              editableField: .skill)
                ]
            ),
            PlayerSection(
                title: "Likes",
                rows: [
                    PlayerRow(title: "Favourite team",
                              value: self.player?.favouriteTeam ?? "",
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
        
        let rowData = sections[indexPath.section].rows[indexPath.row]
        
        cell.leftLabel.text = rowData.title
        cell.rightLabel.text = rowData.value
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title.uppercased()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = sections[indexPath.section].rows[indexPath.row]
        performSegue(withIdentifier: SegueIdentifiers.editPlayer.rawValue, sender: row)
    }
}

// MARK: - PlayerEditViewControllerDelegate
extension PlayerDetailViewController: PlayerEditViewControllerDelegate {
    func didFinishEditing(player: PlayerResponseModel) {
        self.player = player
        title = player.name
        sections = makeSections()
        playerDetailTableView.reloadData()
        
        delegate?.didEdit(player: player)
    }
}

// MARK: - Model
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

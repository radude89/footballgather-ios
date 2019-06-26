//
//  PlayerDetailViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerDetailViewController
class PlayerDetailViewController: UIViewController {
    @IBOutlet weak var playerDetailTableView: UITableView!
    
    var player: PlayerResponseModel?
    
    private lazy var sections = [
        PlayerSection(
            title: "Personal".uppercased(),
            rows: [
                PlayerRow(title: "Name",
                          value: self.player?.name ?? "-")
            ]
        ),
        PlayerSection(
            title: "Play".uppercased(),
            rows: [
                PlayerRow(title: "Preferred position",
                          value: self.player?.preferredPosition?.acronym ?? "-"),
                PlayerRow(title: "Skill",
                          value: self.player?.skill?.rawValue.capitalized ?? "-")
            ]
        ),
        PlayerSection(
            title: "Likes".uppercased(),
            rows: [
                PlayerRow(title: "Favourite team",
                          value: self.player?.favouriteTeam ?? "-")
            ]
        )
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = player?.name
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
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
}

//
//  ConfirmPlayersViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewController

class ConfirmPlayersViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var startGatherButton: UIButton!
    lazy var loadingView = LoadingView.initToView(self.view)
    
    private enum SegueIdentifiers: String {
        case gather = "GatherSegueIdentifier"
    }
    
    enum TeamSection: Int, CaseIterable {
        case bench = 0, teamA, teamB
        
        var headerTitle: String {
            switch self {
            case .bench: return "Bench"
            case .teamA: return "Team A"
            case .teamB: return "Team B"
            }
        }
    }
    
    var playersDictionary: [TeamSection: [PlayerResponseModel]] = [:]
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerTableView.isEditing = true
        startGatherButton.isEnabled = false
    }
    
    @IBAction func startGatherAction(_ sender: Any) {
        showLoadingView()
        
        let gatherService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)
        gatherService.create(GatherCreateModel()) { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(ResourceID.uuid(gatherUUID)) = result {
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    self.performSegue(withIdentifier: SegueIdentifiers.gather.rawValue, sender: gatherUUID)
                }
            } else {
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    AlertHelper.present(in: self, title: "Error", message: "Unable to create gather.")
                }
            }
        }
    }
    
}

// MARK: - Loadable conformance
extension ConfirmPlayersViewController: Loadable {}

// MARK: - UITableViewDelegate | UITableViewDataSource

extension ConfirmPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return TeamSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TeamSection(rawValue: section)?.headerTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let team = TeamSection(rawValue: section), let players = playersDictionary[team] else { return 0 }
        
        return players.count
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerChooseTableViewCellId") else {
            return UITableViewCell()
        }
        
        if let team = TeamSection(rawValue: indexPath.section), let players = playersDictionary[team] {
            let player = players[indexPath.row]
            
            cell.textLabel?.text = player.name
            cell.detailTextLabel?.text = player.preferredPosition?.acronym
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let sourceTeam = TeamSection(rawValue: sourceIndexPath.section),
            let sourcePlayer = playersDictionary[sourceTeam]?[sourceIndexPath.row],
            let destinationTeam = TeamSection(rawValue: destinationIndexPath.section) else {
                fatalError("Unable to move players")
        }

        playersDictionary[sourceTeam]?.remove(at: sourceIndexPath.row)
        
        if playersDictionary[destinationTeam]?.isEmpty == false {
            playersDictionary[destinationTeam]?.insert(sourcePlayer, at: destinationIndexPath.row)
        } else {
            playersDictionary[destinationTeam] = [sourcePlayer]
        }
        
        if playersDictionary[.teamA]?.isEmpty == false &&
            playersDictionary[.teamB]?.isEmpty == false {
            startGatherButton.isEnabled = true
        } else {
            startGatherButton.isEnabled = false
        }
    }
}

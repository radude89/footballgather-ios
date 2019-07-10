//
//  ConfirmPlayersViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewController
typealias Team = ConfirmPlayersViewController.TeamSection

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
        
        createGather { [weak self] uuid in
            guard let self = self else { return }
            guard let gatherUUID = uuid else {
                self.handleServiceFailure()
                return
            }
            
            self.addPlayersToGather(havingUUID: gatherUUID)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.gather.rawValue {
            guard let gatherViewController = segue.destination as? GatherViewController,
                let gatherModel = sender as? GatherModel else {
                    return
            }
            
            gatherViewController.gatherModel = gatherModel
        }
    }
    
    private func createGather(completion: @escaping (UUID?) -> Void) {
        let gatherService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)
        gatherService.create(GatherCreateModel()) { result in
            if case let .success(ResourceID.uuid(gatherUUID)) = result {
                completion(gatherUUID)
            } else {
                completion(nil)
            }
        }
    }
    
    private func addPlayersToGather(havingUUID gatherUUID: UUID) {
        let players = self.playerTeamArray
        let dispatchGroup = DispatchGroup()
        var serviceFailed = false
        
        players.forEach { playerTeamModel in
            dispatchGroup.enter()
            
            self.addPlayer(
                playerTeamModel.player,
                toGatherHavingUUID: gatherUUID,
                team: playerTeamModel.team,
                completion: { playerWasAdded in
                    if !playerWasAdded {
                        serviceFailed = true
                    }
                    
                    dispatchGroup.leave()
            })
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            self.hideLoadingView()
            
            if serviceFailed {
                self.handleServiceFailure()
            } else {
                self.performSegue(withIdentifier: SegueIdentifiers.gather.rawValue,
                                  sender: GatherModel(players: players, gatherUUID: gatherUUID))
            }
        }
    }
    
    private func addPlayer(_ player: PlayerResponseModel,
                           toGatherHavingUUID gatherUUID: UUID,
                           team: TeamSection,
                           completion: @escaping (Bool) -> Void) {
        var service = AddPlayerToGatherService()
        service.addPlayer(
            havingServerId: player.id,
            toGatherWithId: gatherUUID,
            team: PlayerGatherTeam(team: team.headerTitle)) { result in
                if case let .success(resultValue) = result {
                    completion(resultValue)
                } else {
                    completion(false)
                }
        }
    }
    
    private func handleServiceFailure() {
        DispatchQueue.main.async {
            self.hideLoadingView()
            AlertHelper.present(in: self, title: "Error", message: "Unable to create gather.")
        }
    }
    
    private var playerTeamArray: [PlayerTeamModel] {
        var players: [PlayerTeamModel] = []
        players += self.playersDictionary
            .filter { $0.key == .teamA }
            .flatMap { $0.value }
            .map { PlayerTeamModel(team: .teamA, player: $0) }
        
        players += self.playersDictionary
            .filter { $0.key == .teamB }
            .flatMap { $0.value }
            .map { PlayerTeamModel(team: .teamB, player: $0) }
        
        return players
    }
    
}

// MARK: - Loadable conformance
extension ConfirmPlayersViewController: Loadable {}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension ConfirmPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Team.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Team(rawValue: section)?.headerTitle
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let team = Team(rawValue: section), let players = playersDictionary[team] else { return 0 }
        
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
        
        if let team = Team(rawValue: indexPath.section), let players = playersDictionary[team] {
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

// MARK: - PlayerTeamModel
struct PlayerTeamModel {
    let team: Team
    let player: PlayerResponseModel
}

extension PlayerTeamModel: Equatable {
    static func ==(lhs: PlayerTeamModel, rhs: PlayerTeamModel) -> Bool {
        return lhs.team == rhs.team && lhs.player == rhs.player
    }
}

extension PlayerTeamModel: Hashable {}

// MARK: - GatherModel
struct GatherModel {
    let players: [PlayerTeamModel]
    let gatherUUID: UUID
}

extension GatherModel: Hashable {}

extension GatherModel: Equatable {
    static func ==(lhs: GatherModel, rhs: GatherModel) -> Bool {
        return lhs.gatherUUID == rhs.gatherUUID && lhs.players == rhs.players
    }
}

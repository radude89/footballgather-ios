//
//  ConfirmPlayersViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewController
final class ConfirmPlayersViewController: UIViewController, Loadable {

    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var startGatherButton: UIButton!

    lazy var loadingView = LoadingView.initToView(self.view)
    
    var playersDictionary: [TeamSection: [PlayerResponseModel]] = [:]
    
    private var addPlayerService = AddPlayerToGatherService()
    private let gatherService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)
    private let dispatchGroup = DispatchGroup()
    private var gatherUUID: UUID?

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    func setupViews() {
        playerTableView.isEditing = true
        configureStartGatherButton()
    }

    private func configureStartGatherButton() {
        startGatherButton.isEnabled = startGatherButtonIsEnabled
    }
    
    private var startGatherButtonIsEnabled: Bool {
        if playersDictionary[.teamA]?.isEmpty == false &&
            playersDictionary[.teamB]?.isEmpty == false {
            return true
        }
        
        return false
    }
    
    private var gatherModel: GatherModel? {
        guard let gatherUUID = gatherUUID else { return nil }
        
        return GatherModel(players: playerTeamArray, gatherUUID: gatherUUID)
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.gather.rawValue,
            let gatherViewController = segue.destination as? GatherViewController,
            let gatherModel = gatherModel {
            gatherViewController.model = gatherModel
        }
    }

    // MARK: - Actions
    @IBAction private func startGather(_ sender: Any) {
        showLoadingView()

        startGather { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoadingView()

                if !result {
                    self?.handleServiceFailure()
                } else {
                    self?.performSegue(withIdentifier: SegueIdentifier.gather.rawValue, sender: nil)
                }
            }
        }
    }
    private func handleServiceFailure() {
        AlertHelper.present(in: self, title: "Error", message: "Unable to create gather.")
    }
    
    // MARK: - Services
    private func startGather(completion: @escaping (Bool) -> ()) {
        createGather { [weak self] uuid in
            guard let gatherUUID = uuid else {
                completion(false)
                return
            }
            
            self?.gatherUUID = gatherUUID
            self?.addPlayersToGather(havingUUID: gatherUUID, completion: completion)
        }
    }
    
    private func createGather(completion: @escaping (UUID?) -> Void) {
        gatherService.create(GatherCreateModel()) { result in
            if case let .success(ResourceID.uuid(gatherUUID)) = result {
                completion(gatherUUID)
            } else {
                completion(nil)
            }
        }
    }
    
    private func addPlayersToGather(havingUUID gatherUUID: UUID, completion: @escaping (Bool) -> ()) {
        var serviceFailed = false
        
        playerTeamArray.forEach { playerTeam in
            dispatchGroup.enter()
            
            self.addPlayer(playerTeam.player, toGatherHavingUUID: gatherUUID, team: playerTeam.team) { [weak self] playerWasAdded in
                if !playerWasAdded {
                    serviceFailed = true
                }
                
                self?.dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completion(serviceFailed)
        }
    }
    
    private func addPlayer(_ player: PlayerResponseModel,
                           toGatherHavingUUID gatherUUID: UUID,
                           team: TeamSection,
                           completion: @escaping (Bool) -> Void) {
        addPlayerService.addPlayer(
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

}

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
        
        if let team = TeamSection(rawValue: indexPath.section) {
            let players = playersDictionary[team]
            cell.textLabel?.text = players?[indexPath.row].name
            cell.detailTextLabel?.text = players?[indexPath.row].preferredPosition?.acronym
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveRowAt(sourceIndexPath: sourceIndexPath, to: destinationIndexPath)
        configureStartGatherButton()
    }
    
    private func moveRowAt(sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
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
    }
}

// MARK: - TeamSection
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

// MARK: - PlayerTeamModel
struct PlayerTeamModel {
    let team: TeamSection
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

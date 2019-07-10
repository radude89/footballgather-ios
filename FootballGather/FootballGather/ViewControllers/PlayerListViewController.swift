//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

class PlayerListViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var bottomActionView: UIView!
    @IBOutlet weak var confirmOrAddPlayersButton: UIButton!
    
    lazy var loadingView = LoadingView.initToView(self.view)
    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(self.view, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()
    
    private lazy var barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPlayers))
    
    // MARK: - Variables
    
    private let playersService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)
    private var players: [PlayerResponseModel] = []
    
    private enum ViewState {
        case list
        case selection
    }
    private var viewState: ViewState = .list {
        didSet {
            if viewState == .list {
                confirmOrAddPlayersButton.setTitle("Add player", for: .normal)
            } else {
                confirmOrAddPlayersButton.setTitle("Confirm players", for: .normal)
            }
        }
    }
    
    private var selectedPlayersDictionary: [Int: PlayerResponseModel] = [:]
    
    private enum SegueIdentifiers: String {
        case confirmPlayers = "ConfirmPlayersSegueIdentifier"
        case addPlayer = "PlayerAddSegueIdentifier"
        case playerDetails = "PlayerDetailSegueIdentifier"
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Players"
        navigationItem.rightBarButtonItem = barButtonItem
        playerTableView.tableFooterView = UIView()
        
        loadPlayers()
    }
    
    // MARK: - Selectors
    
    @objc
    func selectPlayers(sender: UIBarButtonItem) {
        toggleViewState()
    }
    
    func toggleViewState() {
        title = "Players"
        viewState = viewState == .list ? .selection : .list
        
        if viewState == .list {
            barButtonItem.title = "Select"
            confirmOrAddPlayersButton.isEnabled = true
        } else {
            barButtonItem.title = "Cancel"
            confirmOrAddPlayersButton.isEnabled = false
        }
        
        playerTableView.reloadData()
    }
    
    @IBAction func confirmOrAddPlayersAction(_ sender: Any) {
        if viewState == .list {
            performSegue(withIdentifier: SegueIdentifiers.addPlayer.rawValue, sender: nil)
        } else {
            performSegue(withIdentifier: SegueIdentifiers.confirmPlayers.rawValue, sender: nil)
        }
    }
    
    private func loadPlayers() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        view.isUserInteractionEnabled = false
        
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                }
            case .success(let players):
                DispatchQueue.main.async {
                    self.view.isUserInteractionEnabled = true
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    if players.isEmpty {
                        self.showEmptyView()
                    } else {
                        self.hideEmptyView()
                    }

                    self.players = players
                    self.playerTableView.reloadData()
                }
            }
        }
    }
    
    private func deletePlayer(_ player: PlayerResponseModel, completion: @escaping (Bool) -> Void) {
        var service = playersService
        service.delete(withID: ResourceID.integer(player.id)) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                    completion(false)
                }
            case .success(_):
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    completion(true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.confirmPlayers.rawValue {
            guard let confirmPlayersViewController = segue.destination as? ConfirmPlayersViewController else { return }
            
            let selectedPlayers = Array(selectedPlayersDictionary.values)
            confirmPlayersViewController.playersDictionary[.bench] = selectedPlayers
        } else if segue.identifier == SegueIdentifiers.playerDetails.rawValue {
            guard let playerDetailsViewController = segue.destination as? PlayerDetailViewController,
                let player = sender as? PlayerResponseModel else { return }
            
            playerDetailsViewController.delegate = self
            playerDetailsViewController.player = player
        } else if segue.identifier == SegueIdentifiers.addPlayer.rawValue {
            guard let addPlayerViewController = segue.destination as? PlayerAddViewController else { return }
            
            addPlayerViewController.delegate = self
        }
    }
    
}

extension PlayerListViewController: PlayerDetailViewControllerDelegate {
    func didEdit(player: PlayerResponseModel) {
        guard let index = players.firstIndex(of: player) else { return }
        
        players[index] = player
        
        let indexPath = IndexPath(row: index, section: 0)
        playerTableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: PlayerTableViewCell = tableView.dequeueReusableCell(withIdentifier: "PlayerTableViewCell") as? PlayerTableViewCell else {
            return UITableViewCell()
        }
        
        if viewState == .list {
            selectedPlayersDictionary[indexPath.row] = nil
            cell.setupDefaultView()
        } else {
            cell.setupSelectionView()
        }
        
        let player = players[indexPath.row]
        cell.nameLabel.text = player.name
        
        if let position = player.preferredPosition {
            cell.positionLabel.text = "Position: \(position.rawValue)"
        } else {
            cell.positionLabel.text = "Position: -"
        }
        
        if let skill = player.skill {
            cell.skillLabel.text = "Skill: \(skill.rawValue)"
        } else {
            cell.skillLabel.text = "Skill: -"
        }
        
        cell.playerIsSelected = selectedPlayersDictionary[indexPath.row] != nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !players.isEmpty else { return }
        
        if viewState == .list {
            let player = players[indexPath.row]
            performSegue(withIdentifier: SegueIdentifiers.playerDetails.rawValue, sender: player)
        } else {
            guard let cell: PlayerTableViewCell = tableView.cellForRow(at: indexPath) as? PlayerTableViewCell else {
                return
            }
            
            cell.playerIsSelected = !cell.playerIsSelected
            
            if cell.playerIsSelected {
                selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
            } else {
                selectedPlayersDictionary[indexPath.row] = nil
            }
            
            let selectedPlayers = selectedPlayersDictionary.values.count
            title = selectedPlayers > 0 ? "\(selectedPlayers) selected" : "Players"
            confirmOrAddPlayersButton.isEnabled = selectedPlayers >= 2
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewState == .selection {
            return false
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let alertController = UIAlertController(title: "Delete player", message: "Are you sure you want to delete the selected player?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            let player = self.players[indexPath.row]
            self.deletePlayer(player, completion: { [weak self] result in
                guard result, let self = self else { return }
                
                tableView.beginUpdates()
                self.selectedPlayersDictionary[indexPath.row] = nil
                self.players.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.endUpdates()
                
                if self.players.isEmpty {
                    self.showEmptyView()
                }
            })
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Loadable conformance
extension PlayerListViewController: Loadable {}

// MARK: - Emptyable conformance
extension PlayerListViewController: EmptyViewable {
    func showEmptyView() {
        playerTableView.isHidden = true
        emptyView.isHidden = false
    }
    
    func hideEmptyView() {
        playerTableView.isHidden = false
        emptyView.isHidden = true
    }
    
    func retryAction() {
        hideEmptyView()
        loadPlayers()
    }
}

// MARK: - AddPlayerDelegate
extension PlayerListViewController: AddPlayerDelegate {
    func playerWasAdded(name: String) {
        loadPlayers()
    }
}

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
    @IBOutlet weak var bottomActionViewHeightConstraint: NSLayoutConstraint!
    
    lazy var loadingView = LoadingView.initToView(self.view)
    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(self.view, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()
    
    private lazy var barButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPlayers))
    
    // MARK: - Variables
    
    private let playersService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)
    private var players: [PlayerResponseModel] = []
    
    private enum ViewState {
        case list
        case selection
    }
    private var viewState: ViewState = .list
    
    private var selectedPlayersDictionary: [Int: PlayerResponseModel] = [:]
    
    private enum ViewConstants {
        static let bottomViewHeight: CGFloat = 80.0
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bottomActionViewHeightConstraint.constant = 0
        bottomActionView.isHidden = true
        
        title = "Players"
        navigationItem.rightBarButtonItem = barButtonItem
        playerTableView.tableFooterView = UIView()
        
        loadPlayers()
    }
    
    // MARK: - Selectors
    
    @objc func selectPlayers(sender: UIBarButtonItem) {
        // toggle
        title = "Players"
        viewState = viewState == .list ? .selection : .list
        
        if viewState == .list {
            sender.title = "Select"
            bottomActionViewHeightConstraint.constant = 0
            bottomActionView.isHidden = true
        } else {
            sender.title = "Cancel"
            bottomActionViewHeightConstraint.constant = ViewConstants.bottomViewHeight
            bottomActionView.isHidden = false
        }
        
        playerTableView.reloadData()
    }
    
    @IBAction func startGatherAction(_ sender: Any) {
        showLoadingView()
        
        let gatherService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)
        gatherService.create(GatherCreateModel()) { [weak self] result in
            guard let self = self else { return }
            
            if case let .success(ResourceID.uuid(gatherUUID)) = result {
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    self.performSegue(withIdentifier: "StartGatherSegueIdentifier", sender: gatherUUID)
                }
            } else {
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    AlertHelper.present(in: self, title: "Error", message: "Unable to create gather.")
                }
            }
        }
    }
    
    private func loadPlayers() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                }
            case .success(let players):
                DispatchQueue.main.async {
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
        guard segue.identifier == "StartGatherSegueIdentifier" else { return }
        guard let startGatherViewController = segue.destination as? StartGatherViewController,
            let gatherUUID = sender as? UUID else { return }
        
        startGatherViewController.gatherUUID = gatherUUID
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
        if viewState == .list {
            // TODO: go to next screen
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

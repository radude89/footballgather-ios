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
        
    }
    
    @IBAction func deletePlayerAction(_ sender: Any) {
        
    }
    
    private func loadPlayers() {
        showLoadingView()
        
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    AlertHelper.present(in: self, title: "Error", message: String(describing: error))
                }
            case .success(let players):
                DispatchQueue.main.async {
                    self.hideLoadingView()
                    
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

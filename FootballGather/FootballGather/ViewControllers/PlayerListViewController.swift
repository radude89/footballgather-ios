//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

class PlayerListViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    
    lazy var loadingView = LoadingView.initToView(self.view)
    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(self.view, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()
    
    private let playersService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)
    private var players: [PlayerResponseModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playerTableView.tableFooterView = UIView()
        loadPlayers()
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
        
        return cell
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

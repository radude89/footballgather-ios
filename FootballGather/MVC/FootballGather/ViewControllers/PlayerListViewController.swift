//
//  PlayerListViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 06/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerListTogglable
protocol PlayerListTogglable {
    func toggleViewState()
}

// MARK: - PlayerListViewController
final class PlayerListViewController: UIViewController, Loadable {

    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var bottomActionView: UIView!
    @IBOutlet weak var bottomActionButton: UIButton!

    lazy var loadingView = LoadingView.initToView(self.view)
    private var barButtonItem: UIBarButtonItem!
    
    lazy var emptyView: EmptyView = {
        let emptyView = EmptyView.initToView(self.view, infoText: "There aren't any players for your user.")
        emptyView.delegate = self
        return emptyView
    }()
    
    private let playersService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)
    private var players: [PlayerResponseModel] = []
    private var viewState: ViewState = .list
    private var viewStateDetails: LoginViewStateDetails {
        return ViewStateDetailsFactory.makeViewStateDetails(from: viewState)
    }
    
    private(set) var selectedPlayersDictionary: [Int: PlayerResponseModel] = [:]
    private(set) var selectedPlayerForDetails: PlayerResponseModel?
    
    fileprivate let minimumPlayersToPlay = 2

    // MARK: - Setup methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
        setupBarButtonItem()
        setupTableView()
        loadPlayers()
    }
    
    private func setupTitle() {
        title = "Players"
    }

    private func setupBarButtonItem() {
        barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPlayers))
        navigationItem.rightBarButtonItem = barButtonItem
    }

    private func setupTableView() {
        playerTableView.tableFooterView = UIView()
    }

    // MARK: - Selectors
    @objc private func selectPlayers() {
        toggleViewState()
    }

    @IBAction private func confirmOrAddPlayers(_ sender: Any) {
        performSegue(withIdentifier: viewStateDetails.segueIdentifier, sender: nil)
    }

    // MARK: - Service methods
    private func loadPlayers() {
        view.isUserInteractionEnabled = false
        
        playersService.get { [weak self] (result: Result<[PlayerResponseModel], Error>) in
            DispatchQueue.main.async {
                self?.view.isUserInteractionEnabled = true
                
                switch result {
                case .failure(let error):
                    self?.handleServiceFailures(withError: error)
                    
                case .success(let players):
                    self?.players = players
                    self?.handleLoadPlayersSuccessfulResponse()
                }
            }
        }
    }

    private func handleServiceFailures(withError error: Error) {
        AlertHelper.present(in: self, title: "Error", message: String(describing: error))
    }

    private func handleLoadPlayersSuccessfulResponse() {
        if players.isEmpty {
            showEmptyView()
        } else {
            hideEmptyView()
        }

        playerTableView.reloadData()
    }

    private func requestDeletePlayer(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let player = players[indexPath.row]
        var service = playersService
        
        service.delete(withID: ResourceID.integer(player.id)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.handleServiceFailures(withError: error)
                    completion(false)
                    
                case .success(_):
                    completion(true)
                }
            }
        }
    }

    private func reloadRow(_ row: Int) {
        let indexPath = IndexPath(row: row, section: 0)
        playerTableView.reloadRows(at: [indexPath], with: .none)
    }

    // MARK: - Next screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case SegueIdentifier.confirmPlayers.rawValue:
            if let confirmPlayersViewController = segue.destination as? ConfirmPlayersViewController {
                var playersDictionary: [TeamSection: [PlayerResponseModel]] = [:]
                playersDictionary[.bench] = Array(selectedPlayersDictionary.values)
                
                confirmPlayersViewController.playersDictionary = playersDictionary
            }

        case SegueIdentifier.playerDetails.rawValue:
            if let playerDetailsViewController = segue.destination as? PlayerDetailViewController,
                let player = selectedPlayerForDetails {
                playerDetailsViewController.delegate = self
                playerDetailsViewController.player = player
            }

        case SegueIdentifier.addPlayer.rawValue:
            (segue.destination as? PlayerAddViewController)?.delegate = self

        default:
            break
        }
    }

}

// MARK: - PlayerDetailViewControllerDelegate
extension PlayerListViewController: PlayerDetailViewControllerDelegate {
    func didEdit(player: PlayerResponseModel) {
        guard let index = players.firstIndex(of: player) else { return }

        players[index] = player
        reloadRow(index)
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerListViewController: UITableViewDelegate, UITableViewDataSource {
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
            selectedPlayerForDetails = players[indexPath.row]
            navigateToPlayerDetails(forRowAt: indexPath)
        } else {
            toggleCellSelection(at: indexPath)
            updateViewForPlayerSelection()
        }
    }

    private func navigateToPlayerDetails(forRowAt indexPath: IndexPath) {
        selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
        performSegue(withIdentifier: SegueIdentifier.playerDetails.rawValue, sender: nil)
    }

    private func toggleCellSelection(at indexPath: IndexPath) {
        guard let cell = playerTableView.cellForRow(at: indexPath) as? PlayerTableViewCell else { return }

        cell.playerIsSelected.toggle()
                
        if cell.playerIsSelected {
            selectedPlayersDictionary[indexPath.row] = players[indexPath.row]
        } else {
            selectedPlayersDictionary[indexPath.row] = nil
        }
    }
    
    private func updateViewForPlayerSelection() {
        let selectedPlayersCount = selectedPlayersDictionary.values.count
        title = selectedPlayersCount > 0 ? "\(selectedPlayersCount) selected" : "Players"

        bottomActionButton.isEnabled = selectedPlayersDictionary.values.count >= minimumPlayersToPlay
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewState == .list
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        let alertController = UIAlertController(title: "Delete player", message: "Are you sure you want to delete the selected player?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.handleDeletePlayerConfirmation(forRowAt: indexPath)
        }
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func handleDeletePlayerConfirmation(forRowAt indexPath: IndexPath) {
        showLoadingView()
        requestDeletePlayer(at: indexPath) { [weak self] result in
            guard result, let self = self else { return }

            self.playerTableView.beginUpdates()
            self.players.remove(at: indexPath.row)
            self.playerTableView.deleteRows(at: [indexPath], with: .fade)
            self.playerTableView.endUpdates()

            if self.players.isEmpty {
                self.showEmptyView()
            }
        }
    }
}

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
    func playerWasAdded() {
        loadPlayers()
    }
}

// MARK: - PlayerListToggable
extension PlayerListViewController: PlayerListTogglable {
    func toggleViewState() {
        viewState.toggle()
        barButtonItem.title = viewStateDetails.barButtonItemTitle
        bottomActionButton.setTitle(viewStateDetails.actionButtonTitle, for: .normal)
        bottomActionButton.isEnabled = viewStateDetails.actionButtonIsEnabled
        playerTableView.reloadData()
    }
}

// MARK: - Models
protocol LoginViewStateDetails {
    var barButtonItemTitle: String { get }
    var actionButtonIsEnabled: Bool { get }
    var actionButtonTitle: String { get }
    var segueIdentifier: String { get }
}

extension PlayerListViewController {
    enum ViewState {
        case list
        case selection
        
        mutating func toggle() {
            self = self == .list ? .selection : .list
        }
    }
}

fileprivate extension PlayerListViewController {
    
    struct ListViewStateDetails: LoginViewStateDetails {
        var barButtonItemTitle: String {
            return "Select"
        }
        
        var actionButtonIsEnabled: Bool {
            return false
        }
        
        var segueIdentifier: String {
            return SegueIdentifier.addPlayer.rawValue
        }
        
        var actionButtonTitle: String {
            return "Add player"
        }
    }

    struct SelectionViewStateDetails: LoginViewStateDetails {
        var barButtonItemTitle: String {
            return "Cancel"
        }
        
        var actionButtonIsEnabled: Bool {
            return true
        }
        
        var segueIdentifier: String {
            return SegueIdentifier.confirmPlayers.rawValue
        }
        
        var actionButtonTitle: String {
            return "Confirm players"
        }
    }

    enum ViewStateDetailsFactory {
        static func makeViewStateDetails(from viewState: ViewState) -> LoginViewStateDetails {
            switch viewState {
            case .list:
                return ListViewStateDetails()
                
            case .selection:
                return SelectionViewStateDetails()
            }
        }
    }
}

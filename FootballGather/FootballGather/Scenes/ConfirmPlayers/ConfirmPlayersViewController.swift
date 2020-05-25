//
//  ConfirmPlayersViewController.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewController
final class ConfirmPlayersViewController: UIViewController, ConfirmPlayersViewable {
    
    // MARK: - Properties
    @IBOutlet private weak var playerTableView: UITableView!
    @IBOutlet private weak var startGatherButton: UIButton!

    lazy var loadingView = LoadingView.initToView(view)
    
    var interactor: ConfirmPlayersInteractorProtocol = ConfirmPlayersInteractor()
    var router: ConfirmPlayersRouterProtocol = ConfirmPlayersRouter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTitle("Confirm Players")
        tableViewIsEditing(true)
        setStartGatherButtonState(isEnabled: false)
    }
    
    private func configureTitle(_ title: String) {
        self.title = title
    }
    
    private func tableViewIsEditing(_ isEditing: Bool) {
        playerTableView.isEditing = isEditing
    }
    
    private func setStartGatherButtonState(isEnabled: Bool) {
        startGatherButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    @IBAction private func startGather(_ sender: Any) {
        showLoadingView()
        
        let request = ConfirmPlayers.StartGather.Request()
        interactor.startGather(request: request)
    }
    
}

// MARK: - Configuration
extension ConfirmPlayersViewController: ConfirmPlayersViewConfigurable {
    func configureStartGatherButton(viewModel: ConfirmPlayers.Move.ViewModel) {
        setStartGatherButtonState(isEnabled: viewModel.startGatherButtonIsEnabled)
    }
    
    func showGatherView(gather: GatherModel, delegate: GatherDelegate) {
        router.showGatherView(for: gather, delegate: delegate)
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension ConfirmPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let request = ConfirmPlayers.SectionsCount.Request()
        return interactor.numberOfSections(request: request)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let request = ConfirmPlayers.RowsCount.Request(section: section)
        return interactor.numberOfRowsInSection(request: request)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerChooseTableViewCellId") else {
            return UITableViewCell()
        }
        
        let request = ConfirmPlayers.RowDetails.Request(indexPath: indexPath)
        let rowViewModel = interactor.rowDetails(request: request)
        
        cell.textLabel?.text = rowViewModel?.titleLabelText
        cell.detailTextLabel?.text = rowViewModel?.descriptionLabelText

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let request = ConfirmPlayers.SectionTitle.Request(section: section)
        let viewModel = interactor.titleForHeaderInSection(request: request)
        return viewModel.title
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }


    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let request = ConfirmPlayers.Move.Request(sourceIndexPath: sourceIndexPath,
                                                  destinationIndexPath: destinationIndexPath)
        interactor.move(request: request)
    }
}

// MARK: - Loadable
extension ConfirmPlayersViewController: Loadable {}

// MARK: - Error Handler
extension ConfirmPlayersViewController: ConfirmPlayersViewErrorHandler {}

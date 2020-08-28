//
//  ConfirmPlayersView.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewProtocol
protocol ConfirmPlayersViewProtocol: AnyObject {
    func setupView()
    func showLoadingView()
    func hideLoadingView()
    func handleError(title: String, message: String)
    func handleSuccessfulStartGather()
}

// MARK: - ConfirmPlayersViewDelegate
protocol ConfirmPlayersViewDelegate: AnyObject {
    func presentAlert(title: String, message: String)
    func didStartGather(_ gather: GatherModel)
}

// MARK: - ConfirmPlayersView
final class ConfirmPlayersView: UIView, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var startGatherButton: UIButton!

    lazy var loadingView = LoadingView.initToView(self)
    
    weak var delegate: ConfirmPlayersViewDelegate?
    var presenter: ConfirmPlayersPresenterProtocol!
    
    // MARK: - Private methods
    private func configureStartGatherButton() {
        startGatherButton.isEnabled = presenter.startGatherButtonIsEnabled
    }
    
    @IBAction private func startGather(_ sender: Any) {
        presenter.initiateStartGather()
    }

}

// MARK: - Public API
extension ConfirmPlayersView: ConfirmPlayersViewProtocol {
    
    func setupView() {
        playerTableView.isEditing = true
        configureStartGatherButton()
    }
    
    func handleError(title: String, message: String) {
        delegate?.presentAlert(title: title, message: message)
    }
    
    func handleSuccessfulStartGather() {
        delegate?.didStartGather(presenter.gatherModel!)
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension ConfirmPlayersView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.titleForHeaderInSection(section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(section)
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

        cell.textLabel?.text = presenter.rowTitle(at: indexPath)
        cell.detailTextLabel?.text = presenter.rowDescription(at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        presenter.moveRowAt(sourceIndexPath: sourceIndexPath, to: destinationIndexPath)
        configureStartGatherButton()
    }
}

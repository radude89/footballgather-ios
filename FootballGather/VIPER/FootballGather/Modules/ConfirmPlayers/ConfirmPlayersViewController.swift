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
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var startGatherButton: UIButton!

    lazy var loadingView = LoadingView.initToView(view)
    
    var presenter: ConfirmPlayersPresenterProtocol = ConfirmPlayersPresenter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction private func startGather(_ sender: Any) {
        presenter.startGather()
    }

}

// MARK: - Configuration
extension ConfirmPlayersViewController: ConfirmPlayersViewConfigurable {
    func configureTitle(_ title: String) {
        self.title = title
    }
    
    func tableViewIsEditing(_ isEditing: Bool) {
        playerTableView.isEditing = isEditing
    }
    
    func setStartGatherButtonState(isEnabled: Bool) {
        startGatherButton.isEnabled = isEnabled
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension ConfirmPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerChooseTableViewCellId") else {
            return UITableViewCell()
        }
        
        let cellPresenter = ConfirmPlayersTableViewCellPresenter(view: cell)
        cellPresenter.configure(title: presenter.rowTitle(at: indexPath), descriptionDetails: presenter.rowDescription(at: indexPath))

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        presenter.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }


    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        presenter.moveRowAt(sourceIndexPath: sourceIndexPath, to: destinationIndexPath)
    }
}

// MARK: - UITableViewCell
extension UITableViewCell: ConfirmPlayersTableViewCellProtocol {
    func setTextLabel(_ text: String?) {
        textLabel?.text = text
    }
    
    func setDetailLabel(_ text: String?) {
        detailTextLabel?.text = text
    }
}

// MARK: - Loadable
extension ConfirmPlayersViewController: Loadable {}

// MARK: - Error Handler
extension ConfirmPlayersViewController: ErrorHandler {}

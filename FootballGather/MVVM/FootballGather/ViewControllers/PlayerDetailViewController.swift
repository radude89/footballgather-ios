//
//  PlayerDetailViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerDetailViewControllerDelegate
protocol PlayerDetailViewControllerDelegate: AnyObject {
    func didEdit(player: PlayerResponseModel)
}

// MARK: - PlayerDetailViewController
final class PlayerDetailViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var playerDetailTableView: UITableView!

    weak var delegate: PlayerDetailViewControllerDelegate?
    var viewModel: PlayerDetailViewModel!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }

    private func setupTitle() {
        title = viewModel.title
    }

    private func reloadData() {
        playerDetailTableView.reloadData()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == SegueIdentifier.editPlayer.rawValue,
            let destinationViewController = segue.destination as? PlayerEditViewController else {
                return
        }

        destinationViewController.viewModel = viewModel.makeEditViewModel()
        destinationViewController.delegate = self
    }

}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerDetailTableViewCell") as? PlayerDetailTableViewCell else {
            return UITableViewCell()
        }

        cell.leftLabel.text = viewModel.rowTitleDescription(for: indexPath)
        cell.rightLabel.text = viewModel.rowValueDescription(for: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeaderInSection(section)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectPlayerRow(at: indexPath)
        performSegue(withIdentifier: SegueIdentifier.editPlayer.rawValue, sender: nil)
    }
}

// MARK: - PlayerEditViewControllerDelegate
extension PlayerDetailViewController: PlayerEditViewControllerDelegate {
    func didFinishEditing(player: PlayerResponseModel) {
        setupTitle()
        viewModel.updatePlayer(player)
        viewModel.reloadSections()
        reloadData()
        delegate?.didEdit(player: player)
    }
}

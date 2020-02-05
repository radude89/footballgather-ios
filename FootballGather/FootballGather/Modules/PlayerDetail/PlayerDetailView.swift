//
//  PlayerDetailView.swift
//  FootballGather
//
//  Created by Radu Dan on 24/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerDetailViewProtocol
protocol PlayerDetailViewProtocol: AnyObject {
    var title: String { get }
    
    func reloadData()
    func updateData(player: PlayerResponseModel)
}

// MARK: - PlayerDetailViewDelegate
protocol PlayerDetailViewDelegate: AnyObject {
    func didRequestEditView()
}

// MARK: - PlayerDetailView
final class PlayerDetailView: UIView, PlayerDetailViewProtocol {
    
    // MARK: - Properties
    @IBOutlet weak var playerDetailTableView: UITableView!
    
    weak var delegate: PlayerDetailViewDelegate?
    var presenter: PlayerDetailPresenterProtocol!
    
    // MARK: - Public API
    var title: String {
        return presenter.title
    }
    
    func reloadData() {
        playerDetailTableView.reloadData()
    }
    
    func updateData(player: PlayerResponseModel) {
        presenter.updatePlayer(player)
        presenter.reloadSections()
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension PlayerDetailView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.numberOfSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerDetailTableViewCell") as? PlayerDetailTableViewCell else {
            return UITableViewCell()
        }

        cell.leftLabel.text = presenter.rowTitleDescription(for: indexPath)
        cell.rightLabel.text = presenter.rowValueDescription(for: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.titleForHeaderInSection(section)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectPlayerRow(at: indexPath)
        delegate?.didRequestEditView()
    }
}

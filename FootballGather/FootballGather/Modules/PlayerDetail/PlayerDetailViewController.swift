//
//  PlayerDetailViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - PlayerDetailViewController
final class PlayerDetailViewController: UIViewController, PlayerDetailViewable {

    // MARK: - Properties
    @IBOutlet weak var playerDetailTableView: UITableView!
    
    var presenter: PlayerDetailPresenterProtocol!

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
}

// MARK: - Configuration
extension PlayerDetailViewController: PlayerDetailViewConfigurable {
    func configureTitle(_ title: String) {
        self.title = title
    }
}
    
// MARK: - Reload
extension PlayerDetailViewController: PlayerDetailViewReloadable {
    func reloadData() {
        playerDetailTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource | UITableViewDelegate
extension PlayerDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerDetailTableViewCell") as? PlayerDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let cellPresenter = PlayerDetailTableViewCellPresenter(view: cell)
        cellPresenter.configure(with: presenter.rowDetails(at: indexPath))

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        presenter.titleForHeaderInSection(section)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.selectRow(at: indexPath)
    }
}

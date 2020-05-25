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
    @IBOutlet private weak var playerDetailTableView: UITableView!
    
    var interactor: PlayerDetailInteractorProtocol!
    var router: PlayerDetailRouterProtocol = PlayerDetailRouter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
    }
    
    private func setupTitle() {
        let request = PlayerDetail.ConfigureTitle.Request()
        interactor.configureTitle(request: request)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
}

// MARK: - Configuration
extension PlayerDetailViewController: PlayerDetailViewConfigurable {
    func displayTitle(viewModel: PlayerDetail.ConfigureTitle.ViewModel) {
        title = viewModel.title
    }
}

// MARK: - Router
extension PlayerDetailViewController: PlayerDetailRoutable {
    func showEditView(playerEditable: PlayerEditable, delegate: PlayerEditDelegate) {
        router.showEditView(with: playerEditable, delegate: delegate)
    }
}

// MARK: - Reload
extension PlayerDetailViewController: PlayerDetailReloadable {
    func reloadData() {
        playerDetailTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource | UITableViewDelegate
extension PlayerDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        let request = PlayerDetail.SectionsCount.Request()
        return interactor.numberOfSections(request: request)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let request = PlayerDetail.RowsCount.Request(section: section)
        return interactor.numberOfRowsInSection(request: request)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerDetailTableViewCell") as? PlayerDetailTableViewCell else {
            return UITableViewCell()
        }
        
        let request = PlayerDetail.RowDetails.Request(indexPath: indexPath)
        let rowViewModel = interactor.rowDetails(request: request)
        
        cell.setLeftLabelText(rowViewModel.leftLabelText)
        cell.setRightLabelText(rowViewModel.rightLabelText)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let request = PlayerDetail.SectionTitle.Request(section: section)
        let viewModel = interactor.titleForHeaderInSection(request: request)

        return viewModel.title
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = PlayerDetail.SelectRow.Request(indexPath: indexPath)
        interactor.selectRow(request: request)
    }
}

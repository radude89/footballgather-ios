//
//  ConfirmPlayersViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 26/06/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - ConfirmPlayersViewController
final class ConfirmPlayersViewController: UIViewController, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var startGatherButton: UIButton!
    
    lazy var loadingView = LoadingView.initToView(self.view)
    
    var viewModel: ConfirmPlayersViewModel = ConfirmPlayersViewModel()
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews() {
        playerTableView.isEditing = viewModel.playerTableViewIsEditing
        configureStartGatherButton()
    }
    
    private func configureStartGatherButton() {
        startGatherButton.isEnabled = viewModel.startGatherButtonIsEnabled
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.gather.rawValue,
            let gatherViewController = segue.destination as? GatherViewController, let gatherModel = viewModel.gatherModel {
            let gatherViewModel = GatherViewModel(gatherModel: gatherModel)
            gatherViewController.viewModel = gatherViewModel
        }
    }
    
    // MARK: - Actions
    @IBAction private func startGatherAction(_ sender: Any) {
        showLoadingView()
        
        viewModel.startGather { [weak self] result in
            DispatchQueue.main.async {
                self?.hideLoadingView()
                
                if !result {
                    self?.handleServiceFailure()
                } else {
                    self?.performSegue(withIdentifier: SegueIdentifier.gather.rawValue, sender: nil)
                }
            }
        }
    }
    private func handleServiceFailure() {
        AlertHelper.present(in: self, title: "Error", message: "Unable to create gather.")
    }

}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension ConfirmPlayersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
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
        
        cell.textLabel?.text = viewModel.rowTitle(at: indexPath)
        cell.detailTextLabel?.text = viewModel.rowDescription(at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveRowAt(sourceIndexPath: sourceIndexPath, to: destinationIndexPath)
        configureStartGatherButton()
    }
}

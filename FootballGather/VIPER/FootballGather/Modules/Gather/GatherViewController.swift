//
//  GatherViewController.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - GatherViewController
final class GatherViewController: UIViewController, GatherViewable {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var scoreLabelView: ScoreLabelView!
    @IBOutlet weak var scoreStepper: ScoreStepper!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var actionTimerButton: UIButton!

    lazy var loadingView = LoadingView.initToView(view)
    
    var presenter: GatherPresenterProtocol!
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    // MARK: - IBActions
    @IBAction private func endGather(_ sender: Any) {
        presenter.requestToEndGather()
    }

    @IBAction private func setTimer(_ sender: Any) {
        presenter.setTimer()
    }

    @IBAction private func cancelTimer(_ sender: Any) {
        presenter.cancelTimer()
    }

    @IBAction private func actionTimer(_ sender: Any) {
        presenter.actionTimer()
    }

    @IBAction private func timerCancel(_ sender: Any) {
        presenter.timerCancel()
    }

    @IBAction private func timerDone(_ sender: Any) {
        presenter.timerDone()
    }
    
}

// MARK: - Configuration
extension GatherViewController: GatherViewConfigurable {
    var scoreDescription: String {
        scoreLabelView.scoreDescription
    }
    
    var winnerTeamDescription: String {
        scoreLabelView.winnerTeamDescription
    }
    
    func configureTitle(_ title: String) {
        self.title = title
    }
    
    func setActionButtonTitle(_ title: String) {
        actionTimerButton.setTitle(title, for: .normal)
    }
    
    func setupScoreStepper() {
        scoreStepper.delegate = self
    }
    
    func setTimerViewVisibility(isHidden: Bool) {
        timerView.isHidden = isHidden
    }
    
    func selectRow(_ row: Int, inComponent component: Int, animated: Bool = false) {
        timePickerView.selectRow(row, inComponent: component, animated: animated)
    }
    
    func selectedRow(in component: Int) -> Int {
        timePickerView.selectedRow(inComponent: component)
    }
    
    func setTimerLabelText(_ text: String) {
        timerLabel.text = text
    }
    
    func setTeamALabelText(_ text: String) {
        scoreLabelView.teamAScoreLabel.text = text
    }
    
    func setTeamBLabelText(_ text: String) {
        scoreLabelView.teamBScoreLabel.text = text
    }
}
    
// MARK: - Reload
extension GatherViewController: GatherViewReloadable {
    func reloadData() {
        timePickerView.reloadAllComponents()
        playerTableView.reloadData()
    }
}

// MARK: - Confirmation
extension GatherViewController: GatherViewConfirmable {
    func displayConfirmationAlert() {
        let alertController = UIAlertController(title: "End Gather", message: "Are you sure you want to end the gather?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.presenter.endGather()
        }
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension GatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        presenter.numberOfSections
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        presenter.titleForHeaderInSection(section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatherCellId") else {
            return UITableViewCell()
        }

        let cellPresenter = GatherTableViewCellPresenter(view: cell)
        cellPresenter.configure(title: presenter.rowTitle(at: indexPath), descriptionDetails: presenter.rowDescription(at: indexPath))

        return cell
    }
}

// MARK: - UIPickerViewDataSource
extension GatherViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        presenter.numberOfPickerComponents
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        presenter.numberOfRowsInPickerComponent(component)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        presenter.titleForPickerRow(row, forComponent: component)
    }
}

// MARK: - ScoreStepperDelegate
extension GatherViewController: ScoreStepperDelegate {
    func stepper(_ stepper: UIStepper, didChangeValueForTeam team: TeamSection, newValue: Double) {
        presenter.updateValue(for: team, with: newValue)
    }
}

// MARK: - UITableViewCell
extension UITableViewCell: GatherTableViewCellProtocol {}

// MARK: - Loadable
extension GatherViewController: Loadable {}

// MARK: - Error Handler
extension GatherViewController: ErrorHandler {}

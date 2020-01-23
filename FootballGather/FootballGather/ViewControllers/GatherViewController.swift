//
//  GatherViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 05/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - GatherViewController
final class GatherViewController: UIViewController, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var scoreLabelView: ScoreLabelView!
    @IBOutlet weak var scoreStepper: ScoreStepper!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var actionTimerButton: UIButton!
    
    lazy var loadingView = LoadingView.initToView(self.view)
        
    var viewModel: GatherViewModel!
    
    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewModel()
        setupTitle()
        configureSelectedTime()
        hideTimerView()
        configureTimePickerView()
        configureActionTimerButton()
        setupScoreStepper()
        reloadData()
    }
    
    private func setupTitle() {
        title = viewModel.title
    }
    
    private func setupViewModel() {
        viewModel.delegate = self
    }
    
    private func configureSelectedTime() {
        timerLabel?.text = viewModel.formattedCountdownTimerLabelText
    }
    
    private func configureActionTimerButton() {
        actionTimerButton.setTitle(viewModel.formattedActionTitleText, for: .normal)
    }
    
    private func hideTimerView() {
        timerView.isHidden = true
    }
    
    private func showTimerView() {
        timerView.isHidden = false
    }
    
    private func setupScoreStepper() {
        scoreStepper.delegate = self
    }
    
    private func reloadData() {
        timePickerView.reloadAllComponents()
        playerTableView.reloadData()
    }
    
    // MARK: - IBActions
    @IBAction private func endGather(_ sender: Any) {
        let alertController = UIAlertController(title: "End Gather", message: "Are you sure you want to end the gather?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            self?.endGather()
        }
        alertController.addAction(confirmAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Timer
    @IBAction private func setTimer(_ sender: Any) {
        configureTimePickerView()
        showTimerView()
    }
    
    @IBAction private func cancelTimer(_ sender: Any) {
        viewModel.stopTimer()
        viewModel.resetTimer()
        configureSelectedTime()
        configureActionTimerButton()
        hideTimerView()
    }
    
    @IBAction private func actionTimer(_ sender: Any) {
        viewModel.toggleTimer()
        configureActionTimerButton()
    }
    
    @IBAction private func timerCancel(_ sender: Any) {
        hideTimerView()
    }
    
    @IBAction private func timerDone(_ sender: Any) {
        viewModel.stopTimer()
        viewModel.setTimerMinutes(selectedMinutesRow)
        viewModel.setTimerSeconds(selectedSecondsRow)
        configureSelectedTime()
        configureActionTimerButton()
        hideTimerView()
    }
    
    private var selectedMinutesRow: Int { timePickerView.selectedRow(inComponent: viewModel.minutesComponent) }
    private var selectedSecondsRow: Int { timePickerView.selectedRow(inComponent: viewModel.secondsComponent) }
        
    // MARK: - Private methods
    private func configureTimePickerView() {
        timePickerView.selectRow(viewModel.selectedMinutes, inComponent: viewModel.minutesComponent, animated: false)
        timePickerView.selectRow(viewModel.selectedSeconds, inComponent: viewModel.secondsComponent, animated: false)
    }
    
    private func handleServiceFailure() {
        AlertHelper.present(in: self, title: "Error update", message: "Unable to update gather. Please try again.")
    }
    
    private func handleServiceSuccess() {
        guard let playerListTogglable = navigationController?.viewControllers.first(where: { $0 is PlayerListTogglable }) as? PlayerListTogglable else {
            return
        }
        
        playerListTogglable.toggleViewState()
        
        if let playerListViewController = playerListTogglable as? UIViewController {
            navigationController?.popToViewController(playerListViewController, animated: true)
        }
    }
    
    private func endGather() {
        guard let scoreTeamAString = scoreLabelView.teamAScoreLabel.text,
            let scoreTeamBString = scoreLabelView.teamBScoreLabel.text else {
                return
        }
        
        showLoadingView()
        
        viewModel.endGather(teamAScoreLabelText: scoreTeamAString, teamBScoreLabelText: scoreTeamBString) { [weak self] updated in
            DispatchQueue.main.async {
                self?.hideLoadingView()
                
                if !updated {
                    self?.handleServiceFailure()
                } else {
                    self?.handleServiceSuccess()
                }
            }
        }
    }
    
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension GatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.titleForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRowsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatherCellId") else {
            return UITableViewCell()
        }
        
        let rowDescription = viewModel.rowDescription(at: indexPath)
        
        cell.textLabel?.text = rowDescription.title
        cell.detailTextLabel?.text = rowDescription.details
        
        return cell
    }
}

// MARK: - ScoreStepperDelegate
extension GatherViewController: ScoreStepperDelegate {
    func stepper(_ stepper: UIStepper, didChangeValueForTeam team: TeamSection, newValue: Double) {
        if viewModel.shouldUpdateTeamALabel(section: team) {
            scoreLabelView.teamAScoreLabel.text = viewModel.formatStepperValue(newValue)
        } else if viewModel.shouldUpdateTeamBLabel(section: team) {
            scoreLabelView.teamBScoreLabel.text = viewModel.formatStepperValue(newValue)
        }
    }
}

// MARK: - UIPickerViewDataSource
extension GatherViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        viewModel.numberOfPickerComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.numberOfRowsInPickerComponent(component)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.titleForPickerRow(row, forComponent: component)
    }
}

// MARK: - GatherViewModelDelegate
extension GatherViewController: GatherViewModelDelegate {
    func didUpdateGatherTime() {
        configureSelectedTime()
    }
}

//
//  GatherView.swift
//  FootballGather
//
//  Created by Radu Dan on 26/02/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - GatherViewProtocol
protocol GatherViewProtocol: AnyObject {
    func setupView()
    func configureSelectedTime()
    func showLoadingView()
    func hideLoadingView()
    func handleError(title: String, message: String)
    func handleSuccessfulEndGather()
    func confirmEndGather()
}

// MARK: - GatherViewDelegate
protocol GatherViewDelegate: AnyObject {
    func presentAlert(title: String, message: String)
    func didEndGather()
    func presentConfirmAlertEndGather()
}

// MARK: - GatherView
final class GatherView: UIView, Loadable {
    
    // MARK: - Properties
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var scoreLabelView: ScoreLabelView!
    @IBOutlet weak var scoreStepper: ScoreStepper!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var actionTimerButton: UIButton!

    lazy var loadingView = LoadingView.initToView(self)
    
    weak var delegate: GatherViewDelegate?
    var presenter: GatherPresenterProtocol!
    
    // MARK: - Private methods
    private func hideTimerView() {
        timerView.isHidden = true
    }

    private func configureTimePickerView() {
        timePickerView.selectRow(presenter.selectedMinutes, inComponent: presenter.minutesComponent, animated: false)
        timePickerView.selectRow(presenter.selectedSeconds, inComponent: presenter.secondsComponent, animated: false)
    }
    
    private func configureActionTimerButton() {
        actionTimerButton.setTitle(presenter.formattedActionTitleText, for: .normal)
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
    
    private var selectedMinutesRow: Int { timePickerView.selectedRow(inComponent: presenter.minutesComponent) }
    private var selectedSecondsRow: Int { timePickerView.selectedRow(inComponent: presenter.secondsComponent) }
    
    // MARK: - IBActions
    @IBAction private func endGather(_ sender: Any) {
        delegate?.presentConfirmAlertEndGather()
    }

    // MARK: - Timer
    @IBAction private func setTimer(_ sender: Any) {
        configureTimePickerView()
        showTimerView()
    }

    @IBAction private func cancelTimer(_ sender: Any) {
        presenter.stopTimer()
        presenter.resetTimer()
        configureSelectedTime()
        configureActionTimerButton()
        hideTimerView()
    }

    @IBAction private func actionTimer(_ sender: Any) {
        presenter.toggleTimer()
        configureActionTimerButton()
    }

    @IBAction private func timerCancel(_ sender: Any) {
        hideTimerView()
    }

    @IBAction private func timerDone(_ sender: Any) {
        presenter.stopTimer()
        presenter.setTimerMinutes(selectedMinutesRow)
        presenter.setTimerSeconds(selectedSecondsRow)
        configureSelectedTime()
        configureActionTimerButton()
        hideTimerView()
    }
}

// MARK: - Public API
extension GatherView: GatherViewProtocol {
    func setupView() {
        configureSelectedTime()
        hideTimerView()
        configureTimePickerView()
        configureActionTimerButton()
        setupScoreStepper()
        reloadData()
    }
    
    func configureSelectedTime() {
        timerLabel?.text = presenter.formattedCountdownTimerLabelText
    }
    
    func handleError(title: String, message: String) {
        delegate?.presentAlert(title: title, message: message)
    }
    
    func handleSuccessfulEndGather() {
        delegate?.didEndGather()
    }
    
    func confirmEndGather() {
        guard let scoreTeamAString = scoreLabelView.teamAScoreLabel.text,
            let scoreTeamBString = scoreLabelView.teamBScoreLabel.text else {
                return
        }
        
        presenter.endGather(teamAScoreLabelText: scoreTeamAString, teamBScoreLabelText: scoreTeamBString)
    }
}

// MARK: - ScoreStepperDelegate
extension GatherView: ScoreStepperDelegate {
    func stepper(_ stepper: UIStepper, didChangeValueForTeam team: TeamSection, newValue: Double) {
        if presenter.shouldUpdateTeamALabel(section: team) {
            scoreLabelView.teamAScoreLabel.text = presenter.formatStepperValue(newValue)
        } else if presenter.shouldUpdateTeamBLabel(section: team) {
            scoreLabelView.teamBScoreLabel.text = presenter.formatStepperValue(newValue)
        }
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension GatherView: UITableViewDelegate, UITableViewDataSource {
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

        let rowDescription = presenter.rowDescription(at: indexPath)

        cell.textLabel?.text = rowDescription.title
        cell.detailTextLabel?.text = rowDescription.details

        return cell
    }
}

// MARK: - UIPickerViewDataSource
extension GatherView: UIPickerViewDataSource, UIPickerViewDelegate {
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

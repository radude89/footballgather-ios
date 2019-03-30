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
    
    var model: GatherModel?
    var timeHandler = GatherTimeHandler()
    var updateGatherService = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTitle()
        configureSelectedTime()
        hideTimerView()
        configureTimePickerView()
        configureActionTimerButton()
        setupScoreStepper()
        reloadData()
    }

    private func setupTitle() {
        title = "Gather in progress"
    }

    private func configureSelectedTime() {
        timerLabel?.text = formattedCountdownTimerLabelText
    }
    
    private var formattedCountdownTimerLabelText: String { "\(formattedMinutesDescription):\(formattedSecondsDescription)" }
    
    private var formattedMinutesDescription: String {
        let selectedTime = timeHandler.selectedTime
        return selectedTime.minutes < 10 ? "0\(selectedTime.minutes)" : "\(selectedTime.minutes)"
    }
    
    private var formattedSecondsDescription: String {
        let selectedTime = timeHandler.selectedTime
        return selectedTime.seconds < 10 ? "0\(selectedTime.seconds)" : "\(selectedTime.seconds)"
    }

    private func configureActionTimerButton() {
        actionTimerButton.setTitle(formattedActionTitleText, for: .normal)
    }
    
    private var formattedActionTitleText: String {
        switch timeHandler.state {
        case .paused:
            return "Resume"
            
        case .running:
            return "Pause"
            
        case .stopped:
            return "Start"
        }
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
    @IBAction func endGather(_ sender: Any) {
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
    @IBAction func setTimer(_ sender: Any) {
        configureTimePickerView()
        showTimerView()
    }

    @IBAction func cancelTimer(_ sender: Any) {
        timeHandler.stopTimer()
        timeHandler.resetSelectedTime()
        configureSelectedTime()
        configureActionTimerButton()
        hideTimerView()
    }

    @IBAction func actionTimer(_ sender: Any) {
        toggleTimer()
        configureActionTimerButton()
    }
    
    private func toggleTimer() {
        guard selectedTimeIsValid else { return }
        
        timeHandler.toggleTimer(target: self, selector: #selector(updateTimer(_:)))
    }
    
    private var selectedTimeIsValid: Bool { timeHandler.selectedTime.minutes > 0 || timeHandler.selectedTime.seconds > 0 }
    
    @objc func updateTimer(_ timer: Timer) {
        timeHandler.decrementTime()
        configureSelectedTime()
        configureActionTimerButton()
    }

    @IBAction func timerCancel(_ sender: Any) {
        hideTimerView()
    }

    @IBAction func timerDone(_ sender: Any) {
        timeHandler.stopTimer()
        setTimerMinutes(selectedMinutesRow)
        setTimerSeconds(selectedSecondsRow)
        configureSelectedTime()
        configureActionTimerButton()
        hideTimerView()
    }
    
    private func setTimerMinutes(_ minutes: Int) {
        timeHandler.selectedTime.minutes = minutes
    }
    
    private func setTimerSeconds(_ seconds: Int) {
        timeHandler.selectedTime.seconds = seconds
    }
    
    private var minutesComponent: Int { GatherTimeHandler.Component.minutes.rawValue }
    private var secondsComponent: Int { GatherTimeHandler.Component.seconds.rawValue }

    private var selectedMinutesRow: Int { timePickerView.selectedRow(inComponent: minutesComponent) }
    private var selectedSecondsRow: Int { timePickerView.selectedRow(inComponent: secondsComponent) }
    
    private var selectedMinutes: Int { timeHandler.selectedTime.minutes }
    private var selectedSeconds: Int { timeHandler.selectedTime.seconds }

    // MARK: - Private methods
    private func configureTimePickerView() {
        timePickerView.selectRow(selectedMinutes, inComponent: minutesComponent, animated: false)
        timePickerView.selectRow(selectedSeconds, inComponent: secondsComponent, animated: false)
    }

    private func endGather() {
        guard let scoreTeamAString = scoreLabelView.teamAScoreLabel.text,
            let scoreTeamBString = scoreLabelView.teamBScoreLabel.text else {
                return
        }

        showLoadingView()

        endGather(teamAScoreLabelText: scoreTeamAString, teamBScoreLabelText: scoreTeamBString) { [weak self] updated in
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
    
    private func endGather(teamAScoreLabelText: String, teamBScoreLabelText: String, completion: @escaping (Bool) -> ()) {
        let score = scoreFormattedDescription(teamAScoreLabelText: teamAScoreLabelText, teamBScoreLabelText: teamBScoreLabelText)
        let winnerTeam = winnerTeamFormattedDescription(teamAScoreLabelText: teamAScoreLabelText, teamBScoreLabelText: teamBScoreLabelText)
        let gatherCreateModel = GatherCreateModel(score: score, winnerTeam: winnerTeam)
        
        requestUpdateGather(gatherCreateModel, completion: completion)
    }
    
    private func scoreFormattedDescription(teamAScoreLabelText: String, teamBScoreLabelText: String) -> String {
        return "\(teamAScoreLabelText)-\(teamBScoreLabelText)"
    }
    
    private func winnerTeamFormattedDescription(teamAScoreLabelText: String, teamBScoreLabelText: String) -> String {
        guard let scoreTeamA = Int(teamAScoreLabelText),
            let scoreTeamB = Int(teamBScoreLabelText) else {
                return "None"
        }
        
        var winnerTeam: String = "None"
        if scoreTeamA > scoreTeamB {
            winnerTeam = "Team A"
        } else if scoreTeamA < scoreTeamB {
            winnerTeam = "Team B"
        }
        
        return winnerTeam
    }
    
    private func requestUpdateGather(_ gather: GatherCreateModel, completion: @escaping (Bool) -> Void) {
        guard let gatherUUID = model?.gatherUUID else {
            completion(false)
            return
        }
        
        updateGatherService.update(gather, resourceID: ResourceID.uuid(gatherUUID)) { result in
            if case .success(let updated) = result {
                completion(updated)
            } else {
                completion(false)
            }
        }
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

}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension GatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        TeamSection.allCases.filter { $0 != .bench }.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return TeamSection.teamA.headerTitle
        }
        
        return TeamSection.teamB.headerTitle
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let team: TeamSection = makeTeamSection(from: section)
        return playerTeams(forTeamSection: team).count
    }
    
    private func makeTeamSection(from sectionIndex: Int) -> TeamSection {
        if sectionIndex == 0 {
            return .teamA
        }
        
        return .teamB
    }
    
    private func playerTeams(forTeamSection teamSection: TeamSection) -> [PlayerTeamModel] {
        guard let model = model else { return [] }
        
        return model.players.filter { $0.team == teamSection }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatherCellId") else {
            return UITableViewCell()
        }

        let rowDescription = self.rowDescription(at: indexPath)

        cell.textLabel?.text = rowDescription.title
        cell.detailTextLabel?.text = rowDescription.details

        return cell
    }
    
    private func rowDescription(at indexPath: IndexPath) -> (title: String, details: String?) {
        let team: TeamSection = makeTeamSection(from: indexPath.section)
        let playerTeams = self.playerTeams(forTeamSection: team)
        let player = playerTeams[indexPath.row].player
        
        return (title: player.name, details: player.preferredPosition?.acronym)
    }
}

// MARK: - ScoreStepperDelegate
extension GatherViewController: ScoreStepperDelegate {
    func stepper(_ stepper: UIStepper, didChangeValueForTeam team: TeamSection, newValue: Double) {
        if shouldUpdateTeamALabel(section: team) {
            scoreLabelView.teamAScoreLabel.text = formatStepperValue(newValue)
        } else if shouldUpdateTeamBLabel(section: team) {
            scoreLabelView.teamBScoreLabel.text = formatStepperValue(newValue)
        }
    }
    
    private func formatStepperValue(_ value: Double) -> String { "\(Int(value))" }
    
    private func shouldUpdateTeamALabel(section: TeamSection) -> Bool { section == .teamA }
    
    private func shouldUpdateTeamBLabel(section: TeamSection) -> Bool { section == .teamB }
}

// MARK: - UIPickerViewDataSource
extension GatherViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        GatherTimeHandler.Component.allCases.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let _ = GatherTimeHandler.Component(rawValue: component) {
            return 60
        }
        
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let gatherCounterComponent = GatherTimeHandler.Component(rawValue: component) else {
            return nil
        }
        
        switch gatherCounterComponent {
        case .minutes:
            return "\(row) min"
        case .seconds:
            return "\(row) sec"
        }
    }
}

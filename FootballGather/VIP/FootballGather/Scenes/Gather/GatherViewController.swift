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
    @IBOutlet private weak var playerTableView: UITableView!
    @IBOutlet private weak var scoreLabelView: ScoreLabelView!
    @IBOutlet private weak var scoreStepper: ScoreStepper!
    @IBOutlet private weak var timerLabel: UILabel!
    @IBOutlet private weak var timerView: UIView!
    @IBOutlet private weak var timePickerView: UIPickerView!
    @IBOutlet private weak var actionTimerButton: UIButton!

    lazy var loadingView = LoadingView.initToView(view)
    
    var interactor: GatherInteractorProtocol!
    var router: GatherRouterProtocol = GatherRouter()
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTitle("Gather in progress")
        setTimerViewVisibility(isHidden: true)
        selectRows()
        formatTime()
        configureActionButton()
        setupScoreStepper()
        reloadData()
    }
    
    private func setTimerViewVisibility(isHidden: Bool) {
        timerView.isHidden = isHidden
    }
    
    private func configureTitle(_ title: String) {
        self.title = title
    }
    
    private func selectRows() {
        let request = Gather.SelectRows.Request()
        interactor.selectRows(request: request)
    }
    
    private func formatTime() {
        let request = Gather.FormatTime.Request()
        interactor.formatTime(request: request)
    }
    
    private func configureActionButton() {
        let request = Gather.ConfigureActionButton.Request()
        interactor.configureActionButton(request: request)
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
        let request = Gather.EndGather.Request()
        interactor.requestToEndGather(request: request)
    }

    @IBAction private func setTimer(_ sender: Any) {
        let request = Gather.SetTimer.Request()
        interactor.setTimer(request: request)
    }

    @IBAction private func cancelTimer(_ sender: Any) {
        let request = Gather.CancelTimer.Request()
        interactor.cancelTimer(request: request)
    }

    @IBAction private func actionTimer(_ sender: Any) {
        let request = Gather.ActionTimer.Request()
        interactor.actionTimer(request: request)
    }

    @IBAction private func timerCancel(_ sender: Any) {
        let request = Gather.TimerDidCancel.Request()
        interactor.timerDidCancel(request: request)
    }

    @IBAction private func timerDone(_ sender: Any) {
        guard let minutesComponent = interactor.minutesComponent?.rawValue,
            let secondsComponent = interactor.secondsComponent?.rawValue else {
                return
        }
        
        let selectedMinutes = selectedRow(in: minutesComponent)
        let selectedSeconds = selectedRow(in: secondsComponent)
        
        let request = Gather.TimerDidFinish.Request(selectedMinutes: selectedMinutes,
                                                    selectedSeconds: selectedSeconds)
        interactor.timerDidFinish(request: request)
    }
    
    private func selectedRow(in component: Int) -> Int {
        timePickerView.selectedRow(inComponent: component)
    }
    
}

// MARK: - Configuration
extension GatherViewController: GatherViewDisplayable {
    func displaySelectedRow(viewModel: Gather.SelectRows.ViewModel) {
        selectRow(viewModel.pickerRow, inComponent: viewModel.pickerComponent, animated: viewModel.animated)
    }
    
    private func selectRow(_ row: Int, inComponent component: Int, animated: Bool = false) {
        timePickerView.selectRow(row, inComponent: component, animated: animated)
    }
    
    func displayTime(viewModel: Gather.FormatTime.ViewModel) {
        timerLabel.text = viewModel.formattedTime
    }
    
    func displayActionButtonTitle(viewModel: Gather.ConfigureActionButton.ViewModel) {
        actionTimerButton.setTitle(viewModel.title, for: .normal)
    }
    
    func displayEndGatherConfirmationAlert() {
        let alertController = UIAlertController(title: "End Gather",
                                                message: "Are you sure you want to end the gather?",
                                                preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let request = Gather.EndGather.Request(winnerTeamDescription: self.winnerTeamDescription,
                                                   scoreDescription: self.scoreDescription)
            self.interactor.endGather(request: request)
        }
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private var scoreDescription: String {
        scoreLabelView.scoreDescription
    }
    
    private var winnerTeamDescription: String {
        scoreLabelView.winnerTeamDescription
    }
    
    func configureTimerViewVisibility(viewModel: Gather.SetTimer.ViewModel) {
        timerView.isHidden = !viewModel.timerViewIsVisible
    }
    
    func displayCancelTimer(viewModel: Gather.CancelTimer.ViewModel) {
        configure(timerText: viewModel.formattedTime,
                  actionTimerButtonTitle: viewModel.actionTitle,
                  timerViewIsHidden: !viewModel.timerViewIsVisible)
    }
    
    private func configure(timerText: String, actionTimerButtonTitle: String, timerViewIsHidden: Bool) {
        timerLabel.text = timerText
        actionTimerButton.setTitle(actionTimerButtonTitle, for: .normal)
        timerView.isHidden = timerViewIsHidden
    }
    
    func displayUpdatedTimer(viewModel: Gather.TimerDidFinish.ViewModel) {
        configure(timerText: viewModel.formattedTime,
                  actionTimerButtonTitle: viewModel.actionTitle,
                  timerViewIsHidden: !viewModel.timerViewIsVisible)
    }
    
    func displayTeamScore(viewModel: Gather.UpdateValue.ViewModel) {
        if let teamAText = viewModel.teamAText {
            scoreLabelView.teamAScoreLabel.text = teamAText
        } else if let teamBText = viewModel.teamBText {
            scoreLabelView.teamBScoreLabel.text = teamBText
        }
    }
}

// MARK: - GatherViewRoutable
extension GatherViewController: GatherViewRoutable {
    func popToPlayerListView() {
        router.popToPlayerListView()
    }
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension GatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let request = Gather.SectionsCount.Request()
        return interactor.numberOfSections(request: request)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let request = Gather.RowsCount.Request(section: section)
        return interactor.numberOfRowsInSection(request: request)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatherCellId") else {
            return UITableViewCell()
        }
        
        let request = Gather.RowDetails.Request(indexPath: indexPath)
        let rowViewModel = interactor.rowDetails(request: request)
        
        cell.textLabel?.text = rowViewModel.titleLabelText
        cell.detailTextLabel?.text = rowViewModel.descriptionLabelText

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let request = Gather.SectionTitle.Request(section: section)
        let viewModel = interactor.titleForHeaderInSection(request: request)
        return viewModel.title
    }
}

// MARK: - UIPickerViewDelegate | UIPickerViewDataSource
extension GatherViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        let request = Gather.PickerComponents.Request()
        return interactor.numberOfPickerComponents(request: request)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let request = Gather.PickerRows.Request(component: component)
        return interactor.numberOfRowsInPickerComponent(request: request)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let request = Gather.PickerRowTitle.Request(row: row, component: component)
        let viewModel = interactor.titleForPickerRow(request: request)
        return viewModel.title
    }
}

// MARK: - ScoreStepperDelegate
extension GatherViewController: ScoreStepperDelegate {
    func stepper(_ stepper: UIStepper, didChangeValueForTeam team: TeamSection, newValue: Double) {
        let request = Gather.UpdateValue.Request(teamSection: team, newValue: newValue)
        interactor.updateValue(request: request)
    }
}

// MARK: - Loadable
extension GatherViewController: Loadable {}

// MARK: - Error Handler
extension GatherViewController: GatherViewErrorHandler {}

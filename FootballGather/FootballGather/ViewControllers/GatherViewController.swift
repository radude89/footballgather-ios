//
//  GatherViewController.swift
//  FootballGather
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 05/07/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import UIKit

// MARK: - GatherViewController
class GatherViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var playerTableView: UITableView!
    @IBOutlet weak var scoreLabelView: ScoreLabelView!
    @IBOutlet weak var scoreStepper: ScoreStepper!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var timePickerView: UIPickerView!
    @IBOutlet weak var actionTimerButton: UIButton!
    
    lazy var loadingView = LoadingView.initToView(self.view)
    
    // MARK: - Properties
    private typealias GatherTime = (minutes: Int, seconds: Int)
    
    private enum Constants {
        static let defaultTime: GatherTime = (minutes: 10, seconds: 0)
    }
    
    fileprivate enum GatherCountDownTimerComponent: Int, CaseIterable {
        case minutes = 0, seconds
    }
    
    private enum GatherCountDownTimerState {
        case stopped, running, paused
    }
    
    private var selectedTime: GatherTime = Constants.defaultTime {
        didSet {
            timerLabel?.text = formattedCountdownTimerLabelText
        }
    }
    
    var gatherModel: GatherModel? {
        didSet {
            playerTableView?.reloadData()
        }
    }
    
    private var timer = Timer()
    private var timerState: GatherCountDownTimerState = .stopped {
        didSet {
            switch timerState {
            case .paused:
                actionTimerButton.setTitle("Resume", for: .normal)
            case .running:
                actionTimerButton.setTitle("Pause", for: .normal)
            case .stopped:
                actionTimerButton.setTitle("Start", for: .normal)
            }
        }
    }
    
    private var formattedCountdownTimerLabelText: String {
        let formattedMinutes = selectedTime.minutes < 10 ? "0\(selectedTime.minutes)" : "\(selectedTime.minutes)"
        let formattedSecs = selectedTime.seconds < 10 ? "0\(selectedTime.seconds)" : "\(selectedTime.seconds)"
        
        return "\(formattedMinutes):\(formattedSecs)"
    }
    
    // MARK: - Public methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Gather in progress"
        
        selectedTime = Constants.defaultTime
        timerView.isHidden = true
        setupTimePickerView()
        
        scoreStepper.delegate = self
        playerTableView.reloadData()
    }
    
    @IBAction func endGather(_ sender: Any) {
        guard let scoreTeamAString = scoreLabelView.teamAScoreLabel.text,
            let scoreTeamBString = scoreLabelView.teamBScoreLabel.text,
            let scoreTeamA = Int(scoreTeamAString),
            let scoreTeamB = Int(scoreTeamBString) else {
                return
        }
        
        let score = "\(scoreTeamA)-\(scoreTeamB)"
        
        var winnerTeam: String = "None"
        if scoreTeamA > scoreTeamB {
            winnerTeam = "Team A"
        } else if scoreTeamA < scoreTeamB {
            winnerTeam = "Team B"
        }
        
        let gather = GatherCreateModel(score: score, winnerTeam: winnerTeam)
        
        showLoadingView()
        updateGather(gather) { [weak self] gatherWasUpdated in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.hideLoadingView()
            }
            
            if !gatherWasUpdated {
                DispatchQueue.main.async {
                    AlertHelper.present(in: self, title: "Error update", message: "Unable to update gather. Please try again.")
                }
            }
        }
    }
    
    // MARK: - Timer
    @IBAction func setTimer(_ sender: Any) {
        setupTimePickerView()
        timerView.isHidden = false
    }
    
    @IBAction func cancelTimer(_ sender: Any) {
        timerState = .stopped
        timer.invalidate()
        selectedTime = Constants.defaultTime
        timerView.isHidden = true
    }
    
    @IBAction func actionTimer(_ sender: Any) {
        switch timerState {
        case .stopped, .paused:
            timerState = .running
        case .running:
            timerState = .paused
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @IBAction func timerCancel(_ sender: Any) {
        timerView.isHidden = true
    }
    
    @IBAction func timerDone(_ sender: Any) {
        selectedTime.minutes = timePickerView.selectedRow(inComponent: GatherCountDownTimerComponent.minutes.rawValue)
        selectedTime.seconds = timePickerView.selectedRow(inComponent: GatherCountDownTimerComponent.seconds.rawValue)
        
        timerView.isHidden = true
    }
    
    @objc
    func updateTimer(_ timer: Timer) {
        if selectedTime.seconds == 0 {
            selectedTime.minutes -= 1
            selectedTime.seconds = 59
        } else {
            selectedTime.seconds -= 1
        }
        
        if selectedTime.seconds == 0 && selectedTime.minutes == 0 {
            timer.invalidate()
        }
    }
    
    // MARK: - Private methods
    private func updateGather(_ gather: GatherCreateModel, completion: @escaping (Bool) -> Void) {
        guard let gatherModel = gatherModel else {
            completion(false)
            return
        }
        
        var service = StandardNetworkService(resourcePath: "/api/gathers", authenticated: true)
        service.update(gather, resourceID: ResourceID.uuid(gatherModel.gatherUUID)) { result in
            if case .success(let updated) = result {
                completion(updated)
            } else {
                completion(false)
            }
        }
    }
    
    private func setupTimePickerView() {
        timePickerView.selectRow(selectedTime.minutes, inComponent: GatherCountDownTimerComponent.minutes.rawValue, animated: false)
        timePickerView.selectRow(selectedTime.seconds, inComponent: GatherCountDownTimerComponent.seconds.rawValue, animated: false)
    }
    
}

// MARK: - UITableViewDelegate | UITableViewDataSource
extension GatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gatherModel?.players.filter { $0.team == Team(rawValue: section) }.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GatherCellId") else {
            return UITableViewCell()
        }
        
        if let playerTeams = gatherModel?.players.filter({ $0.team == Team(rawValue: indexPath.section) }) {
            let player = playerTeams[indexPath.row].player
            
            cell.textLabel?.text = player.name
            cell.detailTextLabel?.text = player.preferredPosition?.acronym
        }
        
        return cell
    }
}

// MARK: - ScoreStepperDelegate
extension GatherViewController: ScoreStepperDelegate {
    func stepper(_ stepper: UIStepper, didChangeValueForTeam team: Team, newValue: Double) {
        switch team {
        case .teamA:
            scoreLabelView.teamAScoreLabel.text = "\(Int(newValue))"
        case .teamB:
            scoreLabelView.teamBScoreLabel.text = "\(Int(newValue))"
        default: break
        }
    }
}

// MARK: - Loadable conformance
extension GatherViewController: Loadable {}

// MARK: - UIPickerViewDataSource
extension GatherViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return GatherCountDownTimerComponent.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let gatherCounterComponent = GatherCountDownTimerComponent(rawValue: component) else {
            return 0
        }
        
        switch gatherCounterComponent {
        case .minutes, .seconds:
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let gatherCounterComponent = GatherCountDownTimerComponent(rawValue: component) else {
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

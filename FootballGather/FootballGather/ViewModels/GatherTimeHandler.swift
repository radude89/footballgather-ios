//
//  GatherTimeHandler.swift
//  FootballGather
//
//  Created by Radu Dan on 27/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

// MARK: - GatherTimeHandler
struct GatherTimeHandler {
    var timer: Timer
    var selectedTime: GatherTime
    var state: State
    
    init(timer: Timer = Timer(), selectedTime: GatherTime = .defaultTime, state: State = .stopped) {
        self.timer = timer
        self.selectedTime = selectedTime
        self.state = state
    }
    
    mutating func stopTimer() {
        timer.invalidate()
        state = .stopped
    }
    
    mutating func resetSelectedTime() {
        selectedTime = .defaultTime
    }
    
    mutating func toggleTimer(target: AnyObject, selector: Selector) {
        toggleTimerState()
        
        if state == .paused {
            timer.invalidate()
        } else {
            startTimer(target: target, selector: selector)
        }
    }
    
    private mutating func toggleTimerState() {
        switch state {
        case .stopped, .paused:
            state = .running
        case .running:
            state = .paused
        }
    }
    
    private let timeIntervalUpdatesInSeconds: TimeInterval = 1
    
    private mutating func startTimer(target: AnyObject, selector: Selector) {
        timer = Timer.scheduledTimer(timeInterval: timeIntervalUpdatesInSeconds, target: target, selector: selector, userInfo: nil, repeats: true)
    }
    
    mutating func decrementTime() {
        if selectedTime.seconds == 0 {
            decrementMinutes()
        } else {
            decrementSeconds()
        }
        
        if selectedTimeIsZero {
            stopTimer()
        }
    }
    
    private mutating func decrementMinutes() {
        selectedTime.minutes -= 1
        selectedTime.seconds = 59
    }
    
    private mutating func decrementSeconds() {
        selectedTime.seconds -= 1
    }
    
    private var selectedTimeIsZero: Bool {
        return selectedTime.seconds == 0 && selectedTime.minutes == 0
    }
}

extension GatherTimeHandler {
    enum State {
        case stopped, running, paused
    }
    
    enum Component: Int, CaseIterable {
        case minutes = 0, seconds
    }
}

// MARK: - GatherTime
struct GatherTime {
    var minutes: Int
    var seconds: Int
    
    static let defaultTime = GatherTime(minutes: 10, seconds: 0)
}

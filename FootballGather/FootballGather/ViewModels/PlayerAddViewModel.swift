//
//  PlayerAddViewModel.swift
//  FootballGather
//
//  Created by Radu Dan on 23/01/2020.
//  Copyright © 2020 Radu Dan. All rights reserved.
//

import Foundation

final class PlayerAddViewModel {
    
    private let service: StandardNetworkService
    
    init(service: StandardNetworkService = StandardNetworkService(resourcePath: "/api/players", authenticated: true)) {
        self.service = service
    }
    
    var title: String {
        return "Add Player"
    }
    
    func requestCreatePlayer(name: String, completion: @escaping (Bool) -> Void) {
        let player = PlayerCreateModel(name: name)
        service.create(player) { result in
            if case .success(_) = result {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func doneButtonIsEnabled(forText text: String?) -> Bool {
        return text?.isEmpty == false
    }
}

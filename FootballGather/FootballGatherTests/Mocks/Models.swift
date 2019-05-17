//
//  Models.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 17/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//

import Foundation
@testable import FootballGather

enum ModelsMockFactory {
    static func makeUser(withUsername username: String = "demo-user", password: String = "demo-password") -> RequestUserModel {
        return RequestUserModel(username: username, password: password)
    }
}

enum ModelsMock {
    static let userUUID = UUID(uuidString: "939C0E30-7C25-436D-9AC6-571C2E339AB7")!
    static let token = "v2s4o0XcRgDHF/VojbAmGQ=="
}

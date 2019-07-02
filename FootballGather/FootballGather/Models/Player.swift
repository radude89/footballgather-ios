//
//  Player.swift
//  FootballGatherTests
//
//  Created by Dan, Radu-Ionut (RO - Bucharest) on 13/05/2019.
//  Copyright © 2019 Radu Dan. All rights reserved.
//
//

import Foundation
import CoreData

// MARK: - Player
final class Player: NSManagedObject {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }
    
    @NSManaged var age: Int32
    @NSManaged var favouriteTeam: String?
    @NSManaged var name: String
    @NSManaged var preferredPosition: String?
    @NSManaged var serverId: Int32
    @NSManaged var skill: String?
    @NSManaged var gathers: NSSet?
    @NSManaged var user: User?
}

// MARK: - Generated accessors for gathers
extension Player {
    @objc(addGathersObject:)
    @NSManaged func addToGathers(_ value: Gather)
    
    @objc(removeGathersObject:)
    @NSManaged func removeFromGathers(_ value: Gather)
    
    @objc(addGathers:)
    @NSManaged func addToGathers(_ values: NSSet)
    
    @objc(removeGathers:)
    @NSManaged func removeFromGathers(_ values: NSSet)
}

// MARK: - Skill & Position enum wrappers
extension Player {
    enum Skill: String, Codable, CaseIterable {
        case beginner, amateur, professional
    }
    
    enum Position: String, Codable, CaseIterable {
        case goalkeeper, defender, midfielder, winger, striker
        
        var acronym: String {
            switch self {
            case .goalkeeper: return "GK"
            case .winger: return "W"
            case .striker: return "ST"
            default: return rawValue.prefix(3).uppercased()   
            }
        }
    }
    
    var skillOption: Skill? {
        set {
            skill = newValue?.rawValue
        }
        get {
            if let skill = skill {
                return Skill(rawValue: skill)
            } else {
                return nil
            }
        }
    }
    
    var positionOption: Position? {
        set {
            preferredPosition = newValue?.rawValue
        }
        get {
            if let preferredPosition = preferredPosition {
                return Position(rawValue: preferredPosition)
            } else {
                return nil
            }
        }
    }
}

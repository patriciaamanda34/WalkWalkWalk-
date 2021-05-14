//
//  User+CoreDataProperties.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/14/21.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var userDailySteps: Int16
    @NSManaged public var userDateOfBirth: Date?
    @NSManaged public var userName: String?
    @NSManaged public var userDailyStepsQuota: Int16
    @NSManaged public var routes: Route?
    @NSManaged public var userStats: NSSet?

}

// MARK: Generated accessors for userStats
extension User {

    @objc(addUserStatsObject:)
    @NSManaged public func addToUserStats(_ value: WalkStats)

    @objc(removeUserStatsObject:)
    @NSManaged public func removeFromUserStats(_ value: WalkStats)

    @objc(addUserStats:)
    @NSManaged public func addToUserStats(_ values: NSSet)

    @objc(removeUserStats:)
    @NSManaged public func removeFromUserStats(_ values: NSSet)

}

extension User : Identifiable {

}

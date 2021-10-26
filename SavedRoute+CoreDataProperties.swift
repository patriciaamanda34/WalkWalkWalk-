//
//  SavedRoute+CoreDataProperties.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 6/9/21.
//
//

import Foundation
import CoreData


extension SavedRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedRoute> {
        return NSFetchRequest<SavedRoute>(entityName: "SavedRoute")
    }

    @NSManaged public var savedRouteName: String?
    @NSManaged public var points: NSSet?
    @NSManaged public var routeStats: Route?
    @NSManaged public var savedByUser: User?
    @NSManaged public var savedRouteStats: WalkStats?

}

// MARK: Generated accessors for points
extension SavedRoute {

    @objc(addPointsObject:)
    @NSManaged public func addToPoints(_ value: Coordinate)

    @objc(removePointsObject:)
    @NSManaged public func removeFromPoints(_ value: Coordinate)

    @objc(addPoints:)
    @NSManaged public func addToPoints(_ values: NSSet)

    @objc(removePoints:)
    @NSManaged public func removeFromPoints(_ values: NSSet)

}

extension SavedRoute : Identifiable {

}

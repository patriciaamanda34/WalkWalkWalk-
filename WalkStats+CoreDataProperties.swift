//
//  WalkStats+CoreDataProperties.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/14/21.
//
//

import Foundation
import CoreData


extension WalkStats {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WalkStats> {
        return NSFetchRequest<WalkStats>(entityName: "WalkStats")
    }

    @NSManaged public var walkDate: Date?
    @NSManaged public var walkDistance: Float
    @NSManaged public var walkNoOfSteps: Int32
    @NSManaged public var walkTime: Int32
    @NSManaged public var routes: Route?
    @NSManaged public var savedRoute: SavedRoute?

}

extension WalkStats : Identifiable {

}

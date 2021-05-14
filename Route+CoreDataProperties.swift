//
//  Route+CoreDataProperties.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/14/21.
//
//

import Foundation
import CoreData


extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var routeFinishLatitude: Double
    @NSManaged public var routeFinishLongitude: Double
    @NSManaged public var routeLoopsBack: Bool
    @NSManaged public var routeName: String?
    @NSManaged public var routeStartLatitude: Double
    @NSManaged public var routeStartLongitude: Double
    @NSManaged public var user: User?

}

extension Route : Identifiable {

}

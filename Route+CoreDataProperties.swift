//
//  Route+CoreDataProperties.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 6/9/21.
//
//

import Foundation
import CoreData


extension Route {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Route> {
        return NSFetchRequest<Route>(entityName: "Route")
    }

    @NSManaged public var routeName: String?
    @NSManaged public var routeEndCoordinate: Coordinate?
    @NSManaged public var routeStartCoordinate: Coordinate?
    @NSManaged public var user: User?

}

extension Route : Identifiable {

}

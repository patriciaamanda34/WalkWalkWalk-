//
//  SavedRoute+CoreDataProperties.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/14/21.
//
//

import Foundation
import CoreData


extension SavedRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SavedRoute> {
        return NSFetchRequest<SavedRoute>(entityName: "SavedRoute")
    }

    @NSManaged public var savedRouteName: String?
    @NSManaged public var routeStats: Route?
    @NSManaged public var savedRouteStats: WalkStats?

}

extension SavedRoute : Identifiable {

}

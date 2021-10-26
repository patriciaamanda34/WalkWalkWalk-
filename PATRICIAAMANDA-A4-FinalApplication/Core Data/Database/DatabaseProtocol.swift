//
//  DatabaseProtocol.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//
import Foundation
import CoreLocation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case routes
    case user
    case savedRoute
    case walkStats
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType : ListenerType {get set}
    func onRouteChange(change: DatabaseChange, routes: [Route])
    func onWalkStatsChange(change: DatabaseChange, walkStats: [WalkStats])
    func onSavedRouteChange(change: DatabaseChange, savedRoutes: [SavedRoute])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func fetchUser()->User?
    
    func addUser(name: String, dateOfBirth: Date)
    
    func fetchMyRoutes()->[Route]
    func fetchSavedRoutes()->[SavedRoute]
    
    func fetchAllCoordinatesInSavedRoute(savedRoute: SavedRoute)->[CLLocationCoordinate2D]
    func fetchWalkStatsInUser(user: User)->[WalkStats]
    
    func setPointsToSavedRoute(savedRoute : SavedRoute, points: [CLLocationCoordinate2D])
    
    func createSavedRoute()->SavedRoute
    func createWalkStats()->WalkStats
    
    func createRouteInChild()->Route?
    func createCoordinateInChild()->Coordinate
    func createWalkStatsInChild()->WalkStats
    func createSavedRouteInChild()->SavedRoute
    
    func getCopyOfRoute(route : Route)->Route
    
    func removeRoute(route: Route)
    func removeSavedRoute(savedRoute: SavedRoute)
}


//
//  DatabaseProtocol.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//
import Foundation

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
    //func addRoute(name: String, startLat: double, startLong: double, endLat: double, endLong: double)
    
    func createRouteInChild()->Route
    func fetchRouteInChild()->Route?
}


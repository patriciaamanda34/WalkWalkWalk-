//
//  CoreDataController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
//MARK: - Variables
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer

    let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    var savedRoutesFetchedResultsController: NSFetchedResultsController<SavedRoute>?

    var routesFetchedResultsController:NSFetchedResultsController<Route>?
    
    
//MARK: - Methods
    
    override init() {
        persistentContainer = NSPersistentContainer(name: "A4-DataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
        if let error = error {
        fatalError("Failed to load Core Data Stack with error: \(error)")
            }
        }
        super.init()
    }
    
    
    func cleanup() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    
    func addListener(listener: DatabaseListener){
        listeners.addDelegate(listener)
        
        if listener.listenerType == .savedRoute {
            listener.onSavedRouteChange(change: .update, savedRoutes: fetchSavedRoutes())
        }
        
        else if listener.listenerType == .routes {
            listener.onRouteChange(change: .update, routes: fetchMyRoutes())
        }
    }
    
    
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    
    
    //Fetches the User of the application
    func fetchUser()->User? {
        let context = persistentContainer.viewContext
        let user: User? = nil
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        var users = [User]()
        do {
            try users = context.fetch(request)
        } catch {
            print("Fetch Request failed: \(error)")
        }
        
        if let firstUser = users.first {
            return firstUser //Grab the first user
        }
        return user
    }
    
    
    //Fetches all the Routes
    func fetchMyRoutes()->[Route] {
        let context = persistentContainer.viewContext
        
        let fetchRequest : NSFetchRequest<Route> = Route.fetchRequest()
        
        //Sort it alphabetically based on name
        let nameSortDescriptor = NSSortDescriptor(key: "routeName", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        routesFetchedResultsController = NSFetchedResultsController<Route>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        routesFetchedResultsController?.delegate = self

        do {
            try routesFetchedResultsController?.performFetch()
        } catch {
            print("Fetch Request failed: \(error)")
        }
        if let routes = routesFetchedResultsController?.fetchedObjects {
            return routes
        }
        return [Route]()
    }
    
    
    //Fetches all the Saved Routes
    func fetchSavedRoutes()->[SavedRoute] {
        let context = persistentContainer.viewContext
        
        let fetchRequest : NSFetchRequest<SavedRoute> = SavedRoute.fetchRequest()
        
        //Sort it alphabetically based on name
        let nameSortDescriptor = NSSortDescriptor(key: "savedRouteName", ascending: true)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        savedRoutesFetchedResultsController = NSFetchedResultsController<SavedRoute>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        savedRoutesFetchedResultsController?.delegate = self

        do {
            try savedRoutesFetchedResultsController?.performFetch()
            } catch {
            print("Fetch Request failed: \(error)")
            }
        
        if let savedRoutes = savedRoutesFetchedResultsController?.fetchedObjects {
            return savedRoutes
        }
        return [SavedRoute]()
    }
    
    
    //Creates a new User
    func addUser(name: String, dateOfBirth: Date)
    {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: persistentContainer.viewContext) as! User
        user.userName = name
        user.userDateOfBirth = dateOfBirth
        //Creates the first Walk Stat
        user.addToUserStats(createWalkStats())
    }
    
   
    //Creates a SavedRoute object
    //sets its name to name
    func createSavedRoute(_ name: String)->SavedRoute {
        let savedRoute = NSEntityDescription.insertNewObject(forEntityName: "SavedRoute", into: persistentContainer.viewContext) as! SavedRoute
        
        savedRoute.savedRouteName = name
    
        return savedRoute
    }
    
    
    //Creates a route in child context. used for the "Add a New Route" page.
    //Should save to main context if change is meant to be persisted.
    func createRouteInChild()->Route? {
       
       // let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = self.persistentContainer.viewContext

        let route = NSEntityDescription.insertNewObject(forEntityName: "Route", into: childContext) as! Route
        route.user = getCopyOfUser(user: fetchUser()!)
        return route
    }
    
    
    //Creates a new SavedRoute object with no parameters
    func createSavedRoute()->SavedRoute {
        let savedRoute = NSEntityDescription.insertNewObject(forEntityName: "SavedRoute", into: persistentContainer.viewContext) as! SavedRoute
        
        return savedRoute
    }
    
    
    //Creates a new WalkStats object
    func createWalkStats()->WalkStats {
        let walkStats = NSEntityDescription.insertNewObject(forEntityName: "WalkStats", into: persistentContainer.viewContext) as! WalkStats
        
        walkStats.walkDateStart = Date()
        return walkStats
    }
    
    
    //Sets points to Coordinates in SavedRoute
    func setPointsToSavedRoute(savedRoute : SavedRoute, points: [CLLocationCoordinate2D]) {
        if points.count > 0 {
            //Iterates through points.
            for p in 0...points.count-1 {
                let temp = createCoordinate()
                temp.latitude = points[p].latitude
                temp.longitude = points[p].longitude
                temp.index = Int16(p)
                savedRoute.addToPoints(temp) //Adds to SavedRoute
            }
        }
    }
    
    
    //Fetches all Coordinate objects in SavedRoute then changes it to [CLLocationCoordinate2D].
    func fetchAllCoordinatesInSavedRoute(savedRoute: SavedRoute)->[CLLocationCoordinate2D] {
        var returnValue : [CLLocationCoordinate2D] = []
        
        let tempCoords = savedRoute.points
        
        //Sort based on index
        let coords = tempCoords?.sortedArray(using: [NSSortDescriptor(key: "index", ascending: true)])
        
        if let coords = coords as? [Coordinate] {
            for c in coords {
                returnValue.append(CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude))
            }
        }
        return returnValue
    }
    
    
    //Removes the Route object from main context.
    func removeRoute(route: Route) {
        persistentContainer.viewContext.delete(route)
        removeSavedRouteOfRoute(route: route)
    }
    
    
    //Removes SavedRoutes of a certain Route from main context.
    func removeSavedRouteOfRoute(route: Route) {
        let allSavedRoutes = fetchSavedRoutes()
        for a in allSavedRoutes {
            if a.routeStats == route {
                removeSavedRoute(savedRoute: a)
            }
        }
    }
    
    
    //Removes SavedRoute from main context.
    func removeSavedRoute(savedRoute: SavedRoute) {
        persistentContainer.viewContext.delete(savedRoute)
    }
    
    
    //Fetches all the WalkStats from a User
    func fetchWalkStatsInUser(user: User)->[WalkStats] {
        let walkStats = user.userStats
        walkStats?.sortedArray(using: [NSSortDescriptor(key: "walkDateStart", ascending: true)])
        return walkStats?.allObjects as! [WalkStats]
    }
    
    
    //Creates a Coordinate Object in main context.
    func createCoordinate()->Coordinate {
        let coor = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: persistentContainer.viewContext) as! Coordinate
        
        return coor
    }
    
    
    //Creates a Coordinate object in the Child Context.
    func createCoordinateInChild()->Coordinate {
         childContext.parent = self.persistentContainer.viewContext

        let coor = NSEntityDescription.insertNewObject(forEntityName: "Coordinate", into: childContext) as! Coordinate
        
        return coor
    }
    
    
    //Creates SavedRoute in child context.
    func createSavedRouteInChild()->SavedRoute {
        childContext.parent = self.persistentContainer.viewContext

       let s = NSEntityDescription.insertNewObject(forEntityName: "SavedRoute", into: childContext) as! SavedRoute
       s.savedByUser = getCopyOfUser(user: fetchUser()!)
       return s
    }
    
    
    //Creates WalkStats in Child context.
    func createWalkStatsInChild()->WalkStats {
        childContext.parent = self.persistentContainer.viewContext

       let w = NSEntityDescription.insertNewObject(forEntityName: "WalkStats", into: childContext) as! WalkStats
        
       return w
    }
    
    
    //Gets a copy of Route in the child context.
    func getCopyOfRoute(route : Route)->Route {
        childContext.parent = self.persistentContainer.viewContext

        return childContext.object(with: route.objectID) as! Route
    }
    
    
    //Gets the copy of User in the child context.
    func getCopyOfUser(user: User)->User {
        childContext.parent = self.persistentContainer.viewContext
        return childContext.object(with: user.objectID) as! User
    }
    
    
    // MARK: - Fetched Results Controller Protocol methods

    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {

        if controller == routesFetchedResultsController {
            listeners.invoke() { listener in
                if listener.listenerType == .routes {

                    listener.onRouteChange(change: .update, routes: fetchMyRoutes())
                }
            }
        }
        else if controller == savedRoutesFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == .savedRoute  {
                    listener.onSavedRouteChange(change: .update, savedRoutes: fetchSavedRoutes())
                }
            }
        }
    }
}


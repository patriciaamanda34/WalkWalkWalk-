//
//  CoreDataController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistentContainer: NSPersistentContainer

    var savedRoutesFetchedResultsController: NSFetchedResultsController<SavedRoute>?

    
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
            if(fetchSavedRoutes().count == 0){
                createDefaultSavedRoutes()
            }
        }
        
        else if listener.listenerType == .user {
            //listener.onUserChange(change: .update, user: User)
        }
    }
    func removeListener(listener: DatabaseListener){
        listeners.removeDelegate(listener)
    }
    
    
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
            return firstUser
        }
       
            //user = NSEntityDescription.insertNewObject(forEntityName: "User", into: context) as! User
        //return nil
       // user.userName = "Default User"
       // user.userDateOfBirth = "01-01-2000"
            //return user
        
        return user
    }
    
    
    func fetchSavedRoutes()->[SavedRoute] {
        let context = persistentContainer.viewContext
        
        let fetchRequest : NSFetchRequest<SavedRoute> = SavedRoute.fetchRequest()
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
    
    func addUser(name: String, dateOfBirth: Date)
    {
        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: persistentContainer.viewContext) as! User
        user.userName = name
        user.userDateOfBirth = dateOfBirth
    }
    
    func createDefaultSavedRoutes(){
        let savedRoute = NSEntityDescription.insertNewObject(forEntityName: "SavedRoute", into: persistentContainer.viewContext) as! SavedRoute
        
        savedRoute.savedRouteName = "Test"
        cleanup()
    }
    
    //Creates a route in child context. used for the "Add a New Route" page.
    //Should save to main context if change is meant to be persisted.
    func createRouteInChild()->Route {
       
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = self.persistentContainer.viewContext

        let route = NSEntityDescription.insertNewObject(forEntityName: "Route", into: childContext) as! Route
        
        return route

    }
    
    func fetchRouteInChild()->Route? {
        var routes = [Route]()
        var route : Route?
        
        let childContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childContext.parent = self.persistentContainer.viewContext

        let request: NSFetchRequest<Route> = Route.fetchRequest()
        do {
            try routes = childContext.fetch(request)
        } catch {
            print("Fetch Request failed: \(error)")
        }
        if route == nil {
            route = createRouteInChild()
        }
        else{
            if let firstRoute = routes.first {
                return firstRoute
            }
            
        }
        
        return route
        
        
    }
}

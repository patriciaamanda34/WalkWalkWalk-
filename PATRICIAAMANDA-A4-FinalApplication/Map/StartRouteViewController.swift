//
//  StartRouteViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/21/21.
//

import UIKit
import MapKit
import CoreLocation
import CoreMotion
class StartRouteViewController: UIViewController, SwitchViewDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
//MARK: - Variables
    
    var savedRoute : SavedRoute?
    
    var routeLength : Double?
    
    weak var switchViewDelegate : SwitchViewDelegate?
        
    var currentLocation: CLLocation?
    
    let locationManager = CLLocationManager()
   
   //Polylines
    var totalRoutePolyline: MKPolyline?
    var currentRoutePolyline: MKPolyline?
    
    var points : [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()

    //Outlets
    @IBOutlet weak var routeMapView: MKMapView!

    @IBOutlet weak var firstView: UIView!

    @IBOutlet weak var secondView: UIView!
    
    var route: Route?
    
    var hasTimerStarted : Bool = false //Marks if the timer has started or not.
    
    
//MARK: - View Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Loads the first view first.
        view.bringSubviewToFront(firstView)
        
        //Sets labels and variables
        navigationItem.title = route?.routeName
        
        if let start = route?.routeStartCoordinate, let finish = route?.routeEndCoordinate  {
            showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D(latitude: start.latitude ,longitude: start.longitude), destinationCoordinate: CLLocationCoordinate2D(latitude: finish.latitude, longitude: finish.longitude))
        }
        
        //Sets delegates
        routeMapView.delegate = self
        locationManager.delegate = self

        //Sets user tracking functionalities (location manager)
        //Set to very accurate due to the nature of it being a fitness app.
        locationManager.desiredAccuracy =  kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 10
        currentLocation = locationManager.location!
        routeMapView.showsUserLocation = true

        //So that it asks for permission before the user starts the timer
        CMPedometer().stopUpdates()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
    
    
//MARK: - Location Related Methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
           
            var region = MKCoordinateRegion()
            region.center = currentLocation!.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.001), longitudeDelta: CLLocationDegrees(0.001))
            routeMapView.setRegion(region, animated: true)
        
            if(hasTimerStarted == true){
                points.append(currentLocation!.coordinate)
            
                currentRoutePolyline = MKPolyline(coordinates: points, count: points.count)
            
                routeMapView.addOverlay(currentRoutePolyline!)
                
            }
        }
    }
    
    
// MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "FirstViewSegue" {
            let destination = segue.destination as! FirstStartRouteViewController
            destination.route = route
            destination.switchViewDelegate = self
        }
        else if segue.identifier == "SecondViewSegue" {
            
            let destination = segue.destination as! SecondStartRouteViewController
            destination.route = route

            destination.switchViewDelegate = self
            switchViewDelegate = destination
            destination.routeLength = routeLength
        }
        else if segue.identifier == "FinishSessionSegue" {
            let destination = segue.destination as! SavedRouteDetailViewController
            destination.savedRoute = savedRoute
        }
    }
    
    
   //Shows the route on the map given 2 coordinates.
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .walking //The user will walk. This is to count the ETA.

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }
                
                //for getting just one route
                if let route = unwrappedResponse.routes.first {
                    //show on map
                    totalRoutePolyline = route.polyline
                    self.routeMapView.addOverlay(totalRoutePolyline!)
                    
                    routeLength = (route.distance/1000) // in kilometres
                }
            }
        }
    
    
//MARK: - Actions
    @IBAction func onCancel(_ sender: Any) {
        if (hasTimerStarted == true) {
        //Sends out a warning first if the timer has started, since progress will be lost if user goes back.
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to leave? This page will not be saved.", preferredStyle: .alert)
        
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: back))
                                  
            present(alertController, animated: true, completion: nil)
        }
        else{
            //However, if the timer hasn't started, just go back as normal.
            back(action: UIAlertAction())
        }
    }
    
    
    func back(action : UIAlertAction){
        //Pops the view
        navigationController?.popViewController(animated: true)
        return
    }
    
    
//MARK: - SwitchViewDelegate Methods
    //When the timer is paused, set the boolean accordingly.
    func pauseTimer(sender: Any?) {
        if let sender = sender as? SecondStartRouteViewController {
            if sender.isPaused == true {
                hasTimerStarted = false
            }
            else {
                hasTimerStarted = true
            }
        }
    }
    
    
    func startTimer(sender: Any?) -> Bool {
        //Start timer
        return true
    }
    
    
    func stopTimer(sender: Any?) -> Bool {
        if let sender = sender as? SecondStartRouteViewController {
            
            hasTimerStarted = false
            
            //Create a new SavedRoute object and save values in it.
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let databaseController = appDelegate?.databaseController
            savedRoute = databaseController?.createSavedRouteInChild()
            
            //Convert route to Child Context so that it doesn't collide with it being in two different contexts.
            savedRoute?.routeStats = databaseController?.getCopyOfRoute(route : route!)
            
            let walkStats = databaseController?.createWalkStatsInChild()
            savedRoute?.savedRouteStats = walkStats
            
            walkStats?.walkTime = Int32(sender.count)
            walkStats?.walkDistance = Float(sender.distance)
            walkStats?.walkNoOfSteps = Int32(sender.numberOfSteps)
            
            walkStats?.walkDateStart = sender.walkStart
            walkStats?.walkDateEnd = Date()
            
            let user = savedRoute?.savedByUser
            let userStats = user?.userStats?.allObjects.last as? WalkStats
            
            userStats?.walkNoOfSteps += Int32(sender.numberOfSteps)
            userStats?.walkDistance += Float(sender.distance)
            userStats?.walkTime += Int32(sender.count)
            
            databaseController?.setPointsToSavedRoute(savedRoute: savedRoute!, points: points)
         
            performSegue(withIdentifier: "FinishSessionSegue", sender: sender)
            return true
        }
        return false
    }
    
    
    //This is called when the view container switches from FirstStartRouteViewController to this one.
    func switchView(sender: Any?) -> Bool {
        if (sender as? FirstStartRouteViewController) != nil {
            view.bringSubviewToFront(secondView)
            if((switchViewDelegate?.startTimer(sender: self)) == true) {
                hasTimerStarted = true //Timer stats immediately when starting.
                return true
            }
        }
        return false
    }
    
    
//MARK: - MapView Delegate Methods
    //this delegate function is for displaying the route overlay and styling it
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Drawing 2 polylines in MapKit:
        //https://stackoverflow.com/questions/28045266/how-to-draw-two-polylines-in-different-colors-in-mapkit?rq=1
        var renderer = MKPolylineRenderer()
        if overlay is MKPolyline {
            if overlay as? MKPolyline == totalRoutePolyline {
                renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5.0
            }
            else if overlay as? MKPolyline == currentRoutePolyline {
                renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = UIColor.green
                renderer.lineWidth = 3.0
            }
        }
        return renderer
    }
}

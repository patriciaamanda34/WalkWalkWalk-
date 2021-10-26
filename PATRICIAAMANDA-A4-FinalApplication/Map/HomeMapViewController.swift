//
//  HomeMapViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/22/21.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications
import CoreMotion

class HomeMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    //MARK: - Variables
    
    //Bool value to see if the map has been centered to user location or not
    var centered: Bool = false
    
    weak var databaseController : DatabaseProtocol?
    
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    var notifications = false
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Setting up delegates
        locationManager.delegate = self
        mapView.delegate = self
        
        //Cheking authorizationStatus to display user's location.
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if locationManager.authorizationStatus  == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            //We want this to be very accurate since it's a fitness app.
            //Trade off: Battery life
            locationManager.desiredAccuracy =  kCLLocationAccuracyNearestTenMeters
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = .fitness
            locationManager.distanceFilter = 10

            currentLocation = locationManager.location
        }
        
        //Setting up local notifications to fire at 9 AM each day.
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { granted, error in
            self.notifications = granted
            
            if !granted {
             print("Permission was not granted!")
             return
             }
        }
        
        //Setting notification content:
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "It's a brand new day!"
        notificationContent.body = "Ready for another walk?"
        notificationContent.sound = .default
            
        //Setting the time:
        var datComp = DateComponents()
        datComp.hour = 9
        datComp.minute = 0
        
        //Adding the request
        let trigger = UNCalendarNotificationTrigger(dateMatching: datComp, repeats: true)
        let request = UNNotificationRequest(identifier: "ID", content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error : Error?) in
            if let error = error {
                print(error.localizedDescription)
                }
            }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        //Setting up initial values
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //Starts updating location
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Location Manager Functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            //Only updates when centered is false - runs only once.
            if (centered == false) {
                //Sets center to the current user's location and sets the region accordingly.
                var region = MKCoordinateRegion()
                region.center = currentLocation!.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
                mapView.setRegion(region, animated: true)
        
                centered = true
                mapView.showsUserLocation = true
            }
        }
    }
    
    
    //Runs if the authorization changes.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if locationManager.authorizationStatus  == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            mapView.showsUserLocation = true
            locationManager.desiredAccuracy =  kCLLocationAccuracyBest
            
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = .fitness
            locationManager.distanceFilter = 1
        }
        else if locationManager.authorizationStatus == .denied {
            //Sends a warning if the location authorization status is denied.
            mapView.showsUserLocation = false
            
            displayMessage(title: "Location Services is Required for this Application.", message: "This application requires location services to be activated; to track the user's progress during walking sessions.")
        }
    }
    
    
    //MARK: - Actions
    //Called when the segmentedControl changes; changing to different mapTypes.
    @IBAction func mapTypeSegmentControlChanged(_ segmentedControl: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }

    
    //MARK: - Display Message
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: locationManager.requestAlwaysAuthorization)
    }
}

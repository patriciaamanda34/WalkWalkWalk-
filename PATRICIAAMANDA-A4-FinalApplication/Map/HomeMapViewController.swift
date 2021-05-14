//
//  HomeMapViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/22/21.
//

import UIKit
import MapKit
import CoreLocation

class HomeMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var centered: Bool = false
    weak var databaseController : DatabaseProtocol?
    @IBOutlet weak var mapView: MKMapView!
    
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        
        // Do any additional setup after loading the view.
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        else if locationManager.authorizationStatus  == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            //mapView.showsUserLocation = true
            locationManager.desiredAccuracy =  kCLLocationAccuracyNearestTenMeters
            
            locationManager.pausesLocationUpdatesAutomatically = true
            locationManager.activityType = .fitness
            locationManager.distanceFilter = 10
           // locationManager.location?.horizontalAccuracy
            currentLocation = locationManager.location!
            

//https://medium.com/how-to-track-users-location-with-high-accuracy-ios/tracking-highly-accurate-location-in-ios-vol-3-7cd827a84e4d

        }
       /* else if locationManager.authorizationStatus == .denied {
            mapView.showsUserLocation = false
            
            displayMessage(title: "Location Services is Required for this Application.", message: "This application requires location services to be activated; to track the user's progress during walking sessions.")
        }
        */

        
        
      
      //  if mapView.userLocation != nil {
           // focus(mapView)
       // }
       
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
           
            if(centered == false){
                var region = MKCoordinateRegion()
                region.center = currentLocation!.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
                mapView.setRegion(region, animated: true)
        
                centered = true
                mapView.showsUserLocation = true

            }
           // mapView.userLocation = currentLocation
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()

    }
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
            mapView.showsUserLocation = false
            
            displayMessage(title: "Location Services is Required for this Application.", message: "This application requires location services to be activated; to track the user's progress during walking sessions.")
   //         locationManager.requestAlwaysAuthorization()

        }
    }
    /*
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if(centered == false){
            var region = MKCoordinateRegion()
            region.center = userLocation.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
            mapView.setRegion(region, animated: true)
        
            centered = true
            
        }
    }
    */
    
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        let user = databaseController?.fetchUser()
            //    print(user?.userName)
//        if (databaseController?.fetchUser() == nil) {
        locationManager.startUpdatingLocation()
        
       // }
    }
    
    
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
   /* func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //var region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        var region = MKCoordinateRegion()
        region.center = userLocation.coordinate
        region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
        //region.center = mapView.userLocation
       // mapView.userLocation.coordinate
        //CLLocationCoordinate2D(latitude: <#T##CLLocationDegrees#>, longitude: <#T##CLLocationDegrees#>)
    }*/
    
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: locationManager.requestAlwaysAuthorization)
    }
}

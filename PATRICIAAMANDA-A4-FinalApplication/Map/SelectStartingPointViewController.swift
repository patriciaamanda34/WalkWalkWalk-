//
//  SelectStartingPointViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import UIKit
import CoreLocation
import MapKit

class SelectStartingPointViewController: UIViewController, CLLocationManagerDelegate, LocationSearchSelectedDelegate, UISearchBarDelegate {
    
    func updateLocation(selectedLocation: MKPlacemark) -> Bool {
        mapView.removeAnnotation(mapView.annotations[0])

        currentLocation = selectedLocation.location
        latitudeLabel.text = String(format: "%.3f",currentLocation?.coordinate.latitude ?? 0)
        longitudeLabel.text = String(format: "%.3f",currentLocation?.coordinate.longitude ?? 0)
        var region = MKCoordinateRegion()
        region.center = currentLocation!.coordinate
        region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
        mapView.setRegion(region, animated: true)

        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0,longitude: 0)


        
        mapView.addAnnotation(annotation)
        

        return true
    }
    
    @IBOutlet weak var searchBarView: UIView!
    var currCoordinates: CLLocationCoordinate2D?
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()

   // @IBOutlet weak var UISearchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    var resultSearchController:UISearchController? = nil
    
    var saveStartingPointDelegate: SaveStartingPointDelegate?

    // @IBOutlet weak var latitudeTextField: UITextField!
    
//    @IBOutlet weak var longitudeTextField: UITextField!
    
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        if(mapView.annotations.count > 0){
            mapView.removeAnnotation(mapView.annotations[0])
        }
        latitudeLabel.text = String(format: "%.3f",currentLocation?.coordinate.latitude ?? 0)
        longitudeLabel.text = String(format: "%.3f",currentLocation?.coordinate.longitude ?? 0)
        var region = MKCoordinateRegion()
        region.center = currentLocation!.coordinate
        region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
        mapView.setRegion(region, animated: true)

       // mapView.showsUserLocation = true
        
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0,longitude: 0)

        mapView.addAnnotation(annotation)
    }
    
    func usePreviousLocation() {
        latitudeLabel.text = String(format: "%.3f",currCoordinates?.latitude ?? 0)
        longitudeLabel.text = String(format: "%.3f",currCoordinates?.longitude ?? 0)
        
        var region = MKCoordinateRegion()
        region.center = currCoordinates!
        region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
        mapView.setRegion(region, animated: true)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        locationManager.delegate = self
        

        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
       //locationManager.location?.horizontalAccuracy
        currentLocation = locationManager.location!
        // Do any additional setup after loading the view.
        
        if let currCoordinates = currCoordinates {
            useCurrentLocation(self)
        }
        else {
            usePreviousLocation()
        }
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as! LocationSearchTableViewController
        
        resultSearchController?.delegate = locationSearchTable as? UISearchControllerDelegate

        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        searchBarView.addSubview(resultSearchController!.searchBar)
        
        let searchBar = resultSearchController!.searchBar
               searchBar.sizeToFit()
               searchBar.placeholder = "Search for places"
              // navigationItem.titleView = resultSearchController?.searchBar
               resultSearchController?.hidesNavigationBarDuringPresentation = false
              // resultSearchController?.dimsBackgroundDuringPresentation = true
               definesPresentationContext = false
               locationSearchTable.mapView = mapView
        //resultSearchController?.searchBar
        
       // searchContainer.addSubview(searchController.searchBar)

     //   resultSearchController?
  //  UISearchBar.placeholder = "Search for locations"
        
       // UISearchBar = resultSearchController?.searchBar
        
       // resultSearchController?.searchBar = searchBar
      //  let searchBar = resultSearchController!.searchBar
      //  UISearchBar.sizeToFit()
      //  UISearchBar.placeholder = "Search for locations"
        
      //  searchBar.search
              // navigationItem.titleView = resultSearchController?.searchBar
             //  resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        
        locationSearchTable.mapView = mapView
        locationSearchTable.locationSearchSelectedDelegate = self
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        let latitude = CLLocationDegrees(latitudeLabel?.text ?? "") ?? 0
        let longitude = CLLocationDegrees(longitudeLabel?.text ?? "") ?? 0
        let coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if saveStartingPointDelegate?.save(coordinate: coords) != nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
        definesPresentationContext = true
        
       
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        resultSearchController?.becomeFirstResponder()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        resultSearchController?.resignFirstResponder()
        
    }
  /*  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            mapView.removeAnnotation(mapView.annotations[0])

            currentLocation = location
            var region = MKCoordinateRegion()
            region.center = currentLocation!.coordinate
            region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
            mapView.setRegion(region, animated: true)
    
           // mapView.showsUserLocation = true
            }
           // mapView.userLocation = currentLocation
        }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol LocationSearchSelectedDelegate {
    func updateLocation(selectedLocation: MKPlacemark)->Bool
}


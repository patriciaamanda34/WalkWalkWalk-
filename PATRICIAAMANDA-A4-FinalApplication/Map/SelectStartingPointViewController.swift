//
//  SelectStartingPointViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import UIKit
import CoreLocation
import MapKit

class SelectStartingPointViewController: UIViewController, CLLocationManagerDelegate, LocationSearchSelectedDelegate {
    
    //MARK: - Variables
    
    var currCoordinates: CLLocationCoordinate2D?
    var currentLocation: CLLocation?
    let locationManager = CLLocationManager()

    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    
    var resultSearchController:UISearchController? = nil
    
    var saveStartingPointDelegate: SaveStartingPointDelegate?

    
//MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
     
        //Setting delegates
        locationManager.delegate = self
        

        //Setting user tracking functionalities; location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
        currentLocation = locationManager.location!

        //On default, when this view is displayed it will display user's location.
        useCurrentLocation(self)
        
        if let currCoordinates = currCoordinates , (currCoordinates.latitude != 0 && currCoordinates.longitude != 0) {
            centerToLocation(coordinate: currCoordinates) //Center to currCoordinates.
        }
        else{
            centerToLocation(coordinate: currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0))
        }
        
        //Instantiating locationSearchTable
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTableViewController") as! LocationSearchTableViewController
        
        //Instantiating the UISearchController
        resultSearchController?.delegate = locationSearchTable as? UISearchControllerDelegate
        
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        searchBarView.addSubview(resultSearchController!.searchBar)
        
        resultSearchController?.searchBar.delegate = locationSearchTable

        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        
        definesPresentationContext = false
        
        locationSearchTable.mapView = mapView
        locationSearchTable.mapView = mapView
        locationSearchTable.locationSearchSelectedDelegate = self
    }
    
  
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
        definesPresentationContext = true
    }
    
    
//MARK: - Actions
    @IBAction func saveChanges(_ sender: Any) {
        let latitude = CLLocationDegrees(latitudeLabel?.text ?? "") ?? 0
        let longitude = CLLocationDegrees(longitudeLabel?.text ?? "") ?? 0
        
        //Calling the delegate method
        let coords = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        if saveStartingPointDelegate?.save(coordinate: coords) != nil {
            navigationController?.popViewController(animated: true)
        }
    }
    
    
    @IBAction func useCurrentLocation(_ sender: Any) {
        centerToLocation(coordinate: currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0,longitude: 0))
    }
    
    
    //Function: Make the region center to the location specified.
    func centerToLocation(coordinate: CLLocationCoordinate2D){
        for i in mapView.annotations {
            mapView.removeAnnotation(i)
        }
        
        //Updating labels
        latitudeLabel.text = String(format: "%.3f",coordinate.latitude)
        longitudeLabel.text = String(format: "%.3f",coordinate.longitude)
        
        //Updating region
        var region = MKCoordinateRegion()
        region.center = coordinate
        region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
        mapView.setRegion(region, animated: true)
        
        //Adding annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
    }
    
    
//MARK: - UISearchController Methods
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        resultSearchController?.becomeFirstResponder()
    }
    
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        resultSearchController?.resignFirstResponder()
    }
    
    
//MARK: - LocationSearchSelectedDelegate Function
    func updateLocation(selectedLocation: MKPlacemark) -> Bool {
        //Clear all annotations from the previous selections first.
        for annotation in mapView.annotations {
           mapView.removeAnnotation(annotation)
        }
        
        //Updating the variable:
        currentLocation = selectedLocation.location
        
        //Updating the labels
        latitudeLabel.text = String(format: "%.3f",currentLocation?.coordinate.latitude ?? 0)
        longitudeLabel.text = String(format: "%.3f",currentLocation?.coordinate.longitude ?? 0)
        
        //Updating the region
        var region = MKCoordinateRegion()
        region.center = currentLocation!.coordinate
        region.span = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.01), longitudeDelta: CLLocationDegrees(0.01))
        mapView.setRegion(region, animated: true)

        //Placing an annotation.
        let annotation = MKPointAnnotation()
        annotation.coordinate = currentLocation?.coordinate ?? CLLocationCoordinate2D(latitude: 0,longitude: 0)
        mapView.addAnnotation(annotation)
        
        return true
    }
}

//Protocol: To update the ViewController when a search result has been selected.
protocol LocationSearchSelectedDelegate {
    func updateLocation(selectedLocation: MKPlacemark)->Bool
}


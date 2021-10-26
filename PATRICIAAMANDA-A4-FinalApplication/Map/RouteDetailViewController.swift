//
//  RouteDetailViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/21/21.
//

import UIKit
import MapKit

class RouteDetailViewController: UIViewController , MKMapViewDelegate{

    //MARK: - Variables
    @IBOutlet weak var routeNameLabel: UILabel!
    @IBOutlet weak var routeStartPointLabel: UILabel!
    @IBOutlet weak var routeFinishPointLabel: UILabel!
    @IBOutlet weak var routeApproximatedTimeLabel: UILabel!
    @IBOutlet weak var routeMapView: MKMapView!
    @IBOutlet weak var routeDistanceLabel: UILabel!
    
    var route: Route?
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting labels up
        navigationItem.title = route?.routeName
        routeNameLabel.text = route?.routeName
        
        if let startLatitude = route?.routeStartCoordinate?.latitude, let startLongitude = route?.routeStartCoordinate?.longitude, let finishLatitude = route?.routeEndCoordinate?.latitude, let finishLongitude = route?.routeEndCoordinate?.longitude  {
            
            routeStartPointLabel.text = String("\(round(1000*startLatitude)/1000), \(round(1000*startLongitude)/1000)")
            routeFinishPointLabel.text = String("\(round(1000*finishLatitude)/1000), \(round(1000*finishLongitude)/1000)")
           
            let coord1 = CLLocationCoordinate2D(latitude: startLatitude,longitude: startLongitude)
            let coord2 = CLLocationCoordinate2D(latitude: finishLatitude, longitude: finishLongitude)
            
            showRouteOnMap(pickupCoordinate: coord1, destinationCoordinate: coord2)
           
        }
        
        //Setting up delegates
        routeMapView.delegate = self
    }
    
    
    //Shows the route on the map.
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {

            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .walking

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }
                
                //for getting just one route
                if let route = unwrappedResponse.routes.first {
                    //show on map
                    self.routeMapView.addOverlay(route.polyline)
                    //set the map area to show the route
                    self.routeMapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
                    
                    //Setting the labels up.
                    routeDistanceLabel.text = "\(route.distance/1000) Kilometres"

                    //Expected travel time. Mind that the transportType must be .walking for this app.
                    let time = secondsToHoursMinutes(seconds: Int(route.expectedTravelTime))
                    
                    let timeString = makeTimeString(hours: time.0, minutes: time.1)
                    routeApproximatedTimeLabel.text = timeString
                }

            }
        }
    
    
    //this delegate function is for displaying the route overlay and styling it
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         let renderer = MKPolylineRenderer(overlay: overlay)
         renderer.strokeColor = UIColor.blue
         renderer.lineWidth = 5.0
         return renderer
    }
    
    
    //Changes seconds (input) to hours and minutes.
    func secondsToHoursMinutes(seconds: Int) -> (Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60))
    }
    
    
    //Creating a string from hours and minutes given.
    func makeTimeString(hours: Int, minutes: Int) -> String
    {
        var timeString = ""
        if hours != 0 {
        timeString += String(format: "%02d hours", hours)
            timeString += ", "
            
        }
        if minutes == 0 {
            timeString += String(format: "%01d minutes", minutes)
        }
        else{
            timeString += String(format: "%02d minutes", minutes)
            
        }
        return timeString
    }
}

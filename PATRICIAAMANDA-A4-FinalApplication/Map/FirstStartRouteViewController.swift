//
//  FirstStartRouteViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/21/21.
//

import UIKit
import CoreLocation
import MapKit

class FirstStartRouteViewController: UIViewController {
    
//MARK: - Variables
    var route: Route?
    
    var switchViewDelegate : SwitchViewDelegate?
    
    @IBOutlet weak var estimatedTimeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var routeNameLabel: UILabel!
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //Sets labels
        routeNameLabel.text = route?.routeName
        
        let coordinate1 = CLLocationCoordinate2D(latitude: CLLocationDegrees(route?.routeStartCoordinate?.latitude ?? 0), longitude: CLLocationDegrees(route?.routeStartCoordinate?.longitude ?? 0))
        let coordinate2 = CLLocationCoordinate2D(latitude: CLLocationDegrees(route?.routeEndCoordinate?.latitude ?? 0), longitude: CLLocationDegrees(route?.routeEndCoordinate?.longitude ?? 0))
        
        showRouteOnMap(pickupCoordinate: coordinate1, destinationCoordinate: coordinate2)
    }
    
    
    //MARK: - Actions
    @IBAction func startRoute(_ sender: Any) {
            switchViewDelegate?.switchView(sender: self)
            return
    }
    
    
    //MARK: - Route Calculation Functions
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
                    //Sets the labels with calculated information.
                    distanceLabel.text = "\(route.distance/1000) Kilometres"
                    
                    let time = secondsToHoursMinutes(seconds: Int(route.expectedTravelTime))
                    
                    let timeString = makeTimeString(hours: time.0, minutes: time.1)
                    
                    estimatedTimeLabel.text = timeString
                }
            }
        }
   
    
    //Converts seconds to hours and minutes.
    func secondsToHoursMinutes(seconds: Int) -> (Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60))
    }
    
    
    //Converts hours and minutes to a string.
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

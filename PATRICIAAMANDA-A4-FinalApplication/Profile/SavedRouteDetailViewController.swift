//
//  SavedRouteDetailViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/21/21.
//

import UIKit
import MapKit

class SavedRouteDetailViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {

//MARK: - Variables
    var totalRoutePolyline : MKPolyline?
    var totalSavedRoutePolyline : MKPolyline?
    
    //Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var savedRouteNameLabel: UILabel!
    @IBOutlet weak var routeButton: UIButton!
    @IBOutlet weak var savedRouteNameTextField: UITextField!
    
    @IBOutlet weak var savedRouteStartPointLabel: UILabel!
    @IBOutlet weak var savedRouteEndPointLabel: UILabel!
    @IBOutlet weak var savedRouteDistanceWalkedLabel: UILabel!
    @IBOutlet weak var savedRouteStepsLabel: UILabel!
    @IBOutlet weak var savedRouteTimeElapsedLabel: UILabel!
    @IBOutlet weak var savedRouteDateTimeLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var savedRoute : SavedRoute?

    
//MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting delegates
        mapView.delegate = self
        nameTextField.delegate = self

        //Setting labels
        if savedRoute?.savedRouteName != nil {
            savedRouteNameLabel.text = savedRoute?.savedRouteName
            
            navigationItem.title = savedRoute?.savedRouteName
            
            //Hidding buttons:
            //https://stackoverflow.com/questions/39260491/how-to-hide-bar-button-item
            navigationItem.rightBarButtonItem?.isEnabled = false
            navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
            
            savedRouteNameTextField.isHidden = true
        }
        else {
            navigationItem.title = "Save Walk Session?"
            savedRouteNameTextField.isHidden = false
        }
        
        if let name = savedRoute?.routeStats?.routeName {
            routeButton.setTitle("\(name)", for: .normal)
        }
        
        let walkStats = savedRoute?.savedRouteStats
        savedRouteStepsLabel?.text = String(walkStats?.walkNoOfSteps ?? 0)
        savedRouteDistanceWalkedLabel.text = String(walkStats?.walkDistance ?? 0)
        
        //Formatting Walk Start and Walk End
        if let walkDateStart = walkStats?.walkDateStart, let walkDateEnd = walkStats?.walkDateEnd {
            var labelString : String = ""
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "hh:mm:ss"
        
            labelString+=dateFormatter.string(from: walkDateStart)
            labelString += ", "
            labelString+=timeFormatter.string(from: walkDateStart)
            labelString += " to "
            if dateFormatter.string(from: walkDateStart) != dateFormatter.string(from: walkDateEnd) {
                labelString+=dateFormatter.string(from: walkDateEnd)
                labelString += ", "
            }
            labelString+=timeFormatter.string(from: walkDateEnd)
            
              savedRouteDateTimeLabel.text = labelString
          }
        
        let time = secondsToHoursMinutesSeconds(seconds: Int(walkStats?.walkTime ?? 0))
        
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds:time.2)

        savedRouteTimeElapsedLabel.text = timeString
        
    
        //Setting totalSavedRoutePolyline
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let databaseController = appDelegate?.databaseController
        if let coordinates = databaseController?.fetchAllCoordinatesInSavedRoute(savedRoute: savedRoute!) {
            let startLatitude = coordinates.first?.latitude
            let startLongitude = coordinates.first?.longitude
            let finishLatitude = coordinates.last?.latitude
            let finishLongitude = coordinates.last?.longitude
            if let startLatitude = startLatitude, let startLongitude = startLongitude, let finishLatitude = finishLatitude, let finishLongitude = finishLongitude {
                savedRouteStartPointLabel.text = "\(round(1000*startLatitude)/1000), \(round(1000*startLongitude)/1000)"
                savedRouteEndPointLabel.text = "\(round(1000*finishLatitude)/1000), \(round(1000*finishLongitude)/1000)"
            }
            totalSavedRoutePolyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(totalSavedRoutePolyline!)
        
            if coordinates.count > 0 {
                mapView.setVisibleMapRect(totalSavedRoutePolyline!.boundingMapRect, edgePadding: UIEdgeInsets.init(top: 80.0, left: 20.0, bottom: 100.0, right: 20.0), animated: true)
            }
        }
        
        //Drawing a polyline of the route on the map.
        if let route = savedRoute?.routeStats {
            let start =  route.routeStartCoordinate
            let startLatitude = start?.latitude ?? 0
            let startLongitude = start?.longitude ?? 0
            
            let end = route.routeEndCoordinate
            let finishLatitude = end?.latitude ?? 0
            let finishLongitude = end?.longitude ?? 0
                
            showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D(latitude: startLatitude, longitude: startLongitude), destinationCoordinate: CLLocationCoordinate2D(latitude: finishLatitude, longitude: finishLongitude))
        }
    }
    
    
    //MARK: - Actions
    @IBAction func saveSavedRoute(_ sender: UIBarButtonItem) {
        //Error checking
        if savedRouteNameTextField.text == "" {
            displayMessage(title: "Warning", message: "Route Name field cannot be empty.")
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let databaseController = appDelegate?.databaseController
          
        //Checking if the name is a duplicate, if so, show a warning message.
        let savedRoutes = databaseController?.fetchSavedRoutes()
        let count = savedRoutes?.count ?? 0
        if count > 0 {
            for i in 0...count-1 {
                if savedRoutes?[i].savedRouteName == savedRouteNameTextField.text {
                    //Warning
                    if let temp = savedRoutes?[i].savedRouteName {
                    displayMessage(title: "Warning", message: "A route with the name \(String(describing: temp)) already exists. Please input a different name.")
                        return
                    }
                }
            }
         }
        
        //Error checks have passed, save the SavedRoute
        savedRoute?.savedRouteName = savedRouteNameTextField.text
            
        do {
            try self.savedRoute?.managedObjectContext?.save()
        }
        catch{
            print("ERROR SAVING SAVEDROUTE: \(error)")
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func cancelAction(_ sender: Any) {
        if savedRoute?.savedRouteName == nil {
            //Send a warning if SavedRoute hasn't been saved yet.
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to leave? This page will not be saved.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel,
             handler: nil))
            alertController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: rollbackAndPop))
                                      
            present(alertController, animated: true, completion: nil)
        }
        else {
            navigationController?.popViewController(animated: true)
            return
        }
    }
    
    
    //Rollbacks the child context then pops the view.
    func rollbackAndPop(alertAction : UIAlertAction){
        savedRoute?.managedObjectContext?.rollback()
        navigationController?.popToRootViewController(animated: false)
        return
    }
    
    
//MARK: - MapViewDelegate Methods
    //This delegate function is for displaying the route overlay and styling it
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Displaying 2 Polylines in a MapView:
        //https://stackoverflow.com/questions/28045266/how-to-draw-two-polylines-in-different-colors-in-mapkit?rq=1
        var renderer = MKPolylineRenderer()
        if overlay is MKPolyline {
            if overlay as? MKPolyline == totalRoutePolyline {
                renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5.0
            }
            else if overlay as? MKPolyline == totalSavedRoutePolyline {
                renderer = MKPolylineRenderer(overlay: overlay)
                renderer.strokeColor = UIColor.green
                renderer.lineWidth = 3.0
            }
        }
        return renderer

    }
    
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    
    func makeTimeString(hours: Int, minutes: Int, seconds : Int) -> String
    {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += " : "
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "savedRouteRouteDetailSegue" {
            let destination = segue.destination as! RouteDetailViewController
            destination.route = savedRoute?.routeStats
        }
     }
    
    
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
                    totalRoutePolyline = route.polyline
                    self.mapView.addOverlay(totalRoutePolyline!)
                }
            }
        }
   
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - TextField delegate methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
    


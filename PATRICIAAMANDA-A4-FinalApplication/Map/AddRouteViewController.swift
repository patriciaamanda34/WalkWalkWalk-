//
//  AddRouteViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import UIKit
import MapKit
class AddRouteViewController: UIViewController, SaveStartingPointDelegate {
  
    //MARK: - Variables:
    
    //Variables for finding the route.
    
    //Max iterations allowed before changing the direction
    let maxIterations = 10
    var iter = 0
    
    //When a direction has been tried, put it in this array.
    var notAllowedDirections : [Int] = []
    
    //maxDistance marks the distances allowed by the app.
    //For instance, if it is currently at 100, and the difference between route found and route distance is 90, it will be accepted as a result.
    var maxDistance : [Int] = [100,200,300,400,500]
 
    
    //Outlets
    @IBOutlet weak var routeNameTextField: UITextField!
    
    @IBOutlet weak var startingPointButton: UIButton!
    
    @IBOutlet weak var distanceTextField: UITextField!
    
    var route: Route?
    
    var indicator = UIActivityIndicatorView()
    
    //Source: https://www.usna.edu/Users/oceano/pguth/md_help/html/approx_equivalents.htm#:~:text=At%20the%20equator%20for%20longitude,0.1%C2%B0%20%3D%2011.1%20km
    //1 degree = 111 km approximately
    //0.1 degree = 11.1km
    let distancePerDegree = 111.0 //111 kilometres per degree.
    
    weak var databaseController: DatabaseProtocol?
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
       
        if route == nil {
            route = databaseController?.createRouteInChild()
        }
        
        if let latitude = route?.routeStartCoordinate?.latitude, let longitude = route?.routeStartCoordinate?.longitude {
            if(latitude != 0.0 && longitude != 0.0){
                startingPointButton.setTitle(String("\(latitude), \(longitude)"), for: .normal)
            }
        }
        
        //Add a loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:
                                                view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    
    //MARK: - Actions
    @IBAction func createRoute(_ sender: Any) {
            
        //Error checking to make sure invalid values are eliminated first.
        if routeNameTextField.text == "" {
            displayMessage(title: "Warning", message: "Route Name field cannot be empty.")
            return
        }
        if distanceTextField.text == "" {
            displayMessage(title: "Warning", message: "Distance field cannot be empty.")
            return
        }
        else if let tempDistance = Double(distanceTextField.text!) {
            if tempDistance <= 0 {
                displayMessage(title: "Warning", message: "Distance cannot be empty or a zero.")
                return
            }
            else if tempDistance >= 25 {
                displayMessage(title: "Warning", message: "Distance can only be up to 25 kilometres.")
                return
            }
        }
        if route?.routeStartCoordinate?.latitude == 0 && route?.routeStartCoordinate?.longitude == 0 {
            displayMessage(title: "Warning", message: "Route Start Coordinates cannot be empty. Click on 'Select a Starting point' to select a starting point.")
            return
        }
        
        route?.routeName = routeNameTextField.text
     
        //Error checking: Name cannot be the same.
        let routes = self.databaseController?.fetchMyRoutes()
        let count = routes?.count ?? 0
        
        if count>0 {
            for i in 0...count-1 {
                 if routes?[i].routeName == self.route?.routeName {
                    //Warning
                    if let routeNameTemp = routes?[i].routeName{
                    displayMessage(title: "Warning", message: "A route with the name \(String(describing: routeNameTemp)) already exists. Please input a different name.")
                        return
                    }
                }
            }
        }
          
        //Error checks have passed, now to find the route.
        let distance : Double = Double(distanceTextField.text ?? "") ?? 0
        
        //A random value from 0 to 3 - indicates the direction we want to find the route in.
        var direction = Int.random(in: 0...3)
                
        var length : Double = 0
         
        length = distance/distancePerDegree
        
    
        if notAllowedDirections.count >= 4 {
            //If all directions are already tried, and all distances are already tried too, display an error and return
            if(maxDistance.count == 0) {
                displayMessage(title: "Error", message: "Route not found. Please try again with different parameters and try again in a few moments.")
                
                indicator.stopAnimating()
                
                //"Resetting" maxDistance
                maxDistance = [100,200,300,400,500]
                return
            }
            
            //If all directions are already tried, try a further distance.
            maxDistance.removeFirst()
            notAllowedDirections.removeAll()
            //print(notAllowedDirections)
        }
        
        
        //Not allowed to use directions that are in notAllowedDirections, as those have been tried.
        while notAllowedDirections.contains(direction) {
            direction = Int.random(in: 0...3)
        }
        
        
        //Intializing the end coordinate of the route.
        route?.routeEndCoordinate = databaseController?.createCoordinateInChild()
        
        if (direction == 0) {
            route?.routeEndCoordinate?.latitude = route!.routeStartCoordinate!.latitude + length
            route?.routeEndCoordinate?.longitude = route?.routeStartCoordinate?.longitude ?? 0
        }
        else if (direction == 1) {
            route?.routeEndCoordinate?.latitude = route!.routeStartCoordinate!.latitude - length
            route?.routeEndCoordinate?.longitude = route?.routeStartCoordinate?.longitude ?? 0

        }
        else if (direction == 2) {
            route?.routeEndCoordinate?.longitude = (route?.routeStartCoordinate!.longitude)! + length
            route?.routeEndCoordinate?.latitude = route!.routeStartCoordinate?.latitude ?? 0

        }
        else if (direction == 3) {
            route?.routeEndCoordinate?.longitude = (route?.routeStartCoordinate!.longitude)! - length
            route?.routeEndCoordinate?.latitude = route!.routeStartCoordinate?.latitude ?? 0

        }
     
        
        //Making CLLocationCoordinate2D objects using the start and end coordinate and try to form a route.
        let coor1 = CLLocationCoordinate2D(latitude: CLLocationDegrees(route?.routeStartCoordinate?.latitude ?? 0), longitude: CLLocationDegrees(route?.routeStartCoordinate?.longitude ?? 0))

        let coor2 = CLLocationCoordinate2D(latitude: CLLocationDegrees(route?.routeEndCoordinate?.latitude ?? 0), longitude: CLLocationDegrees(route?.routeEndCoordinate?.longitude ?? 0))
       

        _ = calculateRouteDistance(pickupCoordinate: coor1, destinationCoordinate: coor2, distanceNeeded: distance, direction: direction, length: length)
    }
    
    
    //Runs when back button is pressed, will send a warning before rollbacking the changes.
    @IBAction func backButtonPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to leave? This page will not be saved.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel,
         handler: nil))
        
        //rollbackAndPop will run when this is selected:
        alertController.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: rollbackAndPop))
                                  
        present(alertController, animated: true, completion: nil)

    }
    
    
    func rollbackAndPop(alertAction : UIAlertAction){
        //Rollbacks the child context.
        route?.managedObjectContext?.rollback()
        //Pops this view.
        navigationController?.popToRootViewController(animated: false)
        return
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if (segue.identifier == "selectStartingPointSegue") {
            let destination = segue.destination as! SelectStartingPointViewController
            
            var temp = CLLocationCoordinate2D()
            temp.latitude = CLLocationDegrees(route?.routeStartCoordinate?.latitude ?? 0)
            temp.longitude = CLLocationDegrees(route?.routeStartCoordinate?.longitude ?? 0)
            
            destination.currCoordinates = temp
            destination.saveStartingPointDelegate = self
        }
    }
    

    //MARK: - Misc Functions
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //Calculates the route's distance using Apple's MKDirections.calculate() given two coordinates.
    func calculateRouteDistance(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D, distanceNeeded: Double, direction: Int, length: Double) {
        
        indicator.startAnimating()

        
        let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil))
            request.requestsAlternateRoutes = true
            request.transportType = .walking

            let directions = MKDirections(request: request)
        
            directions.calculate { response, error in
            guard let unwrappedResponse = response else {
                if let error = error {
                    //Dev note: Error mostly caused by the frequency of this request:
                    //https://developer.apple.com/forums/thread/90152

                    print("Error forming a route: \(error)")
                                        
                    self.notAllowedDirections.append(direction)
                    self.iter = 0
                    
                    self.createRoute(self)
                }
                return
            }
            //Runs after the MKDirections gets calculated.
            DispatchQueue.main.async {
            
                if let route = unwrappedResponse.routes.first {
                    
                    let bool = self.calculateDifference(route.distance, distanceNeeded*1000, direction, length)
                    self.iter += 1

                    //If it has iterated more or equal to maxIterations, find another direction.
                    if (self.iter >= self.maxIterations) {
                        self.notAllowedDirections.append(direction)
                        self.iter = 0
                        self.createRoute(self)
                        return
                    }
                    
                    //If bool is true, save the route.
                    if (bool == true) {
                        do {
                            try self.route?.managedObjectContext?.save()
                        }
                        catch {
                            print("ERROR SAVING ROUTE: \(error)")
                        }
                        
                         self.indicator.stopAnimating()

                         self.navigationController?.popViewController(animated: true)
                         return
                    }
                    
                    else {
                        //Recursive call
                        let coor1 = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.route?.routeStartCoordinate?.latitude ?? 0), longitude: CLLocationDegrees(self.route?.routeStartCoordinate?.longitude ?? 0))

                        let coor2 = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.route?.routeEndCoordinate?.latitude ?? 0), longitude: CLLocationDegrees(self.route?.routeEndCoordinate?.longitude ?? 0))
                        let distance : Double = Double(self.distanceTextField.text ?? "") ?? 0
                        self.calculateRouteDistance(pickupCoordinate: coor1, destinationCoordinate: coor2, distanceNeeded: distance, direction: direction, length: length)
                    }
                }
            }
        }
    }
       
     
    //Calculates the distance difference between routeDistance and distanceNeeded, then sets the end point according to the direction
    //and the difference.
    func calculateDifference(_ routeDistance : Double, _ distanceNeeded : Double, _ direction: Int, _ length: Double)->Bool {
        let result = routeDistance - distanceNeeded

        //If the difference is acceptable, (is less or equal to maxDistance), return true.
        if(abs(result) <= Double(maxDistance.first ?? 0)) {
            return true
        }
        else {
            //Sets a new length
            let len = (result/1000)/distancePerDegree
            
            //If result is positive, it means that the route calculated was too far from the distance needed.
            if (result > 0) {
                //print("result is positive")
                if direction == 0 {
                    route?.routeEndCoordinate?.latitude -= len
                }
                else if direction == 1 {
                    route?.routeEndCoordinate?.latitude += len
                }
                else if direction == 2 {
                    route?.routeEndCoordinate?.longitude -= len
                }
                else if direction == 3 {
                    route?.routeEndCoordinate?.longitude += len
                }
            }
            //If result is negative, it means that the route calculated was too near from the distance needed.
            else if (result < 0) {
                //print("result is negative")
                if direction == 0 {
                    route?.routeEndCoordinate?.latitude += len
                }
                else if direction == 1 {
                    route?.routeEndCoordinate?.latitude -= len
                }
                else if direction == 2 {
                    route?.routeEndCoordinate?.longitude += len
                }
                else if direction == 3 {
                    route?.routeEndCoordinate?.longitude -= len
                }
            }
            return false
        }
    }
    
    
//MARK: - SaveStartingPointDelegate Function
        func save(coordinate: CLLocationCoordinate2D) -> Bool! {
            
            //Initiating databaseController if it hasn't been set.
            if databaseController==nil {
                let appDelegate = UIApplication.shared.delegate as? AppDelegate

                databaseController = appDelegate?.databaseController
            }
            
            if let route = route {
                let latitude = Double(coordinate.latitude)
                let longitude = Double(coordinate.longitude)
                  
                route.routeStartCoordinate = databaseController?.createCoordinateInChild()
                route.routeStartCoordinate?.latitude = latitude
                route.routeStartCoordinate?.longitude = longitude
                
                //Edit the startingPointButton's title
                if (latitude != 0.0 && longitude != 0.0) {
                    if let startingPointButton = startingPointButton {
                        startingPointButton.setTitle(String("\(latitude), \(longitude)"), for: .normal)
                    }
                }
            }
            else {
                //If route is nil:
                return false
            }
            return true
        }
        
        
//MARK: - Delegation from ExploreTableViewController
    func updateCoordinates(coordinate: CLLocationCoordinate2D) {

         if databaseController==nil {
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            databaseController = appDelegate?.databaseController
         }
         if route == nil {
             route = databaseController?.createRouteInChild()
             save(coordinate: coordinate)
         }
     }
}


//Protocol: for SelectStartingPointViewController to update the information on AddRouteViewController.
protocol SaveStartingPointDelegate {
    func save(coordinate: CLLocationCoordinate2D)->Bool!
}

    

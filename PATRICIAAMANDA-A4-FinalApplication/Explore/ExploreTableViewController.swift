//
//  ExploreTableViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/23/21.
//

import UIKit
import MapKit
class ExploreTableViewController: UITableViewController, CLLocationManagerDelegate {

    
// MARK: - Variables

    
    var locations: [LocationData]?
    
    let locationManager = CLLocationManager()
    
    var indicator = UIActivityIndicatorView()
    
    
//MARK: - View Related Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        //Sets self as a CLLocationManagerDelegate to track user's location.
        locationManager.delegate = self
        
        //Tracking user's location
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1
        let currentLocation = locationManager.location!
        
        //Requesting a location
        requestLocations(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
        
        
        // Add a loading indicator view
        //(Taken from FIT3178 Labs)
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

    
    override func viewWillDisappear(_ animated: Bool) {
        locationManager.stopUpdatingLocation()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        locationManager.startUpdatingLocation()
    }
   
    
//MARK: - API Request Methods
    func requestLocations(latitude: Double?, longitude: Double?){
        indicator.startAnimating()

        //URL Example: This works for coords -37.9245, 145.1201.
        //10km radius from user's location in URL.
        //https://api.opentripmap.com/0.1/en/places/radius?radius=10000&lon=145.1201&lat=-37.9245&format=json&limit=10&apikey=5ae2e3f221c38a28845f05b6270bd423ddfaacb903ebddcee43f6f7e

        //Constructing URL
        var url = ""
        if let latitude = latitude, let longitude = longitude{
            url = "https://api.opentripmap.com/0.1/en/places/radius?radius=10000&lon=\(longitude)&lat=\(latitude)&format=json&limit=10&apikey=5ae2e3f221c38a28845f05b6270bd423ddfaacb903ebddcee43f6f7e"
        }
        //print("REQUEST URL: \(url)")
        
        let searchURL = URL(string: url)
        guard let requestURL = searchURL else {
            print("Invalid URL.")
            return
        }
        
        
        //Request
        let task = URLSession.shared.dataTask(with: requestURL) {
            (data, response, error) in
            // This closure is executed on a different thread at a later point in
            // time!
            
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            if let error = error {
                print(error)
                return
            }

            do {
                let decoder = JSONDecoder()
                let locationsData = try decoder.decode([LocationData].self, from: data!)

                var loc : [LocationData] = [LocationData]()

                //Removes those without names - I take this as useless data due to the lack of information.
                for l in 0...locationsData.count-1 {
                    if locationsData[l].name != "" {
                        loc.append(locationsData[l])
                        }
                    }
                
                self.locations = loc
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let err {
                print(err)
            }
        }
        task.resume()
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //Returns the number of sections
        return 1
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations?.count ?? 0
       
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! ExploreTableViewCell

        // Configure the cell...
        if let locations = locations {
        cell.nameLabel.text = locations[indexPath.row].name
            
            let categories = locations[indexPath.row].categories
            var str = ""
            for char in categories {
                if char == "_" {
                    str = str +  " "
                }
                else if char == "," {
                    str = str + ", "
                }
                else {
                    str = str + String(char)
                }
            }
            cell.descriptionLabel.text = str
            if let lat = locations[indexPath.row].latitude, let lon = locations[indexPath.row].longitude{
                
                cell.coordinateLabel.text = "Location: \(lat), \(lon)"
                
                //Source: https://stackoverflow.com/questions/26880526/performing-a-segue-from-a-button-within-a-custom-uitableviewcell
                //Tag to find which cell's button was tapped.
                cell.addButton.tag = indexPath.row
                cell.addButton.addTarget(self, action: #selector(ExploreTableViewController.buttonTapped(_:)), for: UIControl.Event.touchUpInside)

            }
        }
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    
    //MARK: - Actions
    @IBAction func buttonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "addLocationAsStartingPointSegue", sender: sender)
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addLocationAsStartingPointSegue" {
            let destination =  segue.destination as! AddRouteViewController

            var lat: Double = 0
            var long: Double = 0
            
            //Checking if the user tapped the cell or the button.
            if let button = sender as? UIButton {
                lat = locations?[button.tag].latitude ?? 0
                long = locations?[button.tag].longitude ?? 0
            }
            else if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for:cell) {
                 lat = locations?[indexPath.row].latitude ?? 0
                 long = locations?[indexPath.row].longitude ?? 0
            }
            
            //Delegate call
            destination.updateCoordinates(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long)))
        }
    }
    

}

//
//  AddRouteViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import UIKit
import MapKit
class AddRouteViewController: UIViewController, SaveStartingPointDelegate {
    func save(coordinate: CLLocationCoordinate2D) -> Bool! {
        route?.routeStartLatitude = Double(coordinate.latitude)
        route?.routeStartLongitude = Double(coordinate.longitude)
        if let latitude = route?.routeStartLatitude, let longitude = route?.routeStartLongitude {
            if(latitude != 0.0 && longitude != 0.0){
                let temp = String(format: "%.3f", latitude)
                let temp2 = String(format: "%.3f", longitude)
                startingPointButton.setTitle(String("\(temp), \(temp2)"), for: .normal)
                
            }
        }
        return true
    }
    

    @IBOutlet weak var routeNameTextField: UITextField!
    
    @IBOutlet weak var startingPointButton: UIButton!
    
    @IBOutlet weak var fixedLocationsSwitch: UISwitch!
    
    @IBOutlet weak var distanceTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var loopSwitch: UISwitch!
    var route: Route?
    
    weak var databaseController: DatabaseProtocol?
    
    @IBAction func fixedLocationsSwitchValueChanged(_ sender: UISwitch) {
        
        if(fixedLocationsSwitch.isOn) {
            tableView.isHidden = false
        }
        else {
            tableView.isHidden = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isHidden = true
        // Do any additional setup after loading the view.
        
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
       
        route = databaseController?.fetchRouteInChild()
        if let latitude = route?.routeStartLatitude, let longitude = route?.routeStartLongitude {
            if(latitude != 0.0 && longitude != 0.0){
                startingPointButton.setTitle(String("\(latitude), \(longitude)"), for: .normal)
                
            }
        }
        
        if let loop = route?.routeLoopsBack{
                if(loop == true){
            loopSwitch.setOn(true, animated: true)
                }
                
            }
        }
    
    

    @IBAction func createRoute(_ sender: Any) {
        //save child context to main context probably
        
        
    }
    
    func requestFinishPoint(){
        //https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=Museum%20of%20Contemporary%20Art%20Australia&inputtype=textquery&fields=photos,formatted_address,name,rating,opening_hours,geometry&key=YOUR_API_KEY
        let latitude = route?.routeStartLatitude
        let longitude = route?.routeFinishLongitude
        let distance = distanceTextField?.text
        let url1 = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?"
        let url2 = "input=&inputtype=textquery&circular=\(distance)@\(latitude),\(longitude)&key=AIzaSyCno81mkRs1wQGv4iFbsDSKKf2TJ7eAB1c"
        let searchURL = URL(string: (url1+url2))
        guard let requestURL = searchURL else {
            print("Invalid URL.")
            return
        }
        
        
     /*   let task = URLSession.shared.dataTask(with: requestURL) {
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
                let volumeData = try decoder.decode(VolumeData.self, from: data!)
                if let books = volumeData.books {
                    self.newBooks.append(contentsOf: books)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                    }
                    if books.count == self.MAX_ITEMS_PER_REQUEST,
                    self.currentRequestIndex + 1 < self.MAX_REQUESTS {
                    self.currentRequestIndex += 1
                    self.requestBooksNamed(bookName)
                    }
                }
            } catch let err {
                print(err)
            }
        }
        task.resume()*/
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if(segue.identifier == "selectStartingPointSegue") {
            let destination = segue.destination as! SelectStartingPointViewController
            var temp = CLLocationCoordinate2D()
            temp.latitude = CLLocationDegrees(route?.routeStartLatitude ?? 0)
            temp.longitude = CLLocationDegrees(route?.routeStartLongitude ?? 0)
            destination.currCoordinates = temp
            destination.saveStartingPointDelegate = self
        }
        // Pass the selected object to the new view controller.
    }
    

}

protocol SaveStartingPointDelegate {
    func save(coordinate: CLLocationCoordinate2D)->Bool!
}

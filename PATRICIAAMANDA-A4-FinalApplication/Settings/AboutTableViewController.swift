//
//  AboutTableViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 6/3/21.
//

import UIKit
import WebKit


class AboutTableViewController: UITableViewController {

    //My references
    var references : [Int : Reference] = [
        0:Reference(title: "Timers in Swift", url: "https://www.youtube.com/watch?v=3TbdoVhgQmE"),
        1:Reference(title: "Looking Up Location using MKLocalSearchRequest", url: "https://www.hackingwithswift.com/example-code/location/how-to-look-up-a-location-with-mklocalsearchrequest"),
        2:Reference(title: "Searching for Location Using Apple's MapKit", url: "https://www.thorntech.com/how-to-search-for-location-using-apples-mapkit/"),
        3:Reference(title: "Creating a Bar Chart on iOS", url: "https://www.robkerr.com/creating-ios-bar-chart-code-swift/"),
        4:Reference(title: "Track Users' Location with High Accuracy", url: "https://medium.com/how-to-track-users-location-with-high-accuracy-ios/tracking-highly-accurate-location-in-ios-vol-3-7cd827a84e4d"),
        5:Reference(title: "Approximate Metric Equivalents for Degrees, Minutes, and Seconds", url: "https://www.usna.edu/Users/oceano/pguth/md_help/html/approx_equivalents.htm#:~:text=At%20the%20equator%20for%20longitude,0.1%C2%B0%20%3D%2011.1%20km"),
        6:Reference(title: "Displaying a Route between 2 Locations", url:"https://fabcoding.com/2020/08/03/swift-display-route-between-2-locations-using-mapkit/"),
        7:Reference(title: "Sending Local Notifications at a Certain Time", url: "https://stackoverflow.com/questions/31821339/how-to-send-a-localnotification-at-a-specific-time-everyday-even-if-that-time-h"),
        8:Reference(title: "Switching Views in View Container", url: "https://www.youtube.com/watch?v=A6vxDDAUj2o"),
        9:Reference(title: "Storing When App Goes to Background", url: "https://stackoverflow.com/questions/31862394/continue-countdown-timer-when-app-is-running-in-background-suspended"),
        10:Reference(title: "Detecting App Going to Background", url: "https://www.hackingwithswift.com/example-code/system/how-to-detect-when-your-app-moves-to-the-background"),
        11:Reference(title: "Making a CMPedometer", url: "https://makeapppie.com/2017/02/14/introducing-core-motion-make-a-pedometer/")
    ]


    //My APIs used
    var apis : [Int : Reference] = [0: Reference(title: "OpenTripMap API", url: "https://opentripmap.io/product")]
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return references.count
        }
        else if section == 1 {
            return apis.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?

        if indexPath.section == 0 {
    
            cell = tableView.dequeueReusableCell(withIdentifier: "referenceCell", for: indexPath)
            
            cell?.textLabel?.text = references[indexPath.row]?.title
            cell?.detailTextLabel?.text = references[indexPath.row]?.url
        }
        else if indexPath.section == 1 {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "apiCell", for: indexPath)
            
            cell?.textLabel?.text = apis[indexPath.row]?.title
            cell?.detailTextLabel?.text = apis[indexPath.row]?.url

        }
        return cell!
    }
    
    
    //Headers for each section.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "References"
        }
        else if section == 1 {
            return "APIs"
        }
        return nil
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var url : URL?
        if indexPath.section == 0{
            url = URL(string: references[indexPath.row]!.url)!
        }
        else if indexPath.section == 1 {
            url = URL(string: apis[indexPath.row]!.url)!
        }
        
        //Open the URL in the device's browser.
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


//Struct that contains a title of a reference and its url.
struct Reference {
    var title : String
    var url : String
}

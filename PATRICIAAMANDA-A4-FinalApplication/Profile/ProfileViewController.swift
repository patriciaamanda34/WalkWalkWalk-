//
//  ProfileViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, BarClickDelegate {
    
//MARK: - Variables
    //Outlets
    @IBOutlet weak var barInfoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    @IBOutlet weak var distanceWalkedTodayLabel: UILabel!
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var weeklyStatsView: WeeklyStatsView!
    
    //Variables
    var user: User?
    weak var databaseController: DatabaseProtocol?

    var steps : [Double] = []
    var distances : [Double] = []
    var times : [Double] = []
    
    
//MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        weeklyStatsView.barClickDelegate = self
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //Resets these values so that they don't overlap when view loads again.
        steps.removeAll()
        distances.removeAll()
        times.removeAll()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        //Gets the user
        user = databaseController?.fetchUser()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
               
        let date =  dateFormatter.string(from: (user?.userDateOfBirth)!)

        //Sets labels
        dateOfBirthLabel.text = date
        nameLabel.text = user?.userName
        
        let walkStats = databaseController?.fetchWalkStatsInUser(user: user!)
        stepsTodayLabel.text = String(walkStats?.last?.walkNoOfSteps ?? 0)
        distanceWalkedTodayLabel.text = String(walkStats?.last?.walkDistance ?? 0)
        
        //Sets the arrays to display the bar graph
        if let walkStats = walkStats {
            for i in 0...walkStats.count-1 {
                steps.append(Double(walkStats[i].walkNoOfSteps))
                distances.append(Double(walkStats[i].walkDistance))
                times.append(Double(walkStats[i].walkTime))
            }
            //Make the array sizes to 7 since we want to display 7 amount of info at a time
                while steps.count < 7 {
                    steps.append(0.0)
                }
                while distances.count < 7 {
                    distances.append(0.0)
                }
                while times.count < 7 {
                    times.append(0.0)
                }
            }
            
        //To load the chart when the view first loads.
        chartTypeValueChanged(segmentedControl)

        barInfoLabel.text = ""
    }
    
    
//MARK: - Actions
    @IBAction func chartTypeValueChanged(_ sender: UISegmentedControl) {
        var dataPoints = [Double]()
        
        switch sender.selectedSegmentIndex {
            case 0:
                dataPoints = distances
            case 1:
                dataPoints = steps
            case 2:
                dataPoints = times
            default:
                dataPoints = distances

        }
        weeklyStatsView.setData(dataPoints)
    }
    

    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String
    {
        var timeString = ""
        if hours != 0 {

        timeString += String(format: "%02d hours", hours)
        timeString += ", "
            
        }
        if minutes == 0 && hours != 0 {
            timeString += String(format: "%01d minutes, ", minutes)
        }
        else if minutes != 0 {
            timeString += String(format: "%02d minutes, ", minutes)
            
        }
        timeString += String(format: "%02d seconds", seconds)

        return timeString
    }
    
    
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
    
    
    //MARK: - BarClickDelegate Methods
    func barClicked(tag: Int) {
        //Display barInfoLabel and set its value.
        barInfoLabel.isHidden = false
        
        let walkStats = user?.userStats?.allObjects as? [WalkStats]
        let date = walkStats?[tag].walkDateStart
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let i = segmentedControl.selectedSegmentIndex
        
        if i == 0 {
            barInfoLabel.text = "Distance walked on  \(dateFormatter.string(from: date ?? Date())) is  \(round(10000*distances[tag])/10000) km"
        }
        else if i == 1 {
            barInfoLabel.text = "Steps taken on \(dateFormatter.string(from: date ?? Date())) is \(Int(steps[tag]))"

        }
        else {
            let time = secondsToHoursMinutesSeconds(seconds: Int(times[tag]))
            let timeStr = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
            barInfoLabel.text = "Time spent walking on \(dateFormatter.string(from: date ?? Date())) is \(timeStr)"
        }
    }
}


//Delegate called when the bar is clicked.
protocol BarClickDelegate : NSObject {
    func barClicked(tag: Int)
}

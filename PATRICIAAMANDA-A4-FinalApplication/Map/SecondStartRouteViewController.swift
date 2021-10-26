//
//  SecondStartRouteViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/24/21.
//

import UIKit
import UserNotifications
import CoreMotion

class SecondStartRouteViewController: UIViewController, SwitchViewDelegate {
    
//MARK: - Variables
    let pedometer = CMPedometer()
    
    //Values that change when timer is running
    var numberOfSteps:Int! = 0
    var distance:Double! = 0
    
    var routeLength : Double?
    
    //Used to when the timer goes to the background
    var currentBackgroundDate : Date?
        
    var route: Route?

    var timer:Timer = Timer()
    var count:Int = 0
    var timerCounting : Bool = true
    
    //Outlets
    @IBOutlet weak var routeNameLabel: UILabel!

    @IBOutlet weak var routeCurrentDistanceLabel: UILabel!
    
    @IBOutlet weak var routeStepsWalkedLabel: UILabel!
    @IBOutlet weak var routeTimeElapsedLabel: UILabel!
    
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    
    var switchViewDelegate : SwitchViewDelegate?

    var isPaused: Bool = false
    
    var walkStart : Date?

    
//MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        routeNameLabel.text = route?.routeName
    }

    
    
//MARK: - Actions
    @IBAction func onPause(_ sender: Any) {
        if (isPaused == true) {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
            isPaused = false
            pauseButton.setTitle("Pause", for: .normal)
            pauseButton.backgroundColor = UIColor.lightGray
        }
        else if (isPaused == false) {
            timer.invalidate()
            isPaused = true
            pauseButton.setTitle("Resume", for: .normal)
            pauseButton.backgroundColor = UIColor.systemBlue
        }
        switchViewDelegate?.pauseTimer(sender: self)
    }
    
    
    @IBAction func onStop(_ sender: Any) {
        onPause(self)
        
        //Warn the user first since it's not reversible
        let alert = UIAlertController(title: "Stop Timer?", message: "Are you sure you would like to stop the Timer?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
                    //unpause
                    self.onPause(self)
                }))
                
        alert.addAction(UIAlertAction(title: "Stop Timer", style: .destructive, handler: { (_) in
                    //Stop the timer
                    self.timer.invalidate()
                    self.routeTimeElapsedLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
                    self.timerCounting = false
            
                    //Delegate call
                    self.switchViewDelegate?.stopTimer(sender: self)
                    self.count = 0
                    return
                }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
//MARK: - SwitchViewDelegate Methods
    func stopTimer(sender: Any?) -> Bool {
        //No implementation here
        return true
    }
    
    
    func pauseTimer(sender: Any?) {
        //No implementation here
    }
    
    
    func switchView(sender: Any?) -> Bool {
        //No implementation here
        return true
    }
    
    
    func startTimer(sender: Any?) -> Bool {
        //Starts the timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        
        //Initialize it with the current date.
        walkStart = Date()
        
        if let sender = sender as? StartRouteViewController {
            routeLength = sender.routeLength
        }
        if CMPedometer.authorizationStatus() == .authorized {
        //Starts Pedometer
            if CMPedometer.isStepCountingAvailable() && CMPedometer.isDistanceAvailable() {
             
                pedometer.startUpdates(from: Date(), withHandler: {(data,error) in
                    if error == nil {
                        if let data = data {
                                //Updates the labels
                                self.numberOfSteps = Int(truncating: data.numberOfSteps)
                                if let distance = data.distance {
                                    self.distance = Double(truncating: distance)/1000 // in kilometres
                                    
                                }
                            }
                        }
                        else {
                            print("Pedometer Error: \(String(describing: error))")
                            }
                    })
            }
        }
        else if CMPedometer.authorizationStatus() == .denied {
            //Sends a warning.
            displayMessage(title: "Motion Usage is Needed for this Application.", message: "It is not possible to record steps counted or distance walked without it. This may this feature from working properly.")
        }
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)


        return true
        
      
    }
    
    
    //Called when app is moved to the background
    @objc func appMovedToBackground() {
        print("App moved to background!")
        //Saves the current time before app moves to background.
        currentBackgroundDate = Date()
        onPause(self)
    }
    
    
    //Called when app is back active.
    @objc func appBecomeActive() {
        print("App moved to foreground!")
        if let currentBackgroundDate = currentBackgroundDate {
            //Sets timer to current date, since when app was in background it did not increment the time.
            let difference = Date().timeIntervalSince(currentBackgroundDate)
            count += Int(round(difference))
            timerCounter()
            onPause(self)
        }
    }

    
    //Called every second, to increment the counter of the timer.
    @objc func timerCounter() -> Void {
        //Incrementing count
        count = count + 1
        
        //Updating labels
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        routeTimeElapsedLabel.text = timeString
    
    
        routeStepsWalkedLabel.text = String(numberOfSteps)
        if let routeLength = routeLength {
            //To round a double to several decimal places:
            //https://stackoverflow.com/questions/27338573/rounding-a-double-value-to-x-number-of-decimal-places-in-swift
            routeCurrentDistanceLabel.text = String("\(round(1000*distance)/1000)/\(routeLength) km")
        }
    }
        
    
    //Converts seconds to hours , minutes and seconds.
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int)
    {
        return ((seconds / 3600), ((seconds % 3600) / 60),((seconds % 3600) % 60))
    }
      
    
    //Converts the hours, minutes, and seconds into a string.
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
    
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

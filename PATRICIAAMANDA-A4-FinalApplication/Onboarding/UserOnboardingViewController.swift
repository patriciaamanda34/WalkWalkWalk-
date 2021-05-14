//
//  UserOnboardingViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/5/21.
//

import UIKit
//import CoreData
import BackgroundTasks

class UserOnboardingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var datePicker: UIDatePicker!
    var user: User?
    
    @IBOutlet weak var nameTextField: UITextField!
   // @IBOutlet weak var dayTextField: UITextField!
   // @IBOutlet weak var monthTextField: UITextField!
   // @IBOutlet weak var yearTextField: UITextField!
    
   // @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
  
    
    weak var databaseController : DatabaseProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
//        dayTextField.delegate = self
 //       monthTextField.delegate = self
  //      yearTextField.delegate = self
        
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "PATRICIAAMANDA-A4-FinalApplication_CheckUser", using: nil) { task in
             self.handleAppCheckUser(task: task as! BGAppRefreshTask)
        }
        
    }
    
    func handleAppCheckUser(task: BGAppRefreshTask) {
       // Schedule a new refresh task
       scheduleAppCheckUser()

       // Create an operation that performs the main part of the background task
       let operation = CheckUserDailySteps()
        
       /*
       // Provide an expiration handler for the background task
       // that cancels the operation
       task.expirationHandler = {
          operation.cancel()
       }

       // Inform the system that the background task is complete
       // when the operation completes
       operation.completionBlock = {
          task.setTaskCompleted(success: !operation.isCancelled)
       }

       // Start the operation
       operationQueue.addOperation(operation)*/
     }
    
    func scheduleAppCheckUser() {
       let request = BGAppRefreshTaskRequest(identifier: "PATRICIAAMANDA-A4-FinalApplication_CheckUser")
       // Fetch no earlier than 15 minutes from now
       request.earliestBeginDate = Date(timeIntervalSinceNow: 24 * 60) //24 mins pls dont forget to x60 this pat

        do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
  /*  @IBAction func editingDidEnd(_ sender: UIDatePicker) {
        
       // datePicker.getValue
    }*/
    
    func CheckUserDailySteps(){
        user = databaseController?.fetchUser()
        
        if(user?.userDailySteps ?? 0 < user?.userDailyStepsQuota ?? 0) {
            //push the notif
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        user = databaseController?.fetchUser()
        //print(user?.userName)
        
        if user != nil {
            //print(user?.userName)
            nameTextField?.text = user?.userName
            datePicker.date = user?.userDateOfBirth ?? Date()
            DispatchQueue.main.async {
                
            self.performSegue(withIdentifier: "onboardingDoneSegue", sender: nil)
            
            }
            //  let viewController = HomeMapViewController()
           // self.present(viewController,animated:true,completion:nil)
        }
        
        //Keyboard
     /*   NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
      */
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "onboardingDoneSegue" {
            if(nameTextField.text == "") {
                displayMessage(title: "Warning", message: "Name cannot be empty.")
                
                return
            }
            if user == nil {
                
                
           // let DOB =  datePicker.date
              //  print(DOB.description)

         //  let dateFormatter = DateFormatter()
              //  dateFormatter.dateFormat = "dd-MM-yyyy"
                
           // let test =  dateFormatter.string(from: datePicker.date)

              // print(dateFormatter.string(from: DOB))
            
            let name = nameTextField.text ?? ""
       //     let day = dayTextField.text!
      //      let month = monthTextField.text!
        //    let year = yearTextField.text!
           // let dob = "\(day)-\(month)-\(year)"
            databaseController?.addUser(name: name, dateOfBirth: datePicker.date)
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.saveContext()
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
    
    
    // MARK: - Handling keyboard

   /* @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo, let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            bottomConstraint.constant = keyboardSize.cgRectValue.height
        }
     }

    @objc func keyboardWillHide(notification: NSNotification) {
        bottomConstraint.constant = 0
    }

*/
}

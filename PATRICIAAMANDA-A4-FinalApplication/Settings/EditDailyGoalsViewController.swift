//
//  EditDailyGoalsViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import UIKit

class EditDailyGoalsViewController: UIViewController {
    
//MARK: - Variables
    @IBOutlet weak var dailyGoalsTextField: UITextField!
   
    weak var profileChangeDelegate: ProfileChangeDelegate?
    
    var user : User?
    
    
//MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dailyGoalsTextField.text = String(user?.userDailySteps ?? 0)
    }
    
    
//MARK: -Actions
    @IBAction func saveChanges(_ sender: UIButton) {
        //Error checking
        if(dailyGoalsTextField.text == "") {
            displayMessage(title: "Warning", message: "Daily Goals cannot be empty.")
            return
        }
        
        
        if let profileChangeDelegate = profileChangeDelegate {
            let dailySteps = Int(dailyGoalsTextField.text ?? "") ?? 0
            if (profileChangeDelegate.saveDailyStepsChanges(dailySteps)) {
                navigationController?.popViewController(animated: true)
            }
        }
    }
    

    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

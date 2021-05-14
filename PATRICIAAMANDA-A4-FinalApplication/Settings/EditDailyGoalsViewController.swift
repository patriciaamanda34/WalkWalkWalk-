//
//  EditDailyGoalsViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/7/21.
//

import UIKit

class EditDailyGoalsViewController: UIViewController {
    @IBOutlet weak var dailyGoalsTextField: UITextField!
    weak var profileChangeDelegate: ProfileChangeDelegate?
    
    var user : User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        dailyGoalsTextField.text = String(user?.userDailySteps ?? 0)
        
    }
    
    @IBAction func saveChanges(_ sender: UIButton) {
        if(dailyGoalsTextField.text == "") {
            displayMessage(title: "Warning", message: "Daily Goals cannot be empty.")
            
            return
        }
        
        
        if let profileChangeDelegate = profileChangeDelegate {
            let dailySteps = Int(dailyGoalsTextField.text ?? "") ?? 0
            if(profileChangeDelegate.saveDailyStepsChanges(dailySteps)) {
                navigationController?.popViewController(animated: true)
            }
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
         handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
}

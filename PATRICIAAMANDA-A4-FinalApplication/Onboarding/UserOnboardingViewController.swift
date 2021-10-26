//
//  UserOnboardingViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 5/5/21.
//

import UIKit

//Onboarding View Controller - only runs during first time user launches the app.
class UserOnboardingViewController: UIViewController, UITextFieldDelegate {

    //MARK: - Variables
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!

    var user: User?
    
    weak var databaseController : DatabaseProtocol?
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
    }
          
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        user = databaseController?.fetchUser()
        
        //If user exists, skip this view and perform segue.
        if user != nil {
            nameTextField?.text = user?.userName
            datePicker.date = user?.userDateOfBirth ?? Date()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "onboardingDoneSegue", sender: nil)
            }
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "onboardingDoneSegue" {
            //Error checking
            if(nameTextField.text == "") {
                displayMessage(title: "Warning", message: "Name cannot be empty.")
                return
            }
            if user == nil {
                let name = nameTextField.text ?? ""
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
}

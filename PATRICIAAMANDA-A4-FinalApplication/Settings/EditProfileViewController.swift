//
//  EditProfileViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//

import UIKit

class EditProfileViewController: UIViewController {
    
//MARK: - Variables
    weak var profileChangeDelegate: ProfileChangeDelegate?
    
    var user : User?
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameTextField.text = user?.userName
        
        datePicker.date = user?.userDateOfBirth ?? Date()
    }
    

//MARK: - Actions
    @IBAction func saveChanges(_ sender: Any) {
        if(nameTextField.text == "") {
            displayMessage(title: "Warning", message: "Name cannot be empty.")
            return
        }
        user?.userName = nameTextField.text
        user?.userDateOfBirth = datePicker.date
      
        if let user = user, let profileChangeDelegate = profileChangeDelegate {
            if (profileChangeDelegate.saveProfileChanges(user)) {
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

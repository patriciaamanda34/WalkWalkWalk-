//
//  SettingsTableViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//

import UIKit

class SettingsTableViewController: UITableViewController, ProfileChangeDelegate {
    // MARK: - ProfileChangeDelegate methods

    func saveProfileChanges(_ newUser: User) -> Bool {
        user = newUser
        tableView.reloadData()
        return true
    }
    
    func saveDailyStepsChanges(_ dailySteps: Int) -> Bool {
        user?.userDailySteps = Int16(dailySteps)
        tableView.reloadData()
        return true
    }
    
    let SECTION_EDITPROFILE = 0
    let SECTION_DAILYGOALS = 1
    let SECTION_NOTIFICATIONS = 2
    let SECTION_HELP = 3
    let SECTION_ABOUT = 4
    
    let CELL_EDITPROFILE = "editProfileCell"
    let CELL_DAILYGOALS = "dailyGoalsCell"
    let CELL_NOTIFICATIONS = "notificationsCell"
    let CELL_HELP = "helpCell"
    let CELL_ABOUT = "aboutCell"
    
    var user: User?
    weak var databaseController: DatabaseProtocol?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        user = databaseController?.fetchUser()
        
     //   print(user?.userName)
        
     
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        databaseController?.cleanup()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
       
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        switch section {
            case SECTION_EDITPROFILE:
                return 2
            case SECTION_DAILYGOALS:
                return 1
            case SECTION_NOTIFICATIONS:
                return 1
            case SECTION_HELP:
                return 1
            case SECTION_ABOUT:
                return 1
            default:
                return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_EDITPROFILE {
            let editProfileCell = tableView.dequeueReusableCell(withIdentifier: CELL_EDITPROFILE, for: indexPath)
            editProfileCell.accessoryType = .none
            if (indexPath.row == 0){
                editProfileCell.textLabel?.text = "Name"
                editProfileCell.detailTextLabel?.text = user?.userName
            }
            else if(indexPath.row == 1){
                editProfileCell.textLabel?.text = "Date of Birth"
                  let dateFormatter = DateFormatter()
                  dateFormatter.dateFormat = "dd-MM-yyyy"
                       
                let date =  dateFormatter.string(from: (user?.userDateOfBirth)!)

                 
                editProfileCell.detailTextLabel?.text = date
            }
            return editProfileCell
            
        }
        else if indexPath.section == SECTION_DAILYGOALS {
            let dailyGoalsCell = tableView.dequeueReusableCell(withIdentifier: CELL_DAILYGOALS, for: indexPath)
            
            dailyGoalsCell.textLabel?.text = "Number of Steps Taken"
            dailyGoalsCell.detailTextLabel?.text = String(user?.userDailySteps ?? 0)
            return dailyGoalsCell
        }
        else if indexPath.section == SECTION_NOTIFICATIONS {
            let notificationsCell = tableView.dequeueReusableCell(withIdentifier: CELL_NOTIFICATIONS, for: indexPath) as! NotificationsTableViewCell
            notificationsCell.accessoryType = .none
            notificationsCell.notificationLabel.text = "Push Notifications"
            return notificationsCell
        }
        else if indexPath.section == SECTION_HELP {
            let helpCell = tableView.dequeueReusableCell(withIdentifier: CELL_HELP, for: indexPath)
            helpCell.textLabel?.text = "Help"
            return helpCell
        }
        let aboutCell = tableView.dequeueReusableCell(withIdentifier: CELL_ABOUT, for: indexPath)

        aboutCell.textLabel?.text = "About"
            return aboutCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_EDITPROFILE {
            return "Profile"
        }
        else if section == SECTION_DAILYGOALS {
            return "Daily Goals"
        }
        else if section == SECTION_NOTIFICATIONS {
            return "Notifications"
        }
        else if section == SECTION_HELP {
            return "Help"
        }
        else if section == SECTION_ABOUT {
            return "About"
        }
        return nil
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "editProfileSegue") {
            let destination = segue.destination as! EditProfileViewController
            destination.user = user
            destination.profileChangeDelegate = self
        }
        else if(segue.identifier == "editDailyGoalsSegue"){
            let destination = segue.destination as! EditDailyGoalsViewController
            destination.user = user
            destination.profileChangeDelegate = self
        }
    }
    

}

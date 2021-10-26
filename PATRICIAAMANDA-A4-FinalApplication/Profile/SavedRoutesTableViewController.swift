//
//  SavedRoutesTableViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/30/21.
//

import UIKit

class SavedRoutesTableViewController: UITableViewController, DatabaseListener {
    
//MARK: - Variables
    var listenerType: ListenerType = .savedRoute
    weak var databaseController : DatabaseProtocol?
    var currentSavedRoutes: [SavedRoute]?

    
    //MARK: - DatabaseListener Methods
    func onRouteChange(change: DatabaseChange, routes: [Route]) {
        //Do nothing
    }
    
    func onWalkStatsChange(change: DatabaseChange, walkStats: [WalkStats]) {
        //Do nothing
    }
    
    func onSavedRouteChange(change: DatabaseChange, savedRoutes: [SavedRoute]) {
        currentSavedRoutes = savedRoutes
        tableView.reloadData()
    }
    

//MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }

    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return currentSavedRoutes?.count ?? 0

        }
        else if section == 1 {
            return 1
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "savedRoutesCell", for: indexPath)
    
            if let savedRoutes = currentSavedRoutes {
                cell.textLabel?.text = savedRoutes[indexPath.row].savedRouteName
            }
          
        }
        else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "savedRoutesCountCell", for: indexPath)
            if let count = currentSavedRoutes?.count {
                //Display the number of saved routes if there's more than 0.
                if count > 0 {
                cell.textLabel?.text = "There are \(count) session(s) saved."
                }
                //Otherwise, display this message.
                else {
                cell.textLabel?.text = "No saved sessions have been added yet. Click on a route in 'My Routes' to start one."
                cell.accessoryType = .none
                }
            }
        }
        return cell
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentSavedRoutes?.count == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let name = currentSavedRoutes?[indexPath.row].savedRouteName {
                //Put a warning out first.
                let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(String(describing: name))? This cannot be undone.", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel,
                 handler: nil))
                alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                    //Delete the row from core data
                    self.databaseController?.removeSavedRoute(savedRoute: self.currentSavedRoutes![indexPath.row])
                    self.currentSavedRoutes?.remove(at: indexPath.row)

                    //Update table
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.reloadSections([0,1], with: .automatic)
                }))
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if currentSavedRoutes?.count ?? 0 > 0 {
            if segue.identifier == "savedRouteDetailSegue" {
                let destination = segue.destination as! SavedRouteDetailViewController
                
                if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for:cell) {
                    destination.savedRoute = currentSavedRoutes?[indexPath.row]
                }
            }
        }
    }
}

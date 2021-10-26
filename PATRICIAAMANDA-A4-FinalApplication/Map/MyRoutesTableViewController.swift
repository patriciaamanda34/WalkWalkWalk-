//
//  MyRoutesTableViewController.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/22/21.
//

import UIKit

class MyRoutesTableViewController: UITableViewController {
   
    //MARK: - Variables
    
    //All the routes fetched from core data
    var routes : [Route]?
    
    weak var databaseController: DatabaseProtocol?

    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        //Setting initial values
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
       
        routes = databaseController?.fetchMyRoutes()
        tableView.reloadData()
    }
    
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return routes?.count ?? 0
            
        }
        else if section == 1 {
            return 1
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell = UITableViewCell()
        
        if indexPath.section == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "myRoutesCell", for: indexPath)
            //Configuring the cell...
            if let routes = routes {
                cell.textLabel?.text = routes[indexPath.row].routeName;
            }
        }
        else if indexPath.section == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "routeCountCell", for: indexPath)
            if let count = routes?.count {
                if count > 0 {
                    cell.textLabel?.text = "There are \(count) route(s) saved."
                }
                else {
                    //If there is nothing in routes, display this message instead.
                    cell.textLabel?.text = "No routes have been added yet. Click '+' on the top right corner to add one."
                }
            }
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if routes?.count == 0 {
            //Deselects the row so that the animation flows smoothly.
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == 0 {
            return true
        }
        return false
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Deleting a route
            if let name = routes?[indexPath.row].routeName {
                
            //Sending a warning first
            let alertController = UIAlertController(title: "Warning", message: "Are you sure you want to delete \(String(describing: name))? This will also delete the walk sessions associated to the route. This cannot be undone.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel,
             handler: nil))
            alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {_ in
                //Deleting the route in Core Data
                self.databaseController?.removeRoute(route: (self.routes?[indexPath.row])!)
                
                //Updating the table
                self.routes?.remove(at: indexPath.row)

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
        // Pass the selected object to the new view controller.
        if segue.identifier == "routeDetailSegue" {
            let destination = segue.destination as! RouteDetailViewController
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for:cell) {
                destination.route = routes?[indexPath.row]
            }
        }
        else if segue.identifier == "SelectRouteSegue"{
            let destination = segue.destination as! StartRouteViewController
            if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for:cell) {
                destination.route = routes?[indexPath.row]
            }            
        }
    }
}



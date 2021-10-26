//
//  SceneDelegate.swift
//  PATRICIAAMANDA-A4-FinalApplication
//
//  Created by Patricia Amanda on 4/21/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
       // print("sceneDidBecomeActive runs")
        
        //Checks if it's a different day or not, if it is, create a new WalkStasts for the user.
        //Comparing dates:
        //https://www.globalnerdy.com/2020/05/28/how-to-work-with-dates-and-times-in-swift-5-part-3-date-arithmetic/
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let user = appDelegate?.databaseController?.fetchUser() {
            var allStats = user.userStats?.allObjects
            if let stats = allStats?.last as? WalkStats {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                
                //if the day/month/year is different:
                if dateFormatter.string(from: stats.walkDateStart ?? Date()) != dateFormatter.string(from: Date()) {
                    let walkStatsNew = appDelegate?.databaseController?.createWalkStats()
                    walkStatsNew?.walkDateStart = Date()
                    user.addToUserStats(walkStatsNew!)
                    
                    if allStats!.count > 7 {
                        allStats?.remove(at: 0) //Removes the first one, only displays a max of 7.
                    }
                }
            }
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.databaseController?.cleanup()
        
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}


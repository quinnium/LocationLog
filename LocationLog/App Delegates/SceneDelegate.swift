//
//  SceneDelegate.swift
//  LocationLog
//
//  Created by Quinn on 30/08/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let myScene = (scene as? UIWindowScene) else { return }
        //window?.tintColor = Colors.LLPink
        if let shortcutItem = connectionOptions.shortcutItem {
            windowScene(myScene, performActionFor: shortcutItem) { _ in    
            }
        }
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
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        // Entered to 'refresh' the page when launching from a Quick Action taxk (so as to toggle the tracking switch correctly)
        
        // To force the MoreTableViewContorller to refresh when app enters foreground (to cover anyone toggling location Tracking /on/off via a Quick Action
        (((self.window?.rootViewController as? UITabBarController)?.viewControllers?[2] as? UINavigationController)?.viewControllers[0] as? MoreTableViewController)?.viewDidAppear(true)
        
        // Custom LL code
        LocationManager.shared.alertHistoryVCOfLog = true
        LocationManager.shared.delegate?.locationRecordsUpdated()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        
        // Custom LL code
        LocationManager.shared.alertHistoryVCOfLog = false
    }

    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        guard let tabBar = window?.rootViewController as? UITabBarController else {
            print("QLog: No UITabBarController!!")
            return
        }
        
        if shortcutItem.type == ShortcutsManager.ActionType.generateTrackingOffOption.rawValue {
            ShortcutsManager.handler(for: .generateTrackingOffOption, tabBar: tabBar)
            
        }
        else if shortcutItem.type == ShortcutsManager.ActionType.generateTrackingOnOption.rawValue {
            ShortcutsManager.handler(for: .generateTrackingOnOption, tabBar: tabBar)
            
            
        }
            
    }

}


//
//  AppDelegate.swift
//  TestPermissionsRequest
//
//  Created by Shaun on 7/21/20.
//  Copyright © 2020 Shaun Hurley. All rights reserved.
//

import UIKit
import SquareReaderSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window:UIWindow?
    var storyboard: UIStoryboard?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SQRDReaderSDK.initialize(applicationLaunchOptions: launchOptions)
        
        storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        let permissionsGranted = PermissionsViewController.areRequiredPermissionsGranted
        print("AppDelegate: are required permissions granted?", permissionsGranted)
//        let readerSDKAuthorized = SQRDReaderSDK.shared.isAuthorized

        if !permissionsGranted {
            print("AppDelegate: opening permissions view controller...")
            let permissionsViewController = storyboard?.instantiateViewController(withIdentifier: "PermissionsViewController") as! PermissionsViewController
            permissionsViewController.delegate = self
            self.window?.rootViewController = permissionsViewController
        }
        
        return true
    }

}

// MARK: - PermissionsViewControllerDelegate protocol delegate

extension AppDelegate: PermissionsViewControllerDelegate {
    
    func permissionsViewControllerDidObtainRequiredPermissions(_ permissionsViewController: PermissionsViewController){
        print("Permissions view controller delegate function called....")
        
        // Switch back to primary navigation view controller
        let navigationViewController = storyboard?.instantiateViewController(withIdentifier: "paymentsNavigationController") as! UINavigationController
        self.window?.rootViewController = navigationViewController
        
    }
    
}

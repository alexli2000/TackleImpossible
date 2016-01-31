//
//  AppDelegate.swift
//  TackleImpossible
//
//  Created by Alexander Li on 2016-01-30.
//  Copyright © 2016 Alexander Li. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?

    let locationManager = CLLocationManager()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Sound], categories: nil))
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        setSafeToDriveNotification()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        application.cancelAllLocalNotifications()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    //MARK: - CLLocation
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updated locations")
        guard let date =  NSUserDefaults.standardUserDefaults().objectForKey("safeToDriveDate") as? NSDate else {
            print("No date available")
            return
        }
        
        if date.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            print("Notification date has already past")
            return
        }
        
        let notification = UILocalNotification()
        notification.alertBody = "Hey are you sure you're ok to drive?"
        notification.regionTriggersOnce = true
        notification.region = CLCircularRegion(center: locations.last!.coordinate, radius: 5, identifier: "usersRegion")
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        print("updated location")
        guard let date =  NSUserDefaults.standardUserDefaults().objectForKey("safeToDriveDate") as? NSDate else {
            print("No date available")
            return
        }
        
        if date.compare(NSDate()) == NSComparisonResult.OrderedAscending {
            print("Notification date has already past")
            return
        }
        
        let notification = UILocalNotification()
        notification.alertBody = "Hey are you sure you're ok to drive?"
        notification.regionTriggersOnce = true
        notification.region = CLCircularRegion(center: newLocation.coordinate, radius: 5, identifier: "usersRegion")
        notification.soundName = "Default"
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
    
}


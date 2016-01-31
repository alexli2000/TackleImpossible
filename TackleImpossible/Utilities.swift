//
//  Utilities.swift
//  TackleImpossible
//
//  Created by Alexander Li on 2016-01-30.
//  Copyright © 2016 Alexander Li. All rights reserved.
//

import UIKit

let minimumSafePercentOfAlcohol:Float = 0.04

let green = UIColor(red: 0.52, green: 0.63, blue: 0.45, alpha: 1)
let yellow = UIColor(red: 0.9, green: 0.84, blue: 0.46, alpha: 1)
let red = UIColor(red: 0.86, green: 0.28, blue: 0.28, alpha: 1)
let beerColor = UIColor(red: 0.78, green: 0.53, blue: 0.16, alpha: 1)

func hoursToRidBodyOfAlcohol(bac:Float) -> Float {
    return bac/0.015
}

func hoursToReachDrivingLimitOfAlcohol(bac:Float) -> Float {
    return (bac - minimumSafePercentOfAlcohol)/0.015
}

func stringOfTimeUntilRidOfAlcohol(time:Float) -> NSMutableAttributedString {
    
    
    let firstString = NSMutableAttributedString(string: "YOU'RE ", attributes: [NSForegroundColorAttributeName:UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1)])
    
    if time < 0 {
        firstString.appendAttributedString(NSMutableAttributedString(string: "OK", attributes: [NSForegroundColorAttributeName:green]))
    } else {
        firstString.appendAttributedString(NSMutableAttributedString(string: "NOT OK", attributes: [NSForegroundColorAttributeName:red]))
    }
    
    firstString.appendAttributedString(NSMutableAttributedString(string: " TO DRIVE", attributes: [NSForegroundColorAttributeName:UIColor(red: 0.38, green: 0.38, blue: 0.38, alpha: 1)]))
    
    if time > 0 {
        print(time)
    let hours = floor(time)
    let mins = (time - hours)*60
    
    firstString.appendAttributedString(NSAttributedString(string: "\nWAIT \(Int(hours)) hours \(Int(mins)) mins", attributes: [NSForegroundColorAttributeName:red]))
    }
    return firstString
}

func stringOfBAC(bac:Float) -> String {
    return(String(format: "%.2f", bac))
}

func replaceSafeToDriveDate(hours:Float) {
    let comps = NSDateComponents()
    comps.hour = Int(floor(hours))
    comps.minute = Int(hours*60) - comps.hour*60
    
    let date = NSCalendar.currentCalendar().dateByAddingComponents(comps, toDate: NSDate(), options: .MatchFirst)
    
    NSUserDefaults.standardUserDefaults().setObject(date, forKey: "safeToDriveDate")
}

func setSafeToDriveNotification() {
    
    guard let date =  NSUserDefaults.standardUserDefaults().objectForKey("safeToDriveDate") as? NSDate else {
        print("No date available")
        return
    }
    
    if date.compare(NSDate()) == NSComparisonResult.OrderedAscending {
        print("Notification date has already past")
        return
    }
    
    let notification = UILocalNotification()
    notification.alertBody = "You should be good to drive! Come check again." // text that will be displayed in the notification
    notification.alertAction = "Check"
    notification.fireDate = date
    notification.soundName = UILocalNotificationDefaultSoundName
    UIApplication.sharedApplication().scheduleLocalNotification(notification)
    
    print("Notification set for \(notification.fireDate)")
    print(UIApplication.sharedApplication().scheduledLocalNotifications?.count)
}

func setLeavingPremiseNotification() {
    
}

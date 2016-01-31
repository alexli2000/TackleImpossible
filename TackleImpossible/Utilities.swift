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

func hoursToRidBodyOfAlcohol(bac:Float, addedDrinks:Int) -> Float {
    let refactoredBAC = bac + additionalBACPerDrinkUnit() * Float(addedDrinks)
    return refactoredBAC/0.015
}

func hoursToReachDrivingLimitOfAlcohol(bac:Float, addedDrinks:Int) -> Float {
    let refactoredBAC = bac + additionalBACPerDrinkUnit() * Float(addedDrinks)
    return (refactoredBAC - minimumSafePercentOfAlcohol)/0.015
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

func stringOfBAC(bac:Float, addedDrinks:Int) -> String {
    let refactoredBAC = bac + additionalBACPerDrinkUnit() * Float(addedDrinks)
    
    return(String(format: "%.2f", refactoredBAC))
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
}

func getBACFromTimeUntilSafeToDrive(hours:Float) -> Float {
    return hours * 0.015
}

func getCurrentBAC() -> Float {
    guard let date =  NSUserDefaults.standardUserDefaults().objectForKey("safeToDriveDate") as? NSDate else {
        print("No date available")
        return 0
    }
    
    if date.compare(NSDate()) == NSComparisonResult.OrderedAscending {
        print("Notification date has already past")
        return 0
    }

    return getBACFromTimeUntilSafeToDrive(Float(date.timeIntervalSinceDate(NSDate())) * 60.0 * 60.0)
}

func additionalBACPerDrinkUnit() -> Float {
    return calculateBACForCurrentUser(1, hoursSinceCommencement: 0)
}

func calculateBACForCurrentUser(numberOfDrinks:Int, hoursSinceCommencement:Float) -> Float {
    
    if NSUserDefaults.standardUserDefaults().floatForKey("userWeight") < 10 {
        NSUserDefaults.standardUserDefaults().setObject(50, forKey: "userWeight")
    }
    
    if NSUserDefaults.standardUserDefaults().objectForKey("weightUnits") == nil {
        NSUserDefaults.standardUserDefaults().setObject("kg", forKey: "weightUnits")
    }
    
    return calculateBACForIndividualWith(NSUserDefaults.standardUserDefaults().boolForKey("userGender"), numberOfDrinks: numberOfDrinks, hoursSinceCommencement: hoursSinceCommencement, weightInKG: NSUserDefaults.standardUserDefaults().floatForKey("userWeight"))
}

func calculateBACForIndividualWith(male:Bool, numberOfDrinks:Int, hoursSinceCommencement:Float, weightInKG:Float) -> Float {
    if male {
        return (Float(10*numberOfDrinks) - 7.5*hoursSinceCommencement)/(6.8*weightInKG)
    } else {
        return (Float(10*numberOfDrinks) - 7.5*hoursSinceCommencement)/(5.5*weightInKG)
    }
}


func usersWeightInKG() -> Float? {
    if let units = NSUserDefaults.standardUserDefaults().objectForKey("weightUnits") as? String {
        if units == "kg" {
            return NSUserDefaults.standardUserDefaults().floatForKey("userWeight")
        } else if units == "lb" {
            return NSUserDefaults.standardUserDefaults().floatForKey("userWeight")*0.453592
        } else if units == "st" {
            return NSUserDefaults.standardUserDefaults().floatForKey("userWeight")*6.35029
        } else {
            print("Could not determine wegiht units")
            return nil
        }
    } else {
        print("No units set!")
        return nil
    }
}



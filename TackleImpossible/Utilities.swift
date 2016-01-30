//
//  Utilities.swift
//  TackleImpossible
//
//  Created by Alexander Li on 2016-01-30.
//  Copyright © 2016 Alexander Li. All rights reserved.
//

import UIKit

let minimumSafePercentOfAlcohol:Float = 0.04

func hoursToRidBodyOfAlcohol(bac:Float) -> Float {
    return bac/0.015
}

func hoursToReachDrivingLimitOfAlcohol(bac:Float) -> Float {
    return (bac - minimumSafePercentOfAlcohol)/0.015
}

func stringOfTimeUntilRidOfAlcohol(time:Float) -> String {
    
    let hours = time % 1
    let mins = (time - hours)*60
    
    return "\(Int(hours)) hours \(Int(mins)) mins"
}

func stringOfBAC(bac:Double) -> String {
    return(String(format: "%.2f", bac))
}
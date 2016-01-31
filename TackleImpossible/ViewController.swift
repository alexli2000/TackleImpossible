//
//  ViewController.swift
//  TackleImpossible
//
//  Created by Alexander Li on 2016-01-30.
//  Copyright © 2016 Alexander Li. All rights reserved.
//

import UIKit
import MessageUI
import HealthKit

class ViewController: UIViewController, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {

    let radius = 3*UIScreen.mainScreen().bounds.width/10
    let buffer = UIScreen.mainScreen().bounds.width/4
    
    var bac:Float?
    
    let path = PocketSVG.pathFromSVGFileNamed("beer120").takeUnretainedValue()
    var loader = FillableLoader()
    var progressCircle = CAShapeLayer()

    
    var addedDrinks = 0
    
    let healthKitStore:HKHealthStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        bac = 0.09
        presentLoader()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func configureViews() {
        configureBACBackground()
        configureSettingsButton()
        configureBACProgress()
        configureAlternativeButtons()
        replaceSafeToDriveDate(hoursToReachDrivingLimitOfAlcohol(bac!, addedDrinks: addedDrinks))
        configureAddDrinkButton()
    }
    
    func configureBACBackground() {
        
        let circle = CAShapeLayer()
        
        let path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 2*radius, height: 2*radius))
        
        circle.path = path.CGPath
        circle.position = CGPoint(x: CGRectGetMidX(self.view.frame) - radius, y: buffer)
        
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
        circle.lineCap = "round"
        circle.lineWidth = 10
        
        self.view.layer.addSublayer(circle)
        
        let circle2 = CAShapeLayer()
        circle2.path = UIBezierPath(ovalInRect: CGRect(x: 5, y: 5, width: 2*radius-10, height: 2*radius-10)).CGPath
        circle2.position = CGPoint(x: CGRectGetMidX(self.view.frame) - radius, y: buffer)
        
        circle2.fillColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1).CGColor
        circle2.strokeColor = UIColor.clearColor().CGColor
        circle2.lineCap = "round"
        circle2.lineWidth = 10
        
        self.view.layer.addSublayer(circle2)
    }
    
    func configureSettingsButton() {
        let settingsButton = UIButton()
        settingsButton.setImage(UIImage(named: "settings"), forState: .Normal)
        settingsButton.addTarget(self, action: "pushToSettings", forControlEvents: .TouchUpInside)
        settingsButton.center = CGPoint(x: UIScreen.mainScreen().bounds.width - buffer/2, y: buffer/2)
        view.addSubview(settingsButton)
    }
    
    func configureBACProgress() {
        let path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 2*radius, height: 2*radius))
        
        let bounds = CGPathGetBoundingBox(path.CGPath)
        let center = CGPoint(x:CGRectGetMidX(bounds), y:CGRectGetMidY(bounds))
        
        let toOrigin = CGAffineTransformMakeTranslation(-center.x, -center.y)
        path.applyTransform(toOrigin)
        
        let rotation = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        path.applyTransform(rotation)
        
        let fromOrigin = CGAffineTransformMakeTranslation(center.x, center.y)
        path.applyTransform(fromOrigin)
        
        progressCircle.path = path.CGPath
        progressCircle.position = CGPoint(x: CGRectGetMidX(self.view.frame) - radius, y: buffer)
        
        progressCircle.fillColor = UIColor.clearColor().CGColor
        progressCircle.strokeColor = circleColorFromBAC().CGColor
        progressCircle.lineCap = "round"
        progressCircle.lineWidth = 10
        progressCircle.strokeEnd = CGFloat(circleEndFromBAC())
        
        self.view.layer.addSublayer(progressCircle)
        let circleAnim = CABasicAnimation(keyPath: "strokeEnd")
        circleAnim.duration = 1.5
        circleAnim.repeatCount = 1
        
        circleAnim.fromValue = 0
        circleAnim.toValue = circleEndFromBAC()
        
        circleAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        let circleColorAnim = CABasicAnimation(keyPath: "strokeColor")
        circleColorAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        circleColorAnim.duration = 2
        circleAnim.repeatCount = 1
        circleAnim.delegate = self
        circleColorAnim.fromValue = green.CGColor
        circleColorAnim.toValue = circleColorFromBAC().CGColor
        
        progressCircle.addAnimation(circleAnim, forKey: "drawCircleAnimation")
        progressCircle.addAnimation(circleColorAnim, forKey: "colorCircleAnimation")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        configureBACLabel()
        configureCarLabel()
    }
    
    func configureBACLabel() {
        if let currentView = view.viewWithTag(3) {
            currentView.removeFromSuperview()
        }
        let bacLabel = SpringLabel()
        bacLabel.text = stringOfBAC(bac!, addedDrinks: addedDrinks) + "%"
        bacLabel.textColor = circleColorFromBAC()
        bacLabel.font = UIFont.systemFontOfSize(36)
        bacLabel.sizeToFit()
        bacLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: buffer + radius)
        bacLabel.tag = 3
        view.addSubview(bacLabel)
        
        bacLabel.animation = "pop"
        bacLabel.duration = 1
        bacLabel.curve = "spring"
        bacLabel.animate()
    }
    
    func configureAddDrinkButton() {
        let addDrinkButton = SpringButton()
        let addDrinkImage = UIImage(named: "addDrink")
        addDrinkButton.setImage(addDrinkImage, forState: .Normal)
        //addDrinkButton.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
        addDrinkButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
//        addDrinkButton.layer.cornerRadius = 20
//        addDrinkButton.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
//        addDrinkButton.layer.shadowRadius = 3
//        addDrinkButton.layer.shadowOpacity = 0.5
//        addDrinkButton.layer.shadowOffset = CGSize(width: 3, height: 3)
        addDrinkButton.center = CGPoint(x: buffer/3, y: buffer + 2*radius/3)
        view.addSubview(addDrinkButton)
        
        addDrinkButton.addTarget(self, action: "addNewDrink", forControlEvents: .TouchUpInside)
        
        addDrinkButton.animation = "fadeIn"
        addDrinkButton.duration = 1
        addDrinkButton.curve = "spring"
        addDrinkButton.animate()
    }
    
    func configureRefreshButton() {
        if let currentView = view.viewWithTag(4) {
            currentView.removeFromSuperview()
        }
        
        if addedDrinks > 0 {
            let addDrinkButton = SpringButton()
            let addDrinkImage = UIImage(named: "refresh")
            addDrinkButton.setImage(addDrinkImage, forState: .Normal)
            //addDrinkButton.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
            addDrinkButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            //        addDrinkButton.layer.cornerRadius = 20
            //        addDrinkButton.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
            //        addDrinkButton.layer.shadowRadius = 3
            //        addDrinkButton.layer.shadowOpacity = 0.5
            //        addDrinkButton.layer.shadowOffset = CGSize(width: 3, height: 3)
            addDrinkButton.center = CGPoint(x: buffer/3, y: buffer + 4*radius/3)
            addDrinkButton.tag = 4
            view.addSubview(addDrinkButton)
            
            addDrinkButton.addTarget(self, action: "removeAllDrinks", forControlEvents: .TouchUpInside)
            
            addDrinkButton.animation = "fadeIn"
            addDrinkButton.duration = 1
            addDrinkButton.curve = "spring"
            addDrinkButton.animate()
        }
    }
    
    func addNewDrink() {
        addedDrinks++
        removeAnimatingViews()
        configureBACProgress()
        configureRefreshButton()
    }
    
    func removeAllDrinks() {
        addedDrinks = 0
        removeAnimatingViews()
        configureBACProgress()
        configureRefreshButton()
    }
    
    func configureAlternativeButtons() {
        
        let lineView = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 4*UIScreen.mainScreen().bounds.width/5, height: 1)))
        lineView.backgroundColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        lineView.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: UIScreen.mainScreen().bounds.height - 100)
        view.addSubview(lineView)
        
        let alternatives = ["message", "uber", "taxi"]
        for idx in 0..<alternatives.count {
            let altButton = SpringButton()
            let altImage = UIImage(named: alternatives[idx])
            altButton.setImage(altImage, forState: .Normal)
            altButton.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1)
            altButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            altButton.layer.cornerRadius = 20
            altButton.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
            altButton.layer.shadowRadius = 3
            altButton.layer.shadowOpacity = 0.5
            altButton.layer.shadowOffset = CGSize(width: 3, height: 3)
            altButton.center = CGPoint(x: CGFloat(2*idx + 1)*UIScreen.mainScreen().bounds.width/CGFloat(alternatives.count*2), y: UIScreen.mainScreen().bounds.height - 55)
            view.addSubview(altButton)
            
            switch alternatives[idx] {
                case "message":
                altButton.addTarget(self, action: "openSMS", forControlEvents: .TouchUpInside)
                case "uber":
                altButton.addTarget(self, action: "openUber", forControlEvents: .TouchUpInside)
                case "taxi":
                altButton.addTarget(self, action: "openPhoneToTaxi", forControlEvents: .TouchUpInside)
            default:
                break
            }
            
            altButton.animation = "pop"
            altButton.duration = 1
            altButton.curve = "spring"
            altButton.animate()
            
        }
    }
    
    func configureCarLabel() {
        let carImageView = SpringImageView()
        if hoursToReachDrivingLimitOfAlcohol(Float(bac!), addedDrinks: addedDrinks) > 0 {
            carImageView.image = UIImage(named: "cab")
        } else {
            carImageView.image = UIImage(named: "car")
        }
        carImageView.sizeToFit()
        carImageView.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: 7*UIScreen.mainScreen().bounds.height/12)
        carImageView.tag = 5
        view.addSubview(carImageView)
        
        carImageView.animation = "slideRight"
        carImageView.curve = "easeOut"
        carImageView.duration = 2
        carImageView.animate()
        
        let carLabel = SpringLabel()
        carLabel.attributedText = stringOfTimeUntilRidOfAlcohol(hoursToReachDrivingLimitOfAlcohol(Float(bac!), addedDrinks: addedDrinks))
        carLabel.numberOfLines = 0
        carLabel.textAlignment = .Center
        carLabel.sizeToFit()
        carLabel.tag = 6
        carLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: 7*UIScreen.mainScreen().bounds.height/12 + 50)
        
        view.addSubview(carLabel)
        
    }
    
    func removeAnimatingViews() {
        if let currentView = view.viewWithTag(5) {
            currentView.removeFromSuperview()
        }
        
        if let currentView = view.viewWithTag(6) {
            currentView.removeFromSuperview()
        }
    }
    
    func circleEndFromBAC() -> Float {
        
        let refactoredBAC = bac! + additionalBACPerDrinkUnit() * Float(addedDrinks)
        
        guard refactoredBAC != 0 else {
            return 0
        }
        
        return refactoredBAC / 0.12
    }
    
    func circleColorFromBAC() -> UIColor {
        guard bac != nil else {
            return UIColor.clearColor()
        }
        let refactoredBAC = bac! + additionalBACPerDrinkUnit() * Float(addedDrinks)
        
        switch refactoredBAC {
        case 0...0.04:
            return green
        case 0.04...0.08:
            return yellow
        case 0.08..<1.0:
            return red
        default:
            print("Error setting color of circle")
            return red
        }
    }
    
    func openSMS() {
        print("did present")
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Hey. I don't think I can drive tonight. Can you give me a ride?"
        messageVC.messageComposeDelegate = self
        self.presentViewController(messageVC, animated: true, completion: nil)
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        print("did finish")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openUber() {
        let url  = NSURL(string: "uber://");
        if UIApplication.sharedApplication().canOpenURL(url!) == true
        {
            UIApplication.sharedApplication().openURL(url!)
        }
    }

    func openPhoneToTaxi() {
        let url  = NSURL(string: "tel://4167515555");
        if UIApplication.sharedApplication().canOpenURL(url!) == true
        {
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    func presentLoader() {
        loader = WavesLoader.showLoaderWithPath(path, onView: view)
        loader.loaderColor = beerColor
        loader.backgroundColor = UIColor.clearColor()
        loader.loaderStrokeColor = UIColor.clearColor()
        
        self.performSelector("cancelLoader", withObject: nil, afterDelay: 3.5)
        
    }
    
    func cancelLoader() {
        loader.removeLoader()
        configureViews()
    }

}

extension ViewController {
    /*
    func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        // 1. Set the types you want to read from HK Store
        let healthKitTypesToRead = Set(arrayLiteral:[
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierDateOfBirth),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBloodType),
            HKObjectType.characteristicTypeForIdentifier(HKCharacteristicTypeIdentifierBiologicalSex),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMass),
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeight),
            HKObjectType.workoutType()
            ])
        
        // 2. Set the types you want to write to HK Store
        let healthKitTypesToWrite = [HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierBodyMassIndex), HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierActiveEnergyBurned), HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierDistanceWalkingRunning), HKQuantityType.workoutType()]
        
        // 3. If the store is not available (for instance, iPad) return an error and don't go on.
        if !HKHealthStore.isHealthDataAvailable()
        {
            let error = NSError(domain: "com.raywenderlich.tutorials.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if( completion != nil )
            {
                completion(success:false, error:error)
            }
            return;
        }
        
        // 4.  Request HealthKit authorization
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: healthKitTypesToRead) { (success, error) -> Void in
            
            if( completion != nil )
            {
                completion(success:success,error:error)
            }
        }
    }
    
    healthManager.authorizeHealthKit { (authorized,  error) -> Void in
    if authorized {
    println("HealthKit authorization received.")
    }
    else
    {
    println("HealthKit authorization denied!")
    if error != nil {
    println("\(error)")
    }
    }
    }*/
}
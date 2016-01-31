//
//  ViewController.swift
//  TackleImpossible
//
//  Created by Alexander Li on 2016-01-30.
//  Copyright © 2016 Alexander Li. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController {

    let radius = 3*UIScreen.mainScreen().bounds.width/10
    let buffer = UIScreen.mainScreen().bounds.width/4
    
    var bac:Float?
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1)
        bac = 0.041
        configureBACBackground()
        configureBACProgress()
        configureAlternativeButtons()
        replaceSafeToDriveDate(hoursToReachDrivingLimitOfAlcohol(bac!))
    }
    
    func configureBACBackground() {
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 2*radius, height: 2*radius)).CGPath
        circle.position = CGPoint(x: CGRectGetMidX(self.view.frame) - radius, y: buffer)
        
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
        circle.lineCap = "round"
        circle.lineWidth = 10
        
        self.view.layer.addSublayer(circle)
        
        let circle2 = CAShapeLayer()
        circle2.path = UIBezierPath(ovalInRect: CGRect(x: 5, y: 5, width: 2*radius-10, height: 2*radius-10)).CGPath
        circle2.position = CGPoint(x: CGRectGetMidX(self.view.frame) - radius, y: buffer)
        
        circle2.fillColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1).CGColor
        circle2.strokeColor = UIColor.clearColor().CGColor
        circle2.lineCap = "round"
        circle2.lineWidth = 10
        
        self.view.layer.addSublayer(circle2)
    }
    
    func configureBACProgress() {
        let circle = CAShapeLayer()
        circle.path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 2*radius, height: 2*radius)).CGPath
        circle.position = CGPoint(x: CGRectGetMidX(self.view.frame) - radius, y: buffer)
        
//        circle.anchorPoint = CGPoint(x: circle.bounds.width/2, y: circle.bounds.height/2)
//        var transform = CATransform3DMakeRotation(CGFloat(M_PI_4), 0, 0, 1.0)
//        transform.m34 = 0.0015
//        circle.transform = transform
        
        circle.fillColor = UIColor.clearColor().CGColor
        circle.strokeColor = circleColorFromBAC().CGColor
        circle.lineCap = "round"
        circle.lineWidth = 10
        circle.strokeEnd = CGFloat(circleEndFromBAC())
        
        self.view.layer.addSublayer(circle)
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
        
        circle.addAnimation(circleAnim, forKey: "drawCircleAnimation")
        circle.addAnimation(circleColorAnim, forKey: "colorCircleAnimation")
    }
    
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        configureBACLabel()
        configureCarLabel()
    }
    
    func configureBACLabel() {
        let bacLabel = SpringLabel()
        bacLabel.text = stringOfBAC(bac!) + "%"
        bacLabel.textColor = circleColorFromBAC()
        bacLabel.font = UIFont.systemFontOfSize(36)
        bacLabel.sizeToFit()
        bacLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: buffer + radius)
        view.addSubview(bacLabel)
        
        bacLabel.animation = "pop"
        bacLabel.duration = 1
        bacLabel.curve = "spring"
        bacLabel.animate()
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
        if hoursToReachDrivingLimitOfAlcohol(Float(bac!)) > 0 {
            carImageView.image = UIImage(named: "cab")
        } else {
            carImageView.image = UIImage(named: "car")
        }
        carImageView.sizeToFit()
        carImageView.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: 7*UIScreen.mainScreen().bounds.height/12)
        view.addSubview(carImageView)
        
        carImageView.animation = "slideRight"
        carImageView.curve = "easeOut"
        carImageView.duration = 2
        carImageView.animate()
        
        let carLabel = SpringLabel()
        carLabel.attributedText = stringOfTimeUntilRidOfAlcohol(hoursToReachDrivingLimitOfAlcohol(Float(bac!)))
        carLabel.numberOfLines = 0
        carLabel.textAlignment = .Center
        carLabel.sizeToFit()
        carLabel.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: 7*UIScreen.mainScreen().bounds.height/12 + 50)
        
        view.addSubview(carLabel)
        
    }
    
    func circleEndFromBAC() -> Float {
        return bac! / 0.12
    }
    
    func circleColorFromBAC() -> UIColor {
        guard bac != nil else {
            return UIColor.clearColor()
        }
        
        switch bac! {
        case 0...0.04:
            return green
        case 0.04...0.08:
            return yellow
        case 0.08..<1.0:
            return red
        default:
            print("Error setting color of circle")
            return UIColor.clearColor()
        }
    }
    
    func openSMS() {
        let messageVC = MFMessageComposeViewController()
        messageVC.body = "Hey. I don't think I can drive tonight. Can you give me a ride?"
        self.presentViewController(messageVC, animated: true, completion: nil)
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

}


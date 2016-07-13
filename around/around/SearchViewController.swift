//
//  SearchViewController.swift
//  around
//
//  Created by Tom Wieschalla  on 20.06.16.
//  Copyright © 2016 Beuth. All rights reserved.
//

import UIKit
import CoreLocation

class SearchViewController: UIViewController,CLLocationManagerDelegate {
    
    var locManager: CLLocationManager?
    
    @IBOutlet weak var radarViewHolder: UIView!
    @IBOutlet weak var radarLine: UIView!
    
    var arcsView: Arcs?
    var radarView: Radar?
    var currentDeviceBearing: Float?
    var dots: NSMutableArray? = []
    var nearbyUsers: NSArray? = []
    var detectCollisionTimer: NSTimer?
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

        arcsView = Arcs.init(frame: CGRectMake(0, 0, 280, 280))
        arcsView!.layer.contentsScale = UIScreen.mainScreen().scale
        radarViewHolder.layer.contentsScale = UIScreen.mainScreen().scale
        radarViewHolder.addSubview(arcsView!)
        
        radarView = Radar.init(frame: CGRectMake(3, 3, radarViewHolder.frame.size.width-6, radarViewHolder.frame.size.height-6))
        radarView!.layer.contentsScale = UIScreen.mainScreen().scale
        radarView?.alpha = 0.68
        radarViewHolder.addSubview(radarView!)
        
        self.spinRadar()
        currentDeviceBearing = 0
        self.startHeadingEvent()
        
        self.loadUsers()
        
        self.locManager?.requestAlwaysAuthorization()
        self.locManager?.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locManager?.delegate = self
            locManager?.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager?.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func spinRadar() {
        let spin = CABasicAnimation.init(keyPath: "transform.rotation")
        spin.duration = 1
        spin.toValue = NSNumber.init(float: Float(-M_PI))
        spin.cumulative = true
        spin.removedOnCompletion = false
        spin.repeatCount = MAXFLOAT
        radarLine.layer.anchorPoint = CGPointMake(-0.18, 0.5)

        radarLine.layer.addAnimation(spin, forKey: "spinRadarLine")
        radarView!.layer.addAnimation(spin, forKey: "spinRadarView")
    }
    
    func startHeadingEvent() {
        if locManager == nil {
            locManager = CLLocationManager.init()
            locManager?.delegate = self
            locManager?.desiredAccuracy = kCLLocationAccuracyBest
            locManager?.distanceFilter = kCLDistanceFilterNone
            locManager?.headingFilter = kCLHeadingFilterNone
        }
        
        if CLLocationManager.headingAvailable() {
            locManager?.startUpdatingHeading()
        }
    }
    
    func loadUsers() {
        self.removePreviousDots()
        
        nearbyUsers = [
            ["gender":"female", "lat":52.5085061013458, "lng":13.5194939520594, "distance":10],
            ["gender":"female", "lat":52.5085061013457, "lng":13.5194939520593, "distance":10],
            ["gender":"female", "lat":52.5085061013456, "lng":13.5194939520592, "distance":10],
            ["gender":"female", "lat":52.5085061013455, "lng":13.5194939520591, "distance":10]]
        
        //self.renderUsersOnRadar(nearbyUsers!)
    }
    
    func removePreviousDots() {
        for dot in dots! {
            dot.removeFromSuperview()
        }
        
        dots = []
    }
    

    func renderUsersOnRadar(nearbyUsers: NSArray) {
        
        let myLoc: CLLocationCoordinate2D = currentLocation!
        
        let maxDistance: Float = (nearbyUsers.lastObject?.valueForKey("distance")?.floatValue)!
        
        for user in nearbyUsers {
            let dot: Dot = Dot.init(frame: CGRectMake(0, 0, 32, 32))
            dot.layer.contentsScale = UIScreen.mainScreen().scale
            
            let userLat: Float = (user.valueForKey("")?.floatValue)!
            let userLng: Float = (user.valueForKey("")?.floatValue)!
            
            let userLoc: CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: Double(userLat), longitude: Double(userLng))
            
            let bearing = self.getHeadingForDirectionFromCoordinate(myLoc, toLoc: userLoc)
            dot.bearing = NSNumber.init(double: bearing)
            
            let d: Float = (user.valueForKey("")?.floatValue)!
            let distance = max(35, d * 132.0 / maxDistance)
            
            dot.distance = NSNumber.init(float: distance)
            dot.userDistance = NSNumber.init(float: d)
            dot.userProfile = user as! [NSObject : AnyObject]
            dot.zoomEnabled = false
            dot.userInteractionEnabled = false
            self.rotateDot(dot, fromDegrees: 0, degrees: bearing, distance: distance)
            
            arcsView?.addSubview(dot)
            
            dots?.addObject(dot)
            
            detectCollisionTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(detectCollisions), userInfo: nil, repeats: true)
            
        }
    }
    
    func detectCollisions(theTimer: NSTimer) {
        var radarLineRotation = self.radiansToDegrees(Double((radarLine.layer.presentationLayer()?.valueForKeyPath("transform.rotation.z"))! as! NSNumber))
        
        if radarLineRotation >= 0 {
            radarLineRotation -= 360
        }
        
        
        for var i = 0; i < dots?.count; i += 1  {
            let dot: Dot  = (dots?.objectAtIndex(i))! as! Dot
            var dotBearing = Float((dot.bearing)!) - currentDeviceBearing!
            
            if dotBearing < -360 {
                dotBearing += 360
            }
            
            if abs(Double(dotBearing) - radarLineRotation) <= 20 {
                self.pulse(dot)
            }
        }
    }
    
    func pulse(dot: Dot) {
        if ((dot.layer.animationKeys()?.contains("pulse")) != nil) {
            return
        }
        
        let pulse = CABasicAnimation.init(keyPath: "transform.scale")
        pulse.duration = 0.15
        pulse.toValue = NSNumber.init(float: 1.4)
        pulse.autoreverses = true
        dot.layer.contentsScale = UIScreen.mainScreen().scale
        dot.layer.addAnimation(pulse, forKey: "pulse")
    }
    
    func rotateDot(dot: Dot, fromDegrees: Double, degrees: Double, distance: Float) {
        
        let path: CGMutablePathRef = CGPathCreateMutable()
        
        CGPathAddArc(path, nil, 140, 140, CGFloat(distance), CGFloat(self.degreesToRadians(fromDegrees)), CGFloat(self.degreesToRadians(degrees)), true)
        
        let theAnimation: CAKeyframeAnimation = CAKeyframeAnimation.init(keyPath: "position")
        theAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        theAnimation.path = path
        
        theAnimation.duration = 3
        theAnimation.removedOnCompletion = false
        theAnimation.repeatCount = 0
        theAnimation.autoreverses = false
        theAnimation.fillMode = kCAFillModeForwards
        theAnimation.cumulative = true
        
        let newPosition: CGPoint = CGPointMake(CGFloat(distance)*CGFloat(cos(self.degreesToRadians(Double(degrees))+138)), CGFloat(distance)*CGFloat(sin(self.degreesToRadians(Double(degrees)))+138))
        dot.layer.position = newPosition
        
        dot.layer.addAnimation(theAnimation, forKey: "rotateDot")
    }
 
 
    
    func getHeadingForDirectionFromCoordinate(fromLoc: CLLocationCoordinate2D, toLoc: CLLocationCoordinate2D) -> Double {
        let fLat = degreesToRadians(fromLoc.latitude)
        let fLng = degreesToRadians(fromLoc.longitude)
        let tLat = degreesToRadians(toLoc.latitude)
        let tLng = degreesToRadians(toLoc.longitude)
        
        let degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)))
        
        if degree >= 0 {
            return -degree
        } else {
            return -(360 + degree)
        }
    }
    
    func rotateArcsToHeading(angle: CGFloat) {
        arcsView?.transform = CGAffineTransformMakeRotation(angle)
    }
    
    func degreesToRadians(x: Double) -> Double {
        return Double(M_PI * x / 180.0)
    }
    
    func radiansToDegrees(x: Double) -> Double {
        return Double(x * 180.0 / M_PI)
    }
    
    // MARK: - LocationManagerDelegate
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location!.coordinate
        print("locations = \(currentLocation!.latitude) \(currentLocation!.longitude)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = newHeading.magneticHeading
        let headingAngle = -(heading*M_PI/180)
        currentDeviceBearing = Float(heading)
        self.rotateArcsToHeading(CGFloat(headingAngle))
    }

}
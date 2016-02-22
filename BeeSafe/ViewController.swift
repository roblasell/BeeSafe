//
//  ViewController.swift
//  BeeSafe
//
//  Created by Robert Lasell on 2/14/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

enum Session: Int {
    case Route = 0, Events
}

enum Route: Int {
    case Date = 0, Lat, Long
}

enum Events: Int {
    case EventType = 0, Time, Lat, Long
}

enum EventType: Int {
    case OffRoute = 0, OnRoute, InBackground, Home
}

/* FOR RESETTING DATA (Testing) */
let RESET:Bool = false

let startTimeKey = "startTime"
let logKey = "log"
let sessionKey = "session"
let addressKey = "address"
let cityKey = "city"
let stateKey = "state"
let zipKey = "zipcode"
let timeKey = "timeKey"
let fullAddressKey = "fullAddress"
let checkpointKey = "checkpoints"
let pointsKey = "points"
let goodPointsKey = "goodPoints"
let badPointsKey = "badPoints"

let checkpointCheckDistance:Double = 30

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var mapPageButton: UIButton!
    @IBOutlet weak var goodPointsLabel: UILabel!
    @IBOutlet weak var badPointsLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    let locationManager = CLLocationManager()
    var homeCoordinates = CLLocationCoordinate2D()
    var session:[AnyObject] = [[AnyObject](), [AnyObject]()]
    var locationList = [CLLocation]()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeDefaults()
        
        // set up location manager
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.distanceFilter = 5 // in meters
            locationManager.headingFilter = kCLHeadingFilterNone
            locationManager.requestAlwaysAuthorization()
        } else {
            let alert = UIAlertController(title: "Location Service Disabled", message: "Sorry, your location could not be determined!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        goodPointsLabel.text = "+" + String(defaults.integerForKey(goodPointsKey))
        badPointsLabel.text = "-" + String(defaults.integerForKey(badPointsKey))
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "applicationDidEnterBackground:",
            name: UIApplicationDidEnterBackgroundNotification,
            object: nil)
    }
    
    func initializeDefaults() {
        if (RESET) {
            defaults.removeObjectForKey(pointsKey)
            defaults.removeObjectForKey(goodPointsKey)
            defaults.removeObjectForKey(badPointsKey)
            defaults.removeObjectForKey(startTimeKey)
            defaults.removeObjectForKey(logKey)
        }
        
        if (defaults.objectForKey(timeKey) == nil) {
            defaults.setObject(NSDate(), forKey: timeKey)
        }
        
        if (defaults.arrayForKey(checkpointKey) == nil) {
            let newPath = []
            defaults.setObject(newPath, forKey: checkpointKey)
        }
        
        // Home Address
        if (defaults.stringForKey(fullAddressKey) == nil) {
            defaults.setObject("", forKey: fullAddressKey)
        }
        
        if (defaults.stringForKey(addressKey) == nil) {
            defaults.setObject("", forKey: addressKey)
        }
        
        if (defaults.stringForKey(cityKey) == nil) {
            defaults.setObject("", forKey: cityKey)
        }
        
        if (defaults.stringForKey(stateKey) == nil) {
            defaults.setObject("", forKey: stateKey)
        }
        
        if (defaults.stringForKey(zipKey) == nil) {
            defaults.setObject("", forKey: zipKey)
        }
        
        if (defaults.boolForKey(sessionKey)) {
            defaults.setBool(false, forKey: sessionKey)
        }
        
        if (defaults.objectForKey(startTimeKey) == nil) {
            let startTime = NSDate()
            defaults.setObject(startTime, forKey: startTimeKey)
        }
        
        if (defaults.arrayForKey(logKey) == nil) {
            let newLog = []
            defaults.setObject(newLog, forKey: logKey)
        }
    }
    
    func applicationDidEnterBackground(notification: NSNotification) {
        logBackgroundEvent()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationList.append(locationManager.location!)
        //print("in didUpdateLocations", locationManager.location!.coordinate)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alert = UIAlertController(title: "Location Service Failed", message: "Sorry, your location could not be determined!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed (sender : AnyObject) -> Void {
        if (defaults.boolForKey(sessionKey) == false) {
            newSession()
            button.setTitle("Stop Walk", forState: UIControlState.Normal)
        } else {
            save()
            button.setTitle("Start Walk", forState: UIControlState.Normal)
        }
    }

    // begin a new logging session
    // create new session with empty arrays for route and events
    // [Any]() notation creates a new Swift array, as opposed to [] which creates an NSArray
    func newSession() {
        locationList = [CLLocation]()
        session = [[AnyObject](), [AnyObject]()]
        //print("HERE!", session)
        locationManager.startUpdatingLocation()
        defaults.setBool(true, forKey: sessionKey)
    }
    
    func save() {
        locationManager.stopUpdatingLocation()
        logCheckpointEvents()
        defaults.setBool(false, forKey: sessionKey)
        
        // add each location in the route to session
        for location in locationList {
            let date = location.timestamp
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            
            var loc = [AnyObject](count: 3, repeatedValue: 0.0)
            loc[Route.Date.rawValue] = date
            loc[Route.Lat.rawValue] = lat
            loc[Route.Long.rawValue] = long
            
            var route = session[Session.Route.rawValue] as! [AnyObject]
            route.append(loc)
            session[Session.Route.rawValue] = route
        }
        /*
        // temporary fix for empty first event
        var events = session[Session.Events.rawValue] as! [AnyObject]
        print("EVENTS BEFORE REMOVING FIRST:", events)
        events.removeFirst()
        session[Session.Events.rawValue] = events
        */
        
        calculatePoints()
        
        // pull log out of user defaults, add session, resave log
        var log = defaults.arrayForKey(logKey)
        log?.append(session)
        defaults.setObject(log, forKey: logKey)
        
        // test print
        //testPrintSessions()
    }
    
    func logBackgroundEvent() {
        if (!defaults.boolForKey(sessionKey)) {
            //print("In background but not currently logging session")
            return
        }
        
        //print("in logBackGroundEvent")
        
        let location = locationManager.location!
        let time = location.timestamp
        let lat = location.coordinate.latitude
        let long = location.coordinate.longitude
        let eventType = EventType.InBackground.rawValue
        
        var event = [AnyObject](count: 4, repeatedValue: 0.0)
        event[Events.Time.rawValue] = time
        event[Events.Lat.rawValue] = lat
        event[Events.Long.rawValue] = long
        event[Events.EventType.rawValue] = eventType
        
        var events = session[Session.Events.rawValue] as! [AnyObject]
        events.append(event)
        session[Session.Events.rawValue] = events
    }
    
    func logCheckpointEvents() {
        let checkpoints = defaults.arrayForKey(checkpointKey)
        var events = [[AnyObject]]()
        
        for checkpoint in checkpoints! {
            let cp = checkpoint as! [Double]
            var cpCoord = CLLocationCoordinate2D()
            cpCoord.latitude = cp[Checkpoints.Lat.rawValue]
            cpCoord.longitude = cp[Checkpoints.Long.rawValue]
            var didLogEvent:Bool = false
            
            for location in locationList {
                let point1 = MKMapPointForCoordinate(location.coordinate)
                let point2 = MKMapPointForCoordinate(cpCoord)
                let distance:CLLocationDistance = MKMetersBetweenMapPoints(point1, point2)
                
                // log a positive checkpoint event
                if (distance < checkpointCheckDistance) {
                    var event = [AnyObject](count: 4, repeatedValue: 0.0)
                    event[Events.Time.rawValue] = location.timestamp
                    event[Events.Lat.rawValue] = cpCoord.latitude
                    event[Events.Long.rawValue] = cpCoord.longitude
                    event[Events.EventType.rawValue] = EventType.OnRoute.rawValue
                    events.append(event)
                    didLogEvent = true
                    break
                }
            }
            
            // log a negative checkpoint event
            if (!didLogEvent) {
                var event = [AnyObject](count: 4, repeatedValue: 0.0)
                event[Events.Time.rawValue] = (locationList.last?.timestamp)!
                event[Events.Lat.rawValue] = cpCoord.latitude
                event[Events.Long.rawValue] = cpCoord.longitude
                event[Events.EventType.rawValue] = EventType.OffRoute.rawValue
                events.append(event)
            }
        }
        
        // check whether the walker reached home
        findHomeAddress()
        for location in locationList {
            let point1 = MKMapPointForCoordinate(location.coordinate)
            let point2 = MKMapPointForCoordinate(homeCoordinates)
            let distance:CLLocationDistance = MKMetersBetweenMapPoints(point1, point2)

            if (distance < checkpointCheckDistance * 2) {
                var event = [AnyObject](count: 4, repeatedValue: 0.0)
                event[Events.Time.rawValue] = location.timestamp
                event[Events.Lat.rawValue] = location.coordinate.latitude
                event[Events.Long.rawValue] = location.coordinate.longitude
                event[Events.EventType.rawValue] = EventType.Home.rawValue
                events.append(event)
                break
            }
        }
        
        // add all events to session
        var sessionEvents = session[Session.Events.rawValue] as! [AnyObject]
        
        for event in events {
            sessionEvents.append(event)
        }
        
        session[Session.Events.rawValue] = sessionEvents
    }
    
    func findHomeAddress() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(defaults.stringForKey(fullAddressKey)!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            
            if let placemark = placemarks?.first {
                let homeCoords:CLLocationCoordinate2D = placemark.location!.coordinate
                self.homeCoordinates.latitude = homeCoords.latitude
                self.homeCoordinates.longitude = homeCoords.longitude
            }
        })
    }
    
    func testPrintSessions() {
        print("NSUserDefaults Data:")
        let l = defaults.arrayForKey(logKey)
        for sess in l! {
            print(sess)
        }
    }
    
    func calculatePoints() {
        var points = defaults.integerForKey(pointsKey)
        var goodPoints = defaults.integerForKey(goodPointsKey)
        var badPoints = defaults.integerForKey(badPointsKey)
        
        for event in session[Session.Events.rawValue] as! [AnyObject] {
            if (event[Events.EventType.rawValue] as! Int == EventType.OnRoute.rawValue) {
                points++
                goodPoints++
            } else if (event[Events.EventType.rawValue] as! Int == EventType.OffRoute.rawValue) {
                points--
                badPoints++
            } else if (event[Events.EventType.rawValue] as! Int == EventType.InBackground.rawValue) {
                points--
                badPoints++
            } else if (event[Events.EventType.rawValue] as! Int == EventType.Home.rawValue) {
                points++
                goodPoints++
            }
        }
        
        goodPointsLabel.text = "+" + String(goodPoints)
        badPointsLabel.text = "-" + String(badPoints)
        
        defaults.setInteger(points, forKey: pointsKey)
        defaults.setInteger(goodPoints, forKey: goodPointsKey)
        defaults.setInteger(badPoints, forKey: badPointsKey)
    }
}



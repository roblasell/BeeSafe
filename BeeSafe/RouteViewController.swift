//
//  RouteViewController.swift
//  BeeSafe
//
//  Created by Robert Lasell on 2/17/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

enum Checkpoints: Int {
    case Lat = 0, Long
}

class RouteViewController: UIViewController, MKMapViewDelegate {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var clearButton: UIBarButtonItem!
    
    var route = [CLLocationCoordinate2D]()
    var annotations = [CustomPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self

        if (defaults.stringForKey(fullAddressKey) != nil) {
            placeHomeAddress()
        }
        
        getCheckpoints()
        
        //let press = UILongPressGestureRecognizer(target: self, action: "action:")
        let press = UITapGestureRecognizer(target: self, action: "action:")
        //press.minimumPressDuration = 1.0
        map.addGestureRecognizer(press)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        saveCheckpoints()
    }
    
    func action(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(map)
        let newCoord:CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: map)
        
        let newAnnotation = CustomPointAnnotation()
        newAnnotation.imageName = "flowersmallgood.png"
        newAnnotation.coordinate = newCoord
        route.append(newCoord)
        //newAnnotation.title = "Checkpoint"
        //newAnnotation.subtitle = String(newCoord.latitude) + ", " + String(newCoord.longitude)
        map.addAnnotation(newAnnotation)
        annotations.append(newAnnotation)
    }
    
    func placeHomeAddress() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(defaults.stringForKey(fullAddressKey)!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            
            if let placemark = placemarks?.first {
                let homeCoordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                let homeAnnotation = CustomPointAnnotation()
                homeAnnotation.imageName = "beehivesmall.png"
                homeAnnotation.coordinate = homeCoordinates
                self.centerMapOnLocation(homeCoordinates)
                homeAnnotation.title = "Home"
                self.map.addAnnotation(homeAnnotation)
            }
        })
    }
    
    @IBAction func undoButtonPressed (sender : AnyObject) -> Void {
        if (!route.isEmpty) {
            route.removeLast()
            map.removeAnnotation(annotations.last!)
            annotations.removeLast()
        }
    }
    
    @IBAction func clearButtonPressed (sender : AnyObject) -> Void {
        if (!route.isEmpty) {
            route.removeAll()
            map.removeAnnotations(annotations)
            annotations.removeAll()
        }
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let regionRadius = 500.0
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        map.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = UIImage(named:cpa.imageName)
        
        return anView
    }
    
    func getCheckpoints() {
        let path = defaults.arrayForKey(checkpointKey)
        
        for loc in path! {
            let lat = loc[Checkpoints.Lat.rawValue] as! Double
            let long = loc[Checkpoints.Long.rawValue] as! Double
            
            var newCoord = CLLocationCoordinate2D()
            newCoord.latitude = lat
            newCoord.longitude = long
            
            route.append(newCoord)
            
            let newAnnotation = CustomPointAnnotation()
            newAnnotation.imageName = "flowersmallgood.png"
            newAnnotation.coordinate = newCoord
            map.addAnnotation(newAnnotation)
            annotations.append(newAnnotation)
        }
    }
    
    func saveCheckpoints() {
        var path = [AnyObject]()
        
        for location in route {
            let lat = location.latitude
            let long = location.longitude
            
            var loc = [AnyObject](count: 2, repeatedValue: 0.0)
            loc[Checkpoints.Lat.rawValue] = lat
            loc[Checkpoints.Long.rawValue] = long
            
            path.append(loc)
        }
        
        defaults.setObject(path, forKey: checkpointKey)
    }
}

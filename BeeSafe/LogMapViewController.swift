//
//  LogMapViewController.swift
//  BeeSafe
//
//  Created by Robert Lasell on 2/15/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

let polylineThreshold = 100.0

class LogMapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var map: MKMapView!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var row:Int = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup map
        map.delegate = self
        
        displayRoute()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func displayRoute() {
        let session = defaults.arrayForKey(logKey)![row] as! [AnyObject]
        let route = session[Session.Route.rawValue] as! [AnyObject]
        
        var oldCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
        var newCoordinate:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        for location in route {
            let lat = location[Route.Lat.rawValue] as! Double
            let long = location[Route.Long.rawValue] as! Double
            
            if (oldCoordinate.latitude == 0 && oldCoordinate.longitude == 0) {
                oldCoordinate.latitude = lat
                oldCoordinate.longitude = long
                
                centerMapOnLocation(oldCoordinate)
                
                continue
            }
            
            newCoordinate.latitude = lat
            newCoordinate.longitude = long
            
            let point1 = MKMapPointForCoordinate(newCoordinate)
            let point2 = MKMapPointForCoordinate(oldCoordinate)
            let distance:CLLocationDistance = MKMetersBetweenMapPoints(point1, point2)
            
            if (distance < polylineThreshold) {
                var area = [oldCoordinate, newCoordinate]
                let polyline = MKPolyline(coordinates: &area, count: area.count)
            
                map.addOverlay(polyline)
            }
            
            oldCoordinate.latitude = lat
            oldCoordinate.longitude = long
        }
        
        placeCheckpoints()
        placeHomeAddress()
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor(red:0.0, green:122.0/255.0, blue:1.0, alpha:1.0)
            pr.lineWidth = 5
            return pr
        }
        return MKOverlayRenderer()
    }
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let regionRadius = 50.0
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, regionRadius, regionRadius)
        map.setRegion(coordinateRegion, animated: true)
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
                //self.centerMapOnLocation(homeCoordinates)
                homeAnnotation.title = "Home"
                self.map.addAnnotation(homeAnnotation)
            }
        })
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
    
    func placeCheckpoints() {
        let session = defaults.arrayForKey(logKey)![row] as! [AnyObject]
        let events = session[Session.Events.rawValue] as! [AnyObject]
        
        for event in events {
            let lat = event[Events.Lat.rawValue] as! Double
            let long = event[Events.Long.rawValue] as! Double
            var newCoord = CLLocationCoordinate2D()
            newCoord.latitude = lat
            newCoord.longitude = long
            
            let newAnnotation = CustomPointAnnotation()
            newAnnotation.coordinate = newCoord
            
            if (event[Events.EventType.rawValue] as! Int == EventType.OnRoute.rawValue) {
                newAnnotation.imageName = "flowersmallgood.png"
                map.addAnnotation(newAnnotation)
            } else if (event[Events.EventType.rawValue] as! Int == EventType.OffRoute.rawValue) {
                newAnnotation.imageName = "flowersmallbad.png"
                map.addAnnotation(newAnnotation)
            }
        }
    }
}

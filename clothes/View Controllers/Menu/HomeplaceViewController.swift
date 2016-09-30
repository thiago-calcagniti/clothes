//
//  HomeplaceViewController.swift
//  AnimatedTabControl
//
//  Created by Thiago Calcagniti on 09/02/16.
//  Copyright © 2016 Calcagniti. All rights reserved.
//

import UIKit
import MapKit
import Parse

protocol ChangeHomeplace {
    func changeHomeplace(_ newPlace: String, newLatitude: Double, newLongitude: Double)
}


class HomeplaceViewController: UIViewController, CLLocationManagerDelegate {
    
    
    var mapView: MKMapView!
    var manager: CLLocationManager!
    var annotation: MKPointAnnotation!
    var delegate: ChangeHomeplace?
    var homePlaceLatitude: Double!
    var homePlaceLongitude: Double!
    
    
    // Initializers
    init(delegate: ChangeHomeplace, latitude: Double, longitude: Double) {
        self.delegate = delegate
        self.homePlaceLatitude = latitude
        self.homePlaceLongitude = longitude
        super.init(nibName: "HomeplaceViewController", bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override func viewDidLoad() {
        
        createMap()
        addInstructionLabel()
        addExistingCityInMap()
        
        

    }
    
  
    func createMap() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        mapView = MKMapView()
        mapView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        mapView.mapType = .standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        self.view.addSubview(mapView)
        
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
        let fingerPress = UILongPressGestureRecognizer(target: self, action: #selector(HomeplaceViewController.changeHomeplace(_:)))
        fingerPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(fingerPress)
    }
    func addInstructionLabel() {
        let screenHeight = UIScreen.main.bounds.height
        let screenWidth = UIScreen.main.bounds.width
        
        let messageView = UILabel()
        messageView.frame = CGRect(x: 0, y: 59, width: screenWidth, height: screenHeight*0.05)
        messageView.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(0.5))
        messageView.textColor = UIColor.white
        messageView.textAlignment = NSTextAlignment.center
        messageView.font = UIFont(name: "Klavika", size: CGFloat(14))
        messageView.text = "Pressione 2 segundos para marcar"
        self.view.addSubview(messageView)
    }
    func addExistingCityInMap() {
        if (homePlaceLatitude != 0 && homePlaceLongitude != 0) {
            let latitude:CLLocationDegrees = homePlaceLatitude
            let longitude:CLLocationDegrees = homePlaceLongitude
            
            let latDelta:CLLocationDegrees = 1.2
            let lonDelta:CLLocationDegrees = 1.2
            
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            
            mapView.setRegion(region, animated: true)
            
            let coordinatePoint = CLLocation(latitude: latitude, longitude: longitude)
            CLGeocoder().reverseGeocodeLocation(coordinatePoint) { (placemarkers, error) -> Void in
                if (error == nil) {
                    if let place = placemarkers?[0] {
                        if let city = place.addressDictionary!["City"] as? NSString {
                            let annotation = MKPointAnnotation()
                            annotation.coordinate = location
                            annotation.title = city as String
                            annotation.subtitle = "Você mora aqui perto!"
                            self.mapView.addAnnotation(annotation)
                            self.mapView.selectAnnotation(annotation, animated: true)
                        }
                    }
                }
            }
        }
    }
    func changeHomeplace(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.began {
            let touchPoint = gesture.location(in: self.mapView)
            let newCoordinate = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            
            let location = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarkers, error) -> Void in
                if (error == nil) {
                    if let place = placemarkers?[0] {
                        if let city = place.addressDictionary!["City"] as? NSString {
                            print("\(city) \(newCoordinate.latitude) \(newCoordinate.longitude)")
                            
                            self.mapView.removeAnnotations(self.mapView.annotations)
                            self.annotation = MKPointAnnotation()
                            self.annotation.coordinate = newCoordinate
                            self.annotation.title = city as String
                            self.annotation.subtitle = "Você mora aqui perto!"
                            self.mapView.addAnnotation(self.annotation)
                            self.mapView.selectAnnotation(self.annotation, animated: true)
                            

                            let cityPlace: PFGeoPoint = PFGeoPoint(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                            let user = PFUser.current()!
                            user["homeplace"] = cityPlace
                            print("\(cityPlace)")
                            user.saveInBackground(block: { (success, error) -> Void in
                                self.delegate?.changeHomeplace(city as String, newLatitude: newCoordinate.latitude, newLongitude: newCoordinate.longitude)
                            })
                        }
                    }
                }
            })
        }
    }
    
    
    
 


}

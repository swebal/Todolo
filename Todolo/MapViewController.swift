//
//  MapViewController.swift
//  Todolo
//
//  Created by Markus Karlsson on 2019-03-16.
//  Copyright © 2019 The App Factory AB. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var didShowUserLocationOnce = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Observera notiser för uppdateringar av användarens plats
        
        let updateLocationName = Notification.Name(UserLocationHelper.didUpdateLocation)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.userLocationDidUpdate), name: updateLocationName, object: nil)
        
        // Begär tillstånd att spåra plats
        
        UserLocationHelper.shared.authorize()
    }
    
    @IBOutlet weak var myMapView: MKMapView!
    
    @objc func userLocationDidUpdate(_ notification:Notification) {
        // Kolla ifall user location finns
        guard let userLocation = notification.object as? CLLocation else {
            return
        }
        // Updatera karta första gången
        if !didShowUserLocationOnce {
            didShowUserLocationOnce = true
            // Flytta och zooma kartan
            let mapSpan = MKCoordinateSpanMake(0.01, 0.01)
            let mapRegion = MKCoordinateRegionMake(userLocation.coordinate, mapSpan)
            myMapView.setRegion(mapRegion, animated: true)
        }
    }
    
    @IBAction func zoomToUserPressed(_ sender: UIButton) {
        // Kolla ifall user location finns
        guard let userLocation = UserLocationHelper.shared.lastKnownLocation else {
            return
        }
        // Flytta och zooma kartan
        let mapSpan = MKCoordinateSpanMake(0.01, 0.01)
        let mapRegion = MKCoordinateRegionMake(userLocation.coordinate, mapSpan)
        myMapView.setRegion(mapRegion, animated: true)
    }
    
    @IBAction func dropPinPressed(_ sender: UIButton) {
        // Hämta koordinated i mitten av kartan och placera en nål i närheten
        let centerCoordinate = myMapView.centerCoordinate
        let randomLatDiff = (Double(arc4random_uniform(100))/100-0.5)/100
        let randomLonDiff = (Double(arc4random_uniform(100))/100-0.5)/100
        // Skapa ny annotation
        let randomAnnotation = MKPointAnnotation()
        randomAnnotation.coordinate = CLLocationCoordinate2DMake(centerCoordinate.latitude+randomLatDiff, centerCoordinate.longitude+randomLonDiff)
        randomAnnotation.title = "Titel"
        randomAnnotation.subtitle = "Undertitel"
        myMapView.addAnnotation(randomAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
}

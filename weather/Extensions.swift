//
//  VCMapView.swift
//  weather
//
//  Created by KUBRA on 2017-01-12.
//  Copyright © 2017 KUBRA. All rights reserved.
//

import MapKit

extension ViewController: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView,
    viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? Artwork {
            
            let identifier = "artPin"
            var view: MKPinAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
              as? MKPinAnnotationView { 
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
              
              view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
              view.canShowCallout = true
              view.calloutOffset = CGPoint(x: -5, y: 5)
              view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure) as UIView
            }

            view.pinTintColor = annotation.pinTintColor()        
            return view
        }
        return nil
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! Artwork
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        location.mapItem().openInMaps(launchOptions: launchOptions)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

// Another way dealing with string localization could use property list
extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    func localizedWithComment(comment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment)
    }
}

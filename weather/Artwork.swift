//
//  Artwork.swift
//  weather
//
//  Created by KUBRA on 2017-01-12.
//  Copyright © 2017 KUBRA. All rights reserved.
//

import Foundation
import MapKit
import Contacts

class Artwork: NSObject, MKAnnotation {
  let title: String?
  let locationName: String
  let discipline: String
  let coordinate: CLLocationCoordinate2D
  
  init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
    self.title = title
    self.locationName = locationName
    self.discipline = discipline
    self.coordinate = coordinate
    
    super.init()
  }
    
  var subtitle: String? {
    return locationName
  }
  
  // MARK: - MapKit related methods
  
  // pinTintColor for disciplines: Sculpture, Plaque, Mural, Monument, other
  func pinTintColor() -> UIColor  {
    switch discipline {
    case "Sculpture", "Plaque":
      return MKPinAnnotationView.redPinColor()
    case "Mural", "Monument": 
      return MKPinAnnotationView.purplePinColor()
    default:
      return MKPinAnnotationView.greenPinColor()
    }
  }
  
    
  // annotation callout opens this mapItem in Maps app
  func mapItem() -> MKMapItem {
    let addressDict = [CNPostalAddressStreetKey: subtitle!]
    let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
    
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = title
    
    return mapItem
  }
 
  
}

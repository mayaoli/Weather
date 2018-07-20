//
//  ViewController.swift
//  weather
//
//  Created by KUBRA on 2017-01-11.
//  Copyright © 2017 KUBRA. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftyJSON
import MapKit

class ViewController: UIViewController, WeatherDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var wmapView: MKMapView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var locationText: UITextField!
    
    let locationManager = CLLocationManager()
    var weather: OpenWeather!
    let regionRadius: CLLocationDistance = 3000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weather = OpenWeather(delegate: self)
        //getLocation()
        
        //let weather = OpenWeather()
        //weather.getWeatherInfo(27.9506, -82.4572)
        //print(weather.weatherJson)
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationText.delegate = self;
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func refresh(_ sender: UIButton) {
        
        view.endEditing(true)
        
        if (self.locationText.text != "") {
            weather.getWeatherByCity((self.locationText.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))!)
        }
        else {
            // Request GPS
            getLocation()
        }
    }
    
    func centerMapOnLocation(_ location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        wmapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func drawMap(_ location: CLLocationCoordinate2D, _ weatherData: JSON) {
        
        DispatchQueue.main.async {
            self.centerMapOnLocation(location)
            
            let weatherInfo = "\(self.tempCelsiusStr(weatherData["main"]["temp"].double!)) (\(weatherData["weather"][0]["description"].string!))"
            let city = weatherData["name"].string
            
            self.locationText!.text = city
            self.cityLabel!.text = city
            self.weatherLabel!.text = weatherInfo
            
            let artwork = Artwork(title: weatherInfo,
                                  locationName: city!,
                                  discipline: "Sculpture",
                                  coordinate: location)
            // CLLocationCoordinate2D(latitude: weather["coord"]["lat"].double!, longitude: weather["coord"]["lon"].double!) is not accurate
            
            let allAnnotations = self.wmapView.annotations
            self.wmapView.removeAnnotations(allAnnotations)
            
            self.wmapView.addAnnotation(artwork)
            self.wmapView.delegate = self
            self.wmapView.selectAnnotation(self.wmapView.annotations[0], animated: true)
        }
    }
    
    func tempCelsiusStr(_ temp: Double) -> String {
        return "\(String(format: "%.1f", temp - 273.15)) °C"  // (temp - 273.15) * 1.8 + 32) °F
    }

    func showError(_ error: NSError) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // All UI code needs to execute in the main queue, which is why we're wrapping the call
        // to showMessage(title:message:) in a dispatch_async() call.
        DispatchQueue.main.async {
            self.showMessage(title: "Error".localized,
                                 message: "ServiceNotAvailable".localized)
        }
        //print("showError error: \(error)")
    }
    
    func showSetting() {
        let alert = UIAlertController(
            title: "ServiceDisabled".localized,
            message: "ServiceDisabledMsg".localized,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
        let openSettingsAction = UIAlertAction(title: "OpenSettings".localized, style: .default) {
            action in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.openURL(url)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(openSettingsAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showMessage(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(
            title: "OK",
            style:  .default,
            handler: nil
        )
        alert.addAction(okAction)
        present(
            alert,
            animated: true,
            completion: nil
        )
    }
    
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            showMessage(
                title: "TurnOn".localized,
                message: "TurnOnMsg".localized
            )
            // use default
            
            
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .authorizedWhenInUse else {
            switch authStatus {
            case .denied, .restricted:
                
                showSetting()
                
                return
                
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                // Shouldn't be here
                print("?")
            }
            
            return
        }
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied, .restricted:
            showSetting()
            return
        default:
            print("?")
        }
        
        //locationManager.delegate = self
        //locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let lastLocation: CLLocation = locations.last!
        let accuracy = lastLocation.horizontalAccuracy * lastLocation.verticalAccuracy
        
        print(accuracy)
        
        var flag : Bool = false;
        
        //if (accuracy < 10000 && !flag) {
        if (!flag) {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        
            DispatchQueue.main.async {
                let newLocation = locations.last!
                self.weather.getWeatherByCoordinate(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
                
                flag = true
                //centerMapOnLocation(newLocation.coordinate)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // All UI code needs to execute in the main queue, which is why we're wrapping the call
        // to showMessage(title:message:) in a dispatch_async() call.
        
        locationManager.stopUpdatingLocation()
        
        DispatchQueue.main.async {
            self.showMessage(title: "GPSFailed".localized,
                                 message: "GPSFailedMsg".localized)
        }
        print("locationManager didFailWithError: \(error)")
        
    }
    
}






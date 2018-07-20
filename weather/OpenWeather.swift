//
//  OpenWeather.swift
//  weather
//
//  Created by KUBRA on 2017-01-11.
//  Copyright © 2017 KUBRA. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreLocation


protocol WeatherDelegate {
    func drawMap(_ location: CLLocationCoordinate2D, _ weather: JSON)
    func showError(_ error: NSError)
}

class OpenWeather {
  
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "392423d99e3eb5603468f8d7d64f6c3c"
    
    var delegate: WeatherDelegate
    
    var latitude : Double
    var longitude : Double
    
    init(delegate: WeatherDelegate) {
        self.delegate = delegate
        self.latitude = 0.0
        self.longitude = 0.0
    }
    
    func getWeatherByCity(_ cityName: String) {
        self.latitude = 0.0
        self.longitude = 0.0
        
        let cityName = cityName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let weatherRequestURL = "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(cityName)"
        
        getWeatherByURL(weatherRequestURL)
    }
    
    func getWeatherByCoordinate(_ lat: Double, _ lon: Double) {
        self.latitude = lat
        self.longitude = lon
        
        let weatherRequestURL = "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(lat)&lon=\(lon)"
        
        getWeatherByURL(weatherRequestURL)
    }
    
    func getWeatherByURL(_ weatherRequestURL:String) {
        
        
        let manager = AFHTTPSessionManager(baseURL: URL(string:openWeatherMapBaseURL))
        manager.requestSerializer = AFJSONRequestSerializer()
        manager.responseSerializer = AFJSONResponseSerializer()
        
        manager.get(weatherRequestURL, parameters: nil, progress: { (NSProgress) in
            
        }, success: { (task:URLSessionDataTask, responseObject) -> Void  in
            
            print("Raw data:\n\(responseObject!)\n")
            
            print((responseObject as? [String: Any])?["visibility"] as? Double ?? 0)
            
            let json = JSON(responseObject ?? [])
        
            if (self.latitude == 0.0 && self.longitude == 0.0) {
                self.latitude=json["coord"]["lat"].double!
                self.longitude=json["coord"]["lon"].double!
            }
 
            self.delegate.drawMap(CLLocationCoordinate2D(latitude:self.latitude, longitude:self.longitude), json)
            
        }, failure: { (task:URLSessionDataTask?, error:Error) -> Void  in
            // Case Error
            print("Error:\n\(error)")
            self.delegate.showError(error as NSError)
        })
        
        /*
        //---------------------------------------------------------------------------------------
        // Preferred way of requesting data
        // The data task retrieves the data, using shared session
        let session = URLSession.shared
        let dataTask = session.dataTask(with: weatherRequestURL, completionHandler: { (data, response, error) in
          
            if let networkError = error {
                // Case Error
                print("Error:\n\(error)")
                self.delegate.showError(networkError as NSError)
            }
            else {

                // Case Success, got a response from the server
                print("Raw data:\n\(data!)\n")
                let dataString = String(data: data!, encoding: String.Encoding.utf8)
                print("Decoded data:\n\(dataString!)")
                // debug end

                // Using SwiftyJSON
                // Check JSON serialization error
                guard let unwrappedData = data else {
                    print("error trying to convert data to JSON")
                    return
                }
                let json = JSON(data: unwrappedData)
                
                //print(json["list"][0]["main"]["temp"])
                if (self.latitude == 0.0 && self.longitude == 0.0) {
                    self.latitude=json["coord"]["lat"].double!
                    self.longitude=json["coord"]["lon"].double!
                }
                
                self.delegate.drawMap(CLLocationCoordinate2D(latitude:self.latitude, longitude:self.longitude), json)
                
                // Parse Json object
                // Prefer to have string name type in this way
                //do {
                //    guard let weatherInfo = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] else {
                //        print("error trying to convert data to JSON")
                //        return
                //    }
                //
                //    let weather = Weather(weatherData: weatherInfo)
                //
                //    self.delegate.drawMap(weather)
                //
                //} catch  {
                //    print("error trying to convert data to JSON")
                //    return
                //}
                
            }
            
        })
        
        // The data task is set up...launch it!
        dataTask.resume()
        */
    }
  
}
    

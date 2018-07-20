//
//  Weather.swift
//  weather
//
//  Created by KUBRA on 2017-01-11.
//  Copyright © 2017 KUBRA. All rights reserved.
//

import Foundation

struct Weather {
    
  let city: String
  
  let weatherID: Int
  let mainWeather: String
  let weatherDescription: String
  let weatherIconID: String
  
  // computed properties.
  fileprivate let temp: Double
  var tempCelsius: Double {
    get {
      return temp - 273.15
    }
  }
  var tempFahrenheit: Double {
    get {
      return (temp - 273.15) * 1.8 + 32
    }
  }
    
  init(weatherData: [String: AnyObject]) {
    city = weatherData["name"] as! String
    
    let weatherDict = weatherData["weather"]![0] as! [String: AnyObject]
    weatherID = weatherDict["id"] as! Int
    mainWeather = weatherDict["main"] as! String
    weatherDescription = weatherDict["description"] as! String
    weatherIconID = weatherDict["icon"] as! String
    
    let mainDict = weatherData["main"] as! [String: AnyObject]
    temp = mainDict["temp"] as! Double
  }
  
}

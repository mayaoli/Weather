//
//  WeatherSpec.swift
//  Weather
//
//  Created by KUBRA on 2017-01-12.
//  Copyright © 2017 KUBRA. All rights reserved.
//


import Quick
import Nimble
@testable import weather

class WeatherSpec: QuickSpec {
    
    override func spec() {
        
        describe("#init") {
            it("should have location, temperature and forecasts") {
                let weather = Weather(location: "location",
                                      temperature: "temperature", forecasts: [])
                expect(weather.location).to(equal("location"))
                expect(weather.temperature).to(equal("temperature"))
                expect(weather.forecasts.count).to(equal(0))
            }
        }
        
    }
    
}

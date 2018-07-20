//
//  Created by Tran Xuan Hoang on 12/4/15.
//  Copyright © 2015 Jake Lin. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftWeather

class TemperatureSpec: QuickSpec {

  override func spec() {

    describe("#init(country:openWeatherMapDegrees:)") {
      
        it("should convert temperature to Fahrenheit") {
          let temperature = Temperature(openWeatherMapDegrees: 20)
          expect(temperature.degrees).to(equal("-424.0" + "\u{f045}"))
        }
      
    }

  }

}

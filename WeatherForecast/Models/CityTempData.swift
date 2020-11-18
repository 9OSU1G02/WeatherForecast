//
//  CityTempData.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import Foundation
struct CityTempData : Hashable {
    var city: String!
    var temp: Double!
    var isCurrentLocation: Bool!
    var lat:String!
    var lon:String!
}

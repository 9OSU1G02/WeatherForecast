//
//  WeatherLocation.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import Foundation
struct WeatherLocation: Codable, Equatable {
    var city: String!
    var lat: String!
    var lon: String!
    var country: String!
    var countryCode: String!
    var adminCity: String!
    var isCurrentLocation: Bool!
}

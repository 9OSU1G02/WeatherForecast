//
//  Constant.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/15/20.
//

import Foundation

let KEY_LOCATIONS = "Locations"
let KEY_TEMP_FORMAT = "TempFormat"
let KEY_SORT_STYLE = "SortStyle"

let CURRENT_HOURLY_FORECAST_URL = "https://api.weatherbit.io/v2.0/forecast/hourly?lat=\(LocationService.shared.latitude ?? 0)&lon=\(LocationService.shared.longtitude ?? 0)&key=ca313af990e94174bab2912d60a680ce&hours=24"
let CURRENT_WEEKLY_FORECAST_URL = "https://api.weatherbit.io/v2.0/forecast/daily?lat=\(LocationService.shared.latitude ?? 0)&lon=\(LocationService.shared.longtitude ?? 0)&key=ca313af990e94174bab2912d60a680ce&days=7"
var CURRENT_FORECAST_URL = "https://api.weatherbit.io/v2.0/current?lat=\(LocationService.shared.latitude ?? 0)&lon=\(LocationService.shared.longtitude ?? 0)&key=ca313af990e94174bab2912d60a680ce"

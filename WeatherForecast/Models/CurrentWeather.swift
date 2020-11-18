//
//  CurrentWeather.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import Foundation
import SwiftyJSON
import Alamofire

class CurrentWeather {
    // MARK: - Properties
    private var _city: String!
    private var _date: Date!
    private var _currentTemp: Double!
    private var _feelsLike: Double!
    private var _uv: Double!
    
    private var _weatherType: String!
    private var _pressure: Double! //mb
    private var _humidity: Double! //%
    private var _windSpeed: Double! // meter/sec
    private var _weatherIcon: String!
    private var _visibility: Double! // KM
    private var _sunrise: String!
    private var _sunset: String!
    
    var city: String {
        if _city == nil {
            _city = ""
        }
        return _city
    }
    var date: Date {
        if _date == nil {
            _date = Date()
        }
        return _date
    }
    var uv: Double {
        if _uv == nil {
            _uv = 0.0
        }
        return _uv
    }
    var sunrise: String {
        if _sunrise == nil {
            _sunrise = ""
        }
        return _sunrise
    }
    var sunset: String {
        if _sunset == nil {
            _sunset = ""
        }
        return _sunset
    }
    var currentTemp: Double {
        if _currentTemp == nil {
            _currentTemp = 0.0
        }
        return _currentTemp
    }
    var feelsLike: Double {
        if _feelsLike == nil {
            _feelsLike = 0.0
        }
        return _feelsLike
    }
    
    var weatherType: String {
        if _weatherType == nil {
            _weatherType = ""
        }
        return _weatherType
    }
    var pressure: Double {
        if _pressure == nil {
            _pressure = 0.0
        }
        return _pressure
    }
    var humidity: Double {
        if _humidity == nil {
            _humidity = 0.0
        }
        return _humidity
    }
    var windSpeed: Double {
        if _windSpeed == nil {
            _windSpeed = 0.0
        }
        return _windSpeed
    }
    var weatherIcon: String {
        if _weatherIcon == nil {
            _weatherIcon = ""
        }
        return _weatherIcon
    }
    var visibility: Double {
        if _visibility == nil {
            _visibility = 0.0
        }
        return _visibility
    }
    func getCurrentWeather(location: WeatherLocation ,_ completion: @escaping (Bool) -> Void) {
        var parameters : [String:String] = [:]
        if !location.isCurrentLocation {
            //%@ arguments will be replace by location.city and location.countryCode
            parameters = ["lat" : location.lat , "lon" : location.lon, "key" : "82b9df16292f41d1ace6baeac1856d20"]
        }
        else {
            parameters = ["lat" : String(LocationService.shared.latitude) , "lon" : String(LocationService.shared.longtitude), "key" : "82b9df16292f41d1ace6baeac1856d20"]
        }
        AF.request("https://api.weatherbit.io/v2.0/current",parameters: parameters).responseJSON { response in
            print("Get current weather")
            guard let result = response.value else {
                self._city = location.city
                completion(false)
                return
            }
            let json = JSON(result)
            self._city = json["data"][0]["city_name"].stringValue
            self._date = DateFromUnix(unixDate: json["data"][0]["ts"].double)
            self._weatherType = json["data"][0]["weather"]["description"].stringValue
            self._currentTemp = getTempBasedOnSettings(celcius: json["data"][0]["temp"].double ?? 0)
            self._feelsLike = json["data"][0]["app_temp"].double ?? 0
            self._pressure = json["data"][0]["pres"].double
            self._humidity = json["data"][0]["rh"].double
            self._windSpeed = json["data"][0]["wind_spd"].double
            self._weatherIcon = json["data"][0]["weather"]["icon"].stringValue
            self._visibility = json["data"][0]["vis"].double
            self._uv = json["data"][0]["uv"].double
            self._sunrise = json["data"][0]["sunrise"].stringValue
            self._sunset = json["data"][0]["sunset"].stringValue
            completion(true)
        }
    }
}

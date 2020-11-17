//
//  HourlyForecast.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
class HourlyForecast {
    private var _date: Date!
    private var _temp: Double!
    private var _weatherIcon: String!
    
    var date: Date {
        if _date == nil {
            _date = Date()
        }
        return _date
    }
    var temp: Double {
        if _temp == nil {
            _temp = 0.0
        }
        return _temp
    }
    var weatherIcon: String {
        if _weatherIcon == nil {
            _weatherIcon = ""
        }
        return _weatherIcon
    }
    
    //Create HourlyForecast instance from item inside data array of json
    init(weatherDictionary: Dictionary<String,AnyObject>) {
        //Convert dictionary to JSON
        let json = JSON(weatherDictionary)
        self._temp = getTempBasedOnSettings(celcius: json["temp"].double ?? 0.0) 
        self._date = DateFromUnix(unixDate: json["ts"].double)
        self._weatherIcon = json["weather"]["icon"].stringValue
    }
    class func downloadHourlyForecastWeather(location: WeatherLocation ,compeltion: @escaping (_ hourlyForecast: [HourlyForecast]) -> Void) {
        var parameters : [String:String] = [:]
        if !location.isCurrentLocation {
            //%@ arguments will be replace by location.city and location.countryCode
            parameters = ["lat" : location.lat , "lon" : location.lon, "key" : "ca313af990e94174bab2912d60a680ce"]
        }
        else {
            parameters = ["lat" : String(LocationService.shared.latitude) , "lon" : String(LocationService.shared.longtitude), "key" : "ca313af990e94174bab2912d60a680ce"]
        }
        var hourlyForecasts : [HourlyForecast] = []
        AF.request("https://api.weatherbit.io/v2.0/forecast/hourly?hours=24",parameters: parameters).responseJSON { (reponse) in
            guard let result = reponse.value
            else {
                compeltion(hourlyForecasts)
                return
            }
            if let dictionary = result as? Dictionary<String,AnyObject> {
                if let list = dictionary["data"] as? [Dictionary<String,AnyObject>] {
                    for item in list {
                        let hourlyForecast = HourlyForecast(weatherDictionary: item)
                        hourlyForecasts.append(hourlyForecast)
                    }
                }
            }
            compeltion(hourlyForecasts)
        }
    }
}

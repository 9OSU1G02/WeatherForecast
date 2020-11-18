//
//  WeeklyForcast.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import Foundation
import Alamofire
import SwiftyJSON
class WeeklyForecast {
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
    
    init(weatherDictionary: Dictionary<String, AnyObject>) {
        let json = JSON(weatherDictionary)
        self._temp = getTempBasedOnSettings(celcius: json["temp"].double ?? 0.0 )
        self._date = DateFromUnix(unixDate: json["ts"].double)
        self._weatherIcon = json["weather"]["icon"].stringValue
    }
    
    class func downloadWeeklyWeatherForecast(location: WeatherLocation, completion: @escaping (_ weatherForecast: [WeeklyForecast]) ->Void) {
        var parameters : [String:String] = [:]
        if !location.isCurrentLocation {
            //%@ arguments will be replace by location.city and location.countryCode
            parameters = ["lat" : location.lat , "lon" : location.lon, "key" : "d702ceb3c7484a7886917d75a3b21533"]
        }
        else {
            parameters = ["lat" : String(LocationService.shared.latitude) , "lon" : String(LocationService.shared.longtitude), "key" : "d702ceb3c7484a7886917d75a3b21533"]
        }
        var weeklyForcast : [WeeklyForecast] = []
        AF.request("https://api.weatherbit.io/v2.0/forecast/daily?days=7",parameters: parameters).responseJSON { (reponse) in
            guard let result = reponse.value
            else {
                completion(weeklyForcast)
                return
            }
            
            if let dictionary = result as? Dictionary<String,AnyObject> {
                if let list = dictionary["data"] as? [Dictionary<String,AnyObject>] {
                    for item in list {
                        let weeklyForecast = WeeklyForecast(weatherDictionary: item)
                        weeklyForcast.append(weeklyForecast)
                    }
                }
            }
            completion(weeklyForcast)
        }
    }
}

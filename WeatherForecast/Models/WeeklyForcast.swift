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
        self._temp = json["temp"].double
        self._date = DateFromUnix(unixDate: json["ts"].double)
        self._weatherIcon = json["weather"]["icon"].stringValue
    }
    
    class func downloadWeeklyWeatherForecast(completion: @escaping (_ weatherForecast: [WeeklyForecast]) ->Void) {
        var weeklyForcast : [WeeklyForecast] = []
        var parameters = ["lat" : "20.9977344", "lon" : "105.8701312", "key" : "ca313af990e94174bab2912d60a680ce"]
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

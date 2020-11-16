//
//  WeatherLocationManager.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/16/20.
//

import Foundation
class WeatherLocationManger {
    private init() {}
    static var allWeatherLocation : [WeatherLocation] {
        guard let data = UserDefaults.standard.value(forKey: KEY_LOCATIONS) as? Data else {
            fatalError("Can't get data from \(KEY_LOCATIONS) keys")
        }
        return try! PropertyListDecoder().decode([WeatherLocation].self, from: data)
    }
   
    static func saveWeatherLocationToUserDefautls(allWeatherLocation: [WeatherLocation]) {
        let _allWeatherLocation = allWeatherLocation
        UserDefaults.standard.set(try? PropertyListEncoder().encode(_allWeatherLocation), forKey: KEY_LOCATIONS)
    }
    
    static func deleteWeatherLocation(index: Int) {
        var _allWeatherLocation = allWeatherLocation
        _allWeatherLocation.remove(at: index)
        saveWeatherLocationToUserDefautls(allWeatherLocation: _allWeatherLocation)
    }
    
    static func reoderWeatherLocation(indexOfWeatherLocationToMove:Int, indexOfWeatherLocationDestination: Int) {
        var _allWeatherLocation = allWeatherLocation
        _allWeatherLocation.swapAt(indexOfWeatherLocationToMove, indexOfWeatherLocationDestination)
        saveWeatherLocationToUserDefautls(allWeatherLocation: _allWeatherLocation)
    }
}

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
    private static var _allWeatherLocation = allWeatherLocation
    static func saveWeatherLocationToUserDefautls() {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(_allWeatherLocation), forKey: KEY_LOCATIONS)
    }
    
    static func deleteWeatherLocation(index: Int) {
        _allWeatherLocation.remove(at: index)
        saveWeatherLocationToUserDefautls()
    }
    
    static func reoderWeatherLocation(indexOfWeatherLocationToMove:Int, indexOfWeatherLocationDestination: Int) {
        _allWeatherLocation.swapAt(indexOfWeatherLocationToMove, indexOfWeatherLocationDestination)
    }
}

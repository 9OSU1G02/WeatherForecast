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
    
    static func sortWeatherLocation(by sortStyle: SortStyle) {
        var _allWeatherLocation = allWeatherLocation
        switch sortStyle {
        case .userEdited:
            break
            
        case .currentLocation:
            let currentWeatherLocationIndex = _allWeatherLocation.firstIndex { (WeatherLocation) -> Bool in
                WeatherLocation.isCurrentLocation == true
            }
            _allWeatherLocation.swapAt(0, currentWeatherLocationIndex!)
            
        case .cityName,.temprature:
            //get order lat & lon of cityTempData in CityTempDataManager.allCityTempData then apply that order to lat & lon of weatherLocation in _allWeatherLocation ( because lat & lon of cityTempData is identical with lat & lon of weatherLocation )
            /*Test Code
             
             var huhuhu = ["nguyen","quoc","huy"]
             var hihihi = ["huy","quoc","nguyen"]
             for i in hihihi {
             if let index = huhuhu.firstIndex(of: i) {
             hihihi[index] = i
             }
             }
             print(hihihi)
             
             */
            for i in _allWeatherLocation {
                if let index = CityTempDataManager.allCityTempData.firstIndex(where: { (cityTempdata) -> Bool in
                    return i.lat == cityTempdata.lat && i.lon == cityTempdata.lon
                }) {
                    _allWeatherLocation[index] = i
                }
            }
        }
        saveWeatherLocationToUserDefautls(allWeatherLocation: _allWeatherLocation)
    }
}

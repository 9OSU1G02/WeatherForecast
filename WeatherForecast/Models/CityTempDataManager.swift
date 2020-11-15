//
//  CityTempDataManager.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/15/20.
//

import Foundation
class CityTempDataManager {
    static let cityTempDataManager = CityTempDataManager()
    private init () {}
    static var allCityTempData: [CityTempData] = []
    static func deletecityTempData(at index: Int) {
        allCityTempData.remove(at: index)
    }
    static func reoderCityTempData(cityTempDataToMove: CityTempData, cityTempDataAtDestination: CityTempData) {
        let destinationIndex = allCityTempData.firstIndex(of: cityTempDataAtDestination) ?? 0
        allCityTempData.removeAll(where: {$0.city == cityTempDataToMove.city && $0.temp == cityTempDataToMove.temp})
        allCityTempData.insert(cityTempDataToMove, at: destinationIndex)
    }
}
    

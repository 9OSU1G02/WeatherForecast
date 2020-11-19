//
//  CityTempDataManager.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/15/20.
//

import Foundation
class CityTempDataManager {
    private init () {}
    static var allCityTempData: [CityTempData] = []
    static func deletecityTempData(at index: Int) {
        allCityTempData.remove(at: index)
    }
    static func reoderCityTempData(IndexOfCityTempDataToMove: Int, IndexOfCityTempDataDestination: Int) {
        allCityTempData.swapAt(IndexOfCityTempDataToMove, IndexOfCityTempDataDestination)
    }
    
}
    

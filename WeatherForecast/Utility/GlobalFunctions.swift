//
//  GlobalFunctions.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import Foundation
import UIKit

//Return Date from unixDate - second from 1970 to that time
func DateFromUnix(unixDate: Double?) -> Date? {
    guard let unixDate = unixDate else {
        return Date()
    }
    return Date(timeIntervalSince1970: unixDate)
}

func getWeatherIconFor(_ type: String) -> UIImage {
    let icon = UIImage(named: type) ?? UIImage(systemName: "questionmark")!
    return icon
}

func getTempBasedOnSettings(celcius: Double) -> Double {
    let format = returnTempFormatFromUserDefaults()
    switch format {
    case .celsius:
        return celcius
    case .fahrenheit:
        return celcius.toFahrenheit()
    }
}
func returnTempFormatFromUserDefaults() -> TempFormat {
    guard let tempFormat = UserDefaults.standard.value(forKey: "TempFormat") as? Int else { return .celsius }
    return  tempFormat == 0 ? .celsius : .fahrenheit
}

func returnRawValueTempFormatIconFromUserDefaults() -> String {
    guard let tempFormatIndex = UserDefaults.standard.value(forKey: "TempFormat") as? Int
    else {
        return "℃"
        }
    let iconTempFormat = TempFormat.allCases[tempFormatIndex].rawValue.components(separatedBy: " ")
    return iconTempFormat[1]
}


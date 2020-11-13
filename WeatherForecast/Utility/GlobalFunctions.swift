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

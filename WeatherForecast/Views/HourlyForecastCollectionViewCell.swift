//
//  HourlyForecastCollectionViewCell.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

class HourlyForecastCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    func config(hourlyForecast: HourlyForecast) {
        timeLabel.text = hourlyForecast.date.time()
        weatherIconImageView.image = getWeatherIconFor(hourlyForecast.weatherIcon)
        tempLabel.text = String(format: "%.0f", hourlyForecast.temp)
    }
}

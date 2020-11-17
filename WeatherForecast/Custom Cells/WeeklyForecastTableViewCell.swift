//
//  WeeklyForecastTableViewCell.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

class WeeklyForecastTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var tempLabel: UILabel!
    
    func config(weeklyForecast : WeeklyForecast) {
        dayOfWeekLabel.text = weeklyForecast.date.dayOfTheWeek()
        weatherIconImageView.image = getWeatherIconFor(weeklyForecast.weatherIcon)
        tempLabel.text = String(format: "%.0f", weeklyForecast.temp)
    }
}

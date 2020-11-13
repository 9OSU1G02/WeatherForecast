//
//  WeatherViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

class WeatherViewController: UIViewController {
    // MARK: - Properties
    let weatherView = WeatherView()
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentWeather()
        getWeeklyWeather()
        getHourlyWeather()
    }
    override func viewDidAppear(_ animated: Bool) {
        
        weatherView.frame = CGRect(x: 0, y: 0, width: currentWeatherScrollView.frame.width, height: currentWeatherScrollView.frame.height) 
        currentWeatherScrollView.addSubview(weatherView)
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var currentWeatherScrollView: UIScrollView!
    private func getCurrentWeather () {
            weatherView.currentWeather.getCurrentWeather { (isSuccess) in
            isSuccess ? self.weatherView.refreshData() : print("Cant get current weather")
        }
    }
    
    private func getWeeklyWeather() {
        WeeklyForecast.downloadWeeklyWeatherForecast() { (weatherForecasts) in
            self.weatherView.weeklyForecastData = weatherForecasts
            self.weatherView.weeklyForecastTableView.reloadData()
        }
    }
    private func getHourlyWeather() {
        HourlyForecast.downloadHourlyForecastWeather() { (weatherForecasts) in
            self.weatherView.hourlyForecastData = weatherForecasts
            self.weatherView.hourlyForecastCollectionView.reloadData()
        }
    }
}


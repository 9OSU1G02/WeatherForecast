//
//  WeatherView.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

class WeatherView: UIView {
    // MARK: - Properties
    var currentWeather: CurrentWeather!
    var weeklyForecastData: [WeeklyForecast] = []
    var hourlyForecastData: [HourlyForecast] = []
    var weatherInfoData: [WeatherInfo] = []
    var lat:String!
    var lon:String!
    var isCurrentLocation:Bool!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var hourlyForecastCollectionView: UICollectionView!
    @IBOutlet weak var weatherInfoCollectionView: UICollectionView!
    @IBOutlet weak var weeklyForecastTableView: UITableView!
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        mainInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        mainInit()
            }
    
    //Working with xib you have to setup view manually
    private func mainInit() {
        //Get nib file
        Bundle.main.loadNibNamed("WeatherView", owner: self, options: nil)
        //Need to add mainView because WeatherView begin is just blank view
        addSubview(mainView)
        // self.bounds mean entire screen size
        mainView.frame = self.bounds
        // mainView Auto resize when superview change
        mainView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        setupHourlyForecastCollectionView()
        setupWeatherInfoCollectionView()
        setupWeeklyForecastTableView()
        
    }
    
    func refreshData() {
        setupCurrentWeather()
        setupWeatherViewInfo()
        weatherInfoCollectionView.reloadData()
    }
    
    // MARK: - Setup subView
    private func setupWeeklyForecastTableView() {
        //Register cell with table view
        weeklyForecastTableView.register(UINib(nibName: "WeeklyForecastTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "cell")
        weeklyForecastTableView.delegate = self
        weeklyForecastTableView.dataSource = self
        weeklyForecastTableView.tableFooterView = UIView()
    }
    
    private func setupHourlyForecastCollectionView() {
        hourlyForecastCollectionView.register(UINib(nibName: "HourlyForecastCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
        hourlyForecastCollectionView.dataSource = self
            }
    
    private func setupWeatherInfoCollectionView() {
        weatherInfoCollectionView.register(UINib(nibName: "WeatherInfoCollectionViewCell", bundle: Bundle.main), forCellWithReuseIdentifier: "cell")
        weatherInfoCollectionView.dataSource = self
        
    }
    
    private func setupCurrentWeather() {
        cityNameLabel.text = currentWeather.city
        dateLabel.text = "Today, \(currentWeather.date.shortDate())"
        tempLabel.text = String(format: "%.0f%@", currentWeather.currentTemp, returnRawValueTempFormatIconFromUserDefaults())
        weatherDescriptionLabel.text = currentWeather.weatherType
        }
    
    private func setupWeatherViewInfo() {
        let windInfo = WeatherInfo(infoText: "\(currentWeather.windSpeed)", image: getWeatherIconFor("wind"))
        let humidityInfo = WeatherInfo(infoText: String(format: "%.0f ", currentWeather.humidity), image: getWeatherIconFor("humidity"))
        let pressureInfo = WeatherInfo(infoText: String(format: "%.0f mb", currentWeather.pressure), image: getWeatherIconFor("pressure"))
        let visibilityInfo = WeatherInfo(infoText: String(format: "%.0f km", currentWeather.visibility), image: getWeatherIconFor("visibility"))
        let feelsLikeInfo = WeatherInfo(infoText: String(format: "%.1f", currentWeather.feelsLike), image: getWeatherIconFor("feelsLike"))
        let uvInfo = WeatherInfo(infoText: String(format: "%.1f", currentWeather.uv), image: getWeatherIconFor("uv"))
        let sunriseInfo = WeatherInfo(infoText: currentWeather.sunrise, image: getWeatherIconFor("sunrise"))
        let sunsetInfo = WeatherInfo(infoText: currentWeather.sunset, image: getWeatherIconFor("sunset"))
        weatherInfoData = [windInfo, humidityInfo, pressureInfo, visibilityInfo, feelsLikeInfo, uvInfo, sunriseInfo, sunsetInfo]
        
    }
}

// MARK: - Extension

extension WeatherView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == hourlyForecastCollectionView ? hourlyForecastData.count : weatherInfoData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == hourlyForecastCollectionView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? HourlyForecastCollectionViewCell else { fatalError() }
            cell.config(hourlyForecast: hourlyForecastData[indexPath.item])
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? WeatherInfoCollectionViewCell else { fatalError("Cannot create hourly table cell") }
            cell.config(weatherInfo: weatherInfoData[indexPath.item])
            return cell
        }
    }
}

extension WeatherView: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weeklyForecastData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? WeeklyForecastTableViewCell else {
            fatalError("Cannot create weather table cell")
        }
        cell.config(weeklyForecast: weeklyForecastData[indexPath.row])
        return cell
    }
}

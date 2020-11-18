//
//  WeatherViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit
import CoreLocation
class WeatherViewController: UIViewController {
    // MARK: - Properties
    var weatherLocation: WeatherLocation!
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D!
    var allLocations: [WeatherLocation] = []
    var allWeatherViews: [WeatherView] = []
    var shouldReload = false
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager?.delegate = self
        locationManagerStart()
        //Scroll by page
        currentWeatherScrollView.isPagingEnabled = true
        currentWeatherScrollView.delegate = self
        setUpListenForTempFormatChange()
    }
    
        override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //If shouldRefrsh = true --> remove all data and get it again by call getWeather()
        if shouldReload {
            CityTempDataManager.allCityTempData = []
            allLocations = []
            allWeatherViews = []
            removeSubViewsFromScrollView()
            getWeather()
            locationManager?.startUpdatingLocation()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManagerStop()
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var currentWeatherScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Observer
    private func setUpListenForTempFormatChange() {
        NotificationCenter.default.addObserver(forName: Notification.Name("units"), object: nil, queue: .main) { (unitParameter) in
            guard let object = unitParameter.object as? Bool else {
                return
            }
            self.shouldReload = object
        }
    }
    // MARK: - Download Weather
    private func getWeather() {
        loadLocationFromUserDefaults()
        createWeatherViews()
        addWeatherToScrollView()
        setPageControlPageNumber()
    }
    
    private func getCurrentWeather(weatherView: WeatherView, location: WeatherLocation) {
        weatherView.currentWeather = CurrentWeather()
        weatherView.currentWeather.getCurrentWeather(location: location) { (isSucces) in
            weatherView.refreshData()
            self.generateWeatherList()
        }
    }
    private func getWeeklyWeather(weatherView: WeatherView, location: WeatherLocation) {
        WeeklyForecast.downloadWeeklyWeatherForecast(location: location) { (weatherForecasts) in
            weatherView.weeklyForecastData = weatherForecasts
            weatherView.weeklyForecastTableView.reloadData()
        }
    }
    private func getHourlyWeather(weatherView: WeatherView, location: WeatherLocation) {
        HourlyForecast.downloadHourlyForecastWeather(location: location) { (weatherForecasts) in
            weatherView.hourlyForecastData = weatherForecasts
            weatherView.hourlyForecastCollectionView.reloadData()
        }
    }
    
    //Remove all subViews from currentWeatherScrollView because when getWeather trigger is will create same subviews and add to currentWeatherScrollView so we need clean old subs view first
    private func removeSubViewsFromScrollView() {
        for subview in currentWeatherScrollView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    private func createWeatherViews() {
        //Create an empty weatherView for each location
        for location in allLocations {
            let weatherView = WeatherView()
            weatherView.isCurrentLocation = location.isCurrentLocation
            allWeatherViews.append(weatherView)
        }
    }
    
    private func addWeatherToScrollView() {
        //weatherView have same index with location
        for i in 0 ..< allWeatherViews.count {
            let weatherView = allWeatherViews[i]
            let location = allLocations[i]
            
            //Get all data need to present in 1 weather view
            getCurrentWeather(weatherView: weatherView, location: location)
            getWeeklyWeather(weatherView: weatherView, location: location)
            getHourlyWeather(weatherView: weatherView, location: location)
            
            //Our scrolView is just 1 long wide view have multiple page (weahterview) next to anothor, first weatherView x postition will be 0, second x will start at view.frame.width * 1 ( next screen ), y will always be 0 because srollView is horiztontal
            //view.frame.width: entire width of screen
            let xPos = view.frame.width * CGFloat(i)
            weatherView.frame = CGRect(x: xPos, y: 0, width: currentWeatherScrollView.bounds.width, height: currentWeatherScrollView.bounds.height)
            currentWeatherScrollView.addSubview(weatherView)
            
            //currentWeatherScrollView have content width equal to how many weatherView we have ( this can just call 1 time is enought because each weatherView have same width)
            currentWeatherScrollView.contentSize.width = weatherView.frame.width * CGFloat(allWeatherViews.count)
        }
        
    }
    
    // MARK: - Load Location from user Defalt
    private func loadLocationFromUserDefaults() {
        //city, country, countryCode will be apply later
        let currentLocation = WeatherLocation(city: "", lat: "\(LocationService.shared.latitude)", lon: "\(LocationService.shared.longtitude)", country: "", contryCode: "", adminCity: "", isCurrentLocation: true)
        if let data = UserDefaults.standard.value(forKey: KEY_LOCATIONS) as? Data {
            guard var allLocations = try? PropertyListDecoder().decode([WeatherLocation].self, from: data) else { fatalError("Cannot Decode location from user default") }
            
            //Get index of currentLocation
            let indexOfCurrentLocation = allLocations.firstIndex { (weatherLocation) -> Bool in
                weatherLocation.isCurrentLocation == true
            }
            allLocations[indexOfCurrentLocation!] = currentLocation
            self.allLocations = allLocations
        }
        else {
            //No data in UserDefaults
            allLocations.append(currentLocation)
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(allLocations), forKey: "Locations")
    }
    
    // MARK: - PageControl
    private func setPageControlPageNumber() {
        pageControl.numberOfPages = allWeatherViews.count
    }
    
    private func updatePageControlSelectedPage(currentPage: Int) {
        pageControl.currentPage =  currentPage
    }
    
    // MARK: - Location Manager
    private func locationManagerStart() {
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestAlwaysAuthorization()
            locationManager!.delegate = self
        }
        //Must have to get location
        locationManager!.startUpdatingLocation()
        //Only update coordite when user move far from last coordinate
        locationManager!.startMonitoringSignificantLocationChanges()
    }
    private func locationManagerStop() {
        locationManager?.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .restricted, .denied, .notDetermined:
            locationManager?.requestAlwaysAuthorization()
            setCoordinate()
        case .authorizedAlways, .authorizedWhenInUse:
            setCoordinate()
        }
    }
    
    private func setCoordinate() {
        currentLocation = locationManager?.location?.coordinate
        if currentLocation != nil {
            //Set our coordinates
            LocationService.shared.latitude = currentLocation.latitude
            LocationService.shared.longtitude = currentLocation.longitude
            getWeather()
        }
    }
    
    // MARK: - Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Faild to get location,\(error.localizedDescription)")
    }
    
    private func generateWeatherList() {
        CityTempDataManager.allCityTempData = []
        for weatherView in allWeatherViews {
            let tempData = CityTempData(city: weatherView.currentWeather.city, temp: weatherView.currentWeather.currentTemp, isCurrentLocation: weatherView.isCurrentLocation,lat: weatherView.lat, lon: weatherView.lon)
            CityTempDataManager.allCityTempData.append(tempData)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allLocationSegue" {
            guard let vc = segue.destination as? AllLocationTableViewController else { fatalError("Can found allLocationSegue ")}
            vc.delegate = self
            }
    }
}

extension WeatherViewController: CLLocationManagerDelegate {
    
}

extension WeatherViewController: ChooseCityViewControllerDelegate {
    func didAdd(indexOffset: Int, shouldReload: Bool) {
        let viewNumber = CGFloat(integerLiteral: indexOffset)
        let newOffset = CGPoint(x: currentWeatherScrollView.frame.width * viewNumber, y: 0)
        // eg: index 1 --> currentWeatherScrollView will display at x = currentWeatherScrollView.frame.width (414) * 1 ---> x the same with x of where second wether view ---> dispay second view
        currentWeatherScrollView.setContentOffset(newOffset, animated: true)
        updatePageControlSelectedPage(currentPage: indexOffset)
        self.shouldReload = shouldReload
    }
}

extension WeatherViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //( i can't see anywhere explain this )
        let value = scrollView.contentOffset.x / scrollView.frame.size .width
        //value >= 0.5 will round up to 1
        updatePageControlSelectedPage(currentPage: Int(round(value)))
    }
}

extension WeatherViewController: AllLocationTableViewControllerDelegate {
    func didSortLocation(shouldReload: Bool) {
        self.shouldReload = shouldReload
    }
                  
    func didChooseLocation(atIndex: Int, shouldReload: Bool) {
        let viewNumber = CGFloat(integerLiteral: atIndex)
        let newOffset = CGPoint(x: currentWeatherScrollView.frame.width * viewNumber, y: 0)
        // eg: index 1 --> currentWeatherScrollView will display at x = currentWeatherScrollView.frame.width (414) * 1 ---> x the same with x of where second wether view ---> dispay second view
        currentWeatherScrollView.setContentOffset(newOffset, animated: true)
        updatePageControlSelectedPage(currentPage: atIndex)
        self.shouldReload = shouldReload
    }
}


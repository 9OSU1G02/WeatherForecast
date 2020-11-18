//
//  ChooseLocationTableViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/14/20.
//

import UIKit
protocol ChooseCityViewControllerDelegate {
    func didAdd(indexOffset: Int,shouldReload: Bool)
}
class ChooseLocationTableViewController: UITableViewController {
    // MARK: - Properties
    var savedLocations: [WeatherLocation]?
    let searchController = UISearchController(searchResultsController: nil)
    var allLocation : [WeatherLocation] = []
    var filterdLocations : [WeatherLocation] = []
    var delegate: ChooseCityViewControllerDelegate?
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchBar.delegate = self
        setupSearchController()
        loadLocationFromUserDefaults()
        loadLocationFromCSV()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadLocationFromUserDefaults()
    }
    
    // MARK: - Search Controller
    private func setupSearchController() {
        tableView.tableFooterView = UIView()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        //Don't obserures background when click on searchbar
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        //delegate of Search Controller ( updateSearchResults )
        searchController.searchResultsUpdater = self
        // FIXME:  "Does matter at current time, maybe cause a bug later"
        definesPresentationContext = true
    }
    
    // MARK: - Get Location
    
    private func loadLocationFromCSV() {
        guard let cityPath = Bundle.main.path(forResource: "city", ofType: "csv") else {
            fatalError("Cannot load location.csv file")
        }
        parseCSVAt(urls: URL(fileURLWithPath: cityPath))
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return searchController.isActive && searchController.searchBar.text != "" ? filterdLocations.count : allLocation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ChooseLocationTableViewCell else { fatalError("Cant create choose location cell")}
        let location = searchController.isActive && searchController.searchBar.text != "" ? filterdLocations[indexPath.row] : allLocation[indexPath.row]
        cell.cityName.text = location.city
        cell.countryName.text = location.country
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate = navigationController?.viewControllers[0] as! WeatherViewController
        if searchController.isActive && searchController.searchBar.text != ""   {
            if savedLocations!.contains(allLocation[indexPath.row]) || savedLocations!.contains(filterdLocations[indexPath.row]) {
                didChooseLocationIsAlreadyExist()
            }
            else {
                saveLocationToUserDefaults(location: filterdLocations[indexPath.row])
                tableView.deselectRow(at: indexPath, animated: true)
                navigationController?.popToRootViewController(animated: true)
                delegate?.didAdd(indexOffset: savedLocations!.count - 1, shouldReload: true)
            }
        }
        else {
            if savedLocations!.contains(allLocation[indexPath.row]){
                didChooseLocationIsAlreadyExist()
            }
            else {
                saveLocationToUserDefaults(location: allLocation[indexPath.row])
                tableView.deselectRow(at: indexPath, animated: true)
                navigationController?.popToRootViewController(animated: true)
                delegate?.didAdd(indexOffset: savedLocations!.count - 1, shouldReload: true)
            }
        }
    }
    
    // MARK: - Parse CSV file
    private func parseCSVAt(urls: URL) {
        
        do {
            let data = try Data(contentsOf: urls)
            let dataEncoded = String(data: data, encoding: .utf8)
            // get the line and convert to [String] by components(separatedBy: "\n")--> ["Hanoi,21.028167,105.854152,Vietnam,VN,Hà Nội" , "Haiphong,20.864807,106.683449,Vietnam,VN,Hải Phòng"] then break String element to 3 part by omponents(separatedBy: ",")
            //---> [ [Hanoi,21.028167,105.854152,Vietnam,VN,Hà Nội], [Haiphong,20.864807,106.683449,Vietnam,VN,Hải Phòng] ]
            if let dataArray = dataEncoded?.components(separatedBy: "\n").map({ $0.components(separatedBy: ",")}) {
                var i = 0
                //Skip first line ( i = 0 ) because first line useless : city,country,countryCode and line must have 3 component ( line.count > 2 )
                for line in dataArray where line.count > 2{
                    if i != 0 {
                        createLocation(line: line)
                    }
                    i += 1
                }
            }
        } catch {
            fatalError("Error reading CSV file")
        }
        
    }
    
    //line : [Araure,Venezuela,VE]
    private func createLocation(line: [String]) {
        let weatherLocation = WeatherLocation(city: line[0], lat: line[1], lon: line[2], country: line[3], contryCode: line[4], adminCity: line[5], isCurrentLocation: false)
        allLocation.append(weatherLocation)
    }
    private func didChooseLocationIsAlreadyExist() {
        tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        let alert = UIAlertController(title: nil, message: "This Location is already exist", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    // MARK: - UserDefaults
    private func saveLocationToUserDefaults(location: WeatherLocation) {
        if savedLocations != nil {
            //if savedLocations (data in userDefault) don't contain location then add location
            if !savedLocations!.contains(location) {
                savedLocations!.append(location)
            }
        }
        //if savedLocations (data in userDefault ) doesn exit
        else {
            savedLocations = [location]
        }
        //save savedLocations to user default
        WeatherLocationManger.saveWeatherLocationToUserDefautls(allWeatherLocation: savedLocations!)
    }
    
    private func loadLocationFromUserDefaults() {
        if let data = UserDefaults.standard.value(forKey: "Locations") as? Data {
            savedLocations = try? PropertyListDecoder().decode([WeatherLocation].self, from: data)
        }
    }
}

// MARK: - Extension

extension ChooseLocationTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterdLocations = allLocation.filter({ (weatherLocation) -> Bool in
            return weatherLocation.city.lowercased().contains(searchText.lowercased()) || weatherLocation.country.lowercased().contains(searchText.lowercased()) || weatherLocation.adminCity.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text ?? "")
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.dismiss(animated: true) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

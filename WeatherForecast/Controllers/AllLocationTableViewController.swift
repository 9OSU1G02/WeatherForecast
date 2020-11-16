//
//  AllLocationTableViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

protocol AllLocationTableViewControllerDelegate {
    func didChooseLocation(atIndex: Int, shouldReload: Bool)
}

enum SortStyle: Int {
    case currentLocation
    case cityName
    case temprature
}

enum Section: String, CaseIterable {
    case main
}

class AllLocationTableViewController: UITableViewController{
    func didEditRow(shouldReload: Bool) {
        self.shouldReload = shouldReload
    }
    
    // MARK: - Properties
    var dataSource: AllLocationDataSource!
    var sortStyle: SortStyle!
    var delegate: AllLocationTableViewControllerDelegate?
    var shouldReload = false
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        loadSortStyleFromUserDefaults()
        configureDataSource()
        dataSource.update(sortStyle: sortStyle)
    }
    
    // MARK: - UserDefaults
    private func saveSortStyleInUserDefaults(rawValue: Int ) {
        UserDefaults.standard.setValue(rawValue, forKey: KEY_SORT_STYLE)
    }
    
    private func loadSortStyleFromUserDefaults() {
        if let rawValue = UserDefaults.standard.value(forKey: KEY_SORT_STYLE) as? Int {
            sortStyle = SortStyle(rawValue: rawValue)
        }
        else {
            sortStyle = SortStyle.currentLocation
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var sortButtons: [UIButton]!
    
    // MARK: - IBActions
    @IBAction func sortByCurrentLocation(_ sender: UIButton) {
        dataSource.update(sortStyle: .currentLocation)
        updateTintColors(tappedButton: sender)
        saveSortStyleInUserDefaults(rawValue: 0)
        if sortStyle.rawValue != 0 {
            shouldReload = true
        }
    }
    @IBAction func sortByCityName(_ sender: UIButton) {
        dataSource.update(sortStyle: .cityName)
        updateTintColors(tappedButton: sender)
        saveSortStyleInUserDefaults(rawValue: 1)
        if sortStyle.rawValue != 1 {
            shouldReload = true
        }
    }
    @IBAction func sortByTemprature(_ sender: UIButton) {
        dataSource.update(sortStyle: .temprature)
        updateTintColors(tappedButton: sender)
        saveSortStyleInUserDefaults(rawValue: 2)
        if sortStyle.rawValue != 2 {
            shouldReload = true
        }
    }
    
    func updateTintColors(tappedButton: UIButton) {
        sortButtons.forEach { button in
            button.tintColor = button == tappedButton
                ? button.tintColor
                : .secondaryLabel
        }
    }
    
    // MARK: - DataSource
    func configureDataSource() {
        dataSource = AllLocationDataSource(tableView: tableView) {
            tableView, indexPath, cityTempData -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? AllLocationTableViewCell
            else { fatalError("Could not create BookCell") }
            cell.cityNameLabel.text = cityTempData.city
            cell.tempratureLabel.text = String(format: "%.0f", cityTempData.temp)
            cell.currentLocationIconImage.isHidden = !cityTempData.isCurrentLocation
            return cell
        }
    }
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
        delegate?.didChooseLocation(atIndex: indexPath.row, shouldReload: shouldReload)
    }
}

class AllLocationDataSource: UITableViewDiffableDataSource<Section,CityTempData> {
    
    var currentSortStyle : SortStyle = .currentLocation
    func update(sortStyle: SortStyle, animatingDifferences: Bool = true) {
        currentSortStyle = sortStyle
        var newSnapshot = NSDiffableDataSourceSnapshot<Section,CityTempData>()
        newSnapshot.appendSections(Section.allCases)
        let cityTempDataByIsCurrentLocation : [Bool: [CityTempData]] = Dictionary(grouping: CityTempDataManager.allCityTempData, by: \.isCurrentLocation)
        
        for (_, cityTempDatas) in cityTempDataByIsCurrentLocation {
            var sortedCityTempData: [CityTempData]
            switch sortStyle {
            case .currentLocation:
                sortedCityTempData = cityTempDatas
            case .cityName:
                sortedCityTempData = cityTempDatas.sorted { $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending }
            case .temprature:
                sortedCityTempData = cityTempDatas.sorted { $0.temp > $1.temp }
            }
            newSnapshot.appendItems(sortedCityTempData, toSection: .main)
        }
        
        apply(newSnapshot,animatingDifferences: animatingDifferences)
    }
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let cityTempDataToEdit = itemIdentifier(for: indexPath) {
            return !cityTempDataToEdit.isCurrentLocation
        }
        else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete cityTempData from allCityTempData
            CityTempDataManager.deletecityTempData(at: indexPath.row)
            // TODO: - Delete weatherLocation from userDefaults
            WeatherLocationManger.deleteWeatherLocation(index: indexPath.row)
            update(sortStyle: currentSortStyle)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            sourceIndexPath != destinationIndexPath,
            sourceIndexPath.section == destinationIndexPath.section
        else {
            apply(snapshot(), animatingDifferences: false)
            return
        }
        // Reoder cityTempData in allCityTempData
        CityTempDataManager.reoderCityTempData(IndexOfCityTempDataToMove: sourceIndexPath.row, IndexOfCityTempDataDestination: destinationIndexPath.row)
        // Reoder weatherLocation in userDefault
        WeatherLocationManger.reoderWeatherLocation(indexOfWeatherLocationToMove: sourceIndexPath.row, indexOfWeatherLocationDestination: destinationIndexPath.row)
        update(sortStyle: currentSortStyle, animatingDifferences: false)
    }
}


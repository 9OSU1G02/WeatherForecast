//
//  AllLocationTableViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

protocol AllLocationTableViewControllerDelegate {
    func didChooseLocation(atIndex: Int, shouldReload: Bool)
    func didSortLocation(shouldReload:Bool)
}

enum SortStyle: Int {
    case userEdited
    case currentLocation
    case cityName
    case temprature
}

enum Section: String, CaseIterable {
    case main
}

class AllLocationTableViewController: UITableViewController{
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
    override func viewDidAppear(_ animated: Bool) {
        loadSortStyleFromUserDefaults()
    }
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        delegate?.didSortLocation(shouldReload: shouldReload)
        
    }
    
    // MARK: - UserDefaults
    private func saveSortStyleInUserDefaults(rawValue: Int ) {
        UserDefaults.standard.setValue(rawValue, forKey: KEY_SORT_STYLE)
    }
    
    private func loadSortStyleFromUserDefaults() {
        if let rawValue = UserDefaults.standard.value(forKey: KEY_SORT_STYLE) as? Int {
            sortStyle = SortStyle(rawValue: rawValue)
            for i in 0..<sortButtons.count {
                // i + 1 because we have 3 button but 4 sort style
                sortButtons[i].tintColor = i + 1 == rawValue ? .white : .secondaryLabel
            }
        }
        else {
            sortStyle = SortStyle.currentLocation
            sortButtons[0].tintColor = .white
            sortButtons[1].tintColor = .secondaryLabel
            sortButtons[2].tintColor = .secondaryLabel
        }
    }
    
    
    
    // MARK: - IBOutlets
    
    @IBOutlet var sortButtons: [UIButton]!
    
    // MARK: - IBActions
    @IBAction func sortByCurrentLocation(_ sender: UIButton) {
        dataSource.update(sortStyle: .currentLocation)
        updateTintColors(tappedButton: sender)
        shouldReload = true
        saveSortStyleInUserDefaults(rawValue: 1)
    }
    @IBAction func sortByCityName(_ sender: UIButton) {
        dataSource.update(sortStyle: .cityName)
        updateTintColors(tappedButton: sender)
        shouldReload = true
        saveSortStyleInUserDefaults(rawValue: 2)
    }
    @IBAction func sortByTemprature(_ sender: UIButton) {
        dataSource.update(sortStyle: .temprature)
        updateTintColors(tappedButton: sender)
        shouldReload = true
        saveSortStyleInUserDefaults(rawValue: 3)
    }
    
    func updateTintColors(tappedButton: UIButton) {
        sortButtons.forEach { button in
            button.tintColor = button == tappedButton
                ? .white
                : .secondaryLabel
        }
    }
    
    // MARK: - DataSource
    func configureDataSource() {
        dataSource = AllLocationDataSource(tableView: tableView) {
            tableView, indexPath, cityTempData -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath) as? AllLocationTableViewCell
            else { fatalError("Could not create BookCell") }
            cell.cityNameLabel.text = cityTempData.city
            cell.tempratureLabel.text = String(format: "%.0f%@", cityTempData.temp, returnRawValueTempFormatIconFromUserDefaults())
            cell.currentLocationIconImage.isHidden = !cityTempData.isCurrentLocation
            return cell
        }
        dataSource.delegate = self
    }
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
        delegate?.didChooseLocation(atIndex: indexPath.row, shouldReload: shouldReload)
    }
    
}


extension AllLocationTableViewController: AllLocationDataSourceDelegate {
    func didChooseDeleteCurrentLocation() {
        let alert = UIAlertController(title: nil, message: "You can't delete your current location", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true, completion: nil)
    }
    
    func didEditRow(shouldReload: Bool) {
        self.shouldReload = shouldReload
    }
    
}

protocol AllLocationDataSourceDelegate {
    func didEditRow(shouldReload: Bool)
    func didChooseDeleteCurrentLocation()
}

class AllLocationDataSource: UITableViewDiffableDataSource<Section,CityTempData> {
    var delegate: AllLocationDataSourceDelegate?
    var currentSortStyle : SortStyle = .userEdited
    func update(sortStyle: SortStyle, animatingDifferences: Bool = true) {
        currentSortStyle = sortStyle
        var newSnapshot = NSDiffableDataSourceSnapshot<Section,CityTempData>()
        newSnapshot.appendSections(Section.allCases)
        switch sortStyle {
        case .userEdited:
            break
        case .currentLocation:
            let currentLocationCityTempDataIndex = CityTempDataManager.allCityTempData.firstIndex { (cityTempData) -> Bool in
                cityTempData.isCurrentLocation == true
            }
            CityTempDataManager.allCityTempData.swapAt(0, currentLocationCityTempDataIndex!)
        case .cityName:
            CityTempDataManager.allCityTempData.sort{$0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending}
        case .temprature:
            CityTempDataManager.allCityTempData.sort {$0.temp < $1.temp }
        }
        WeatherLocationManger.sortWeatherLocation(by: sortStyle)
        newSnapshot.appendItems(CityTempDataManager.allCityTempData, toSection: .main)
        apply(newSnapshot,animatingDifferences: animatingDifferences)
    }
    
    // MARK: - Delegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if itemIdentifier(for: indexPath)!.isCurrentLocation {
                delegate?.didChooseDeleteCurrentLocation()
                return
            }
            // Delete cityTempData from allCityTempData
            CityTempDataManager.deletecityTempData(at: indexPath.row)
            // TODO: - Delete weatherLocation from userDefaults
            // - 1 because
            WeatherLocationManger.deleteWeatherLocation(index: indexPath.row)
            update(sortStyle: currentSortStyle)
        }
        delegate?.didEditRow(shouldReload: true)
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
            sourceIndexPath != destinationIndexPath
        else {
            apply(snapshot(), animatingDifferences: false)
            return
        }
        // Reoder cityTempData in allCityTempData
        CityTempDataManager.reoderCityTempData(IndexOfCityTempDataToMove: sourceIndexPath.row, IndexOfCityTempDataDestination: destinationIndexPath.row)
        // Reoder weatherLocation in userDefault
        WeatherLocationManger.reoderWeatherLocation(indexOfWeatherLocationToMove: sourceIndexPath.row, indexOfWeatherLocationDestination: destinationIndexPath.row)
        update(sortStyle: .userEdited, animatingDifferences: false)
        //save user edit sort Style
        UserDefaults.standard.setValue(0, forKey: KEY_SORT_STYLE)
        delegate?.didEditRow(shouldReload: true)
    }
}


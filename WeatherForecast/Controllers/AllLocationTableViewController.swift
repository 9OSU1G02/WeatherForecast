//
//  AllLocationTableViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

enum SortStyle: Int {
    case currentLocation
    case cityName
    case temprature
}

enum Section: String, CaseIterable {
    case main
}

class AllLocationTableViewController: UITableViewController {
    // MARK: - Properties
    var dataSource: AllLocationDataSource!
    var sortStyle: SortStyle!
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem
        loadSortStyleFromUserDefaults()
        configureDataSource()
        dataSource.update(sortStyle: sortStyle)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    }
    @IBAction func sortByCityName(_ sender: UIButton) {
        dataSource.update(sortStyle: .cityName)
        updateTintColors(tappedButton: sender)
        saveSortStyleInUserDefaults(rawValue: 1)
    }
    @IBAction func sortByTemprature(_ sender: UIButton) {
        dataSource.update(sortStyle: .temprature)
        updateTintColors(tappedButton: sender)
        saveSortStyleInUserDefaults(rawValue: 2)
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
            // TODO: - Delete cityTempData from allCityTempData
            CityTempDataManager.deletecityTempData(at: indexPath.row)
            update(sortStyle: currentSortStyle)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard
          sourceIndexPath != destinationIndexPath,
          sourceIndexPath.section == destinationIndexPath.section,
          let cityTempDataToMove = itemIdentifier(for: sourceIndexPath),
          let cityTempDataAtDestination = itemIdentifier(for: destinationIndexPath)
          else {
            apply(snapshot(), animatingDifferences: false)
            return
        }
        // TODO: - Reoder cityTempData in allCityTempData
        CityTempDataManager.reoderCityTempData(cityTempDataToMove: cityTempDataToMove, cityTempDataAtDestination: cityTempDataAtDestination)
        update(sortStyle: currentSortStyle, animatingDifferences: false)
    }
}

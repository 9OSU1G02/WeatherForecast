//
//  AllLocationTableViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

enum SortStyle {
    case cityName
    case temprature
}

enum Section: String, CaseIterable {
    case currentLocation = "Your Location"
    case anotherLocation = "Another Locations"
}

class AllLocationTableViewController: UITableViewController {
    // MARK: - Properties
    var dataSource: AllLocationDataSource!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet var sortButtons: [UIButton]!
    
    // MARK: - IBActions
    @IBAction func sortByCityName(_ sender: UIButton) {
        dataSource.update(sortStyle: .cityName)
        updateTintColors(tappedButton: sender)
    }
    @IBAction func sortByTemprature(_ sender: UIButton) {
        dataSource.update(sortStyle: .temprature)
        updateTintColors(tappedButton: sender)
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
        
        cell.readMeBookmark.isHidden = !book.readMe
        return cell
      }
    }
}


class AllLocationDataSource: UITableViewDiffableDataSource<Section,CityTempData> {
    var currentSortStyle : SortStyle = .cityName
    func update(sortStyle: SortStyle, animatingDifferences: Bool = true) {
        currentSortStyle = sortStyle
        var newSnapshot = NSDiffableDataSourceSnapshot<Section,CityTempData>()
        newSnapshot.appendSections(Section.allCases)
        let cityTempDataByIsCurrentLocation : [Bool: [CityTempData]] = Dictionary(grouping: CityTempData.allCityTempData, by: \.isCurrentLocation)
        for (isCurrentLocation, cityTempDatas) in cityTempDataByIsCurrentLocation {
            var sortedCityTempData: [CityTempData]
            switch sortStyle {
            case .cityName:
                sortedCityTempData = cityTempDatas.sorted { $0.city.localizedCaseInsensitiveCompare($1.city) == .orderedAscending }
            case .temprature:
                sortedCityTempData = cityTempDatas.sorted { $0.temp > $1.temp }
            }
            newSnapshot.appendItems(sortedCityTempData, toSection: isCurrentLocation ? .currentLocation : .anotherLocation)
        }
        apply(newSnapshot,animatingDifferences: animatingDifferences)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        indexPath.section == snapshot().indexOfSection(.currentLocation) ? false : true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let cityTempData = self.itemIdentifier(for: indexPath) else { return }
            // TODO: - Delete cityTempData from allCityTempData
            
            update(sortStyle: currentSortStyle)
        }
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == snapshot().indexOfSection(.currentLocation)
        {
          return true
        } else {
          return false
        }
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
        update(sortStyle: currentSortStyle, animatingDifferences: false)
    }
}

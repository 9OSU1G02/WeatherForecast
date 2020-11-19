//
//  SettingTableViewController.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/17/20.
//

import UIKit


class SettingTableViewController: UITableViewController {
    // MARK: - Properties
    
    var shouldReload = false
    var currentIndexTempFormat: Int!
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        loadTempFormatFromUserDefaults()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadTempFormatFromUserDefaults()
    }
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TempFormat.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath)
        let cellText = TempFormat.allCases[indexPath.row].rawValue.components(separatedBy: " ")
        cell.textLabel?.text = cellText[0]
        cell.detailTextLabel?.text = cellText[1]
        if indexPath.row == currentIndexTempFormat {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Remove all checkmark
        tableView.visibleCells.forEach { (cell) in
            cell.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        if indexPath.row != currentIndexTempFormat {
            updateTempFormatInUserDefaults(newValue: indexPath.row)
            NotificationCenter.default.post(name: Notification.Name(NOTIFICATION_TEMP_FORMAT), object: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    private func updateTempFormatInUserDefaults(newValue: Int) {
        shouldReload = true
        UserDefaults.standard.set(newValue,forKey: KEY_TEMP_FORMAT)
    }
    
    private func loadTempFormatFromUserDefaults() {
        if let indexTempFormat = UserDefaults.standard.value(forKey: KEY_TEMP_FORMAT) as? Int {
            currentIndexTempFormat = indexTempFormat
        }
        else {
            currentIndexTempFormat = 0
        }
    }
    
}

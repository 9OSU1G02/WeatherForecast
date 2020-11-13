//
//  WeatherInfoCollectionViewCell.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/13/20.
//

import UIKit

class WeatherInfoCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoImageView: UIImageView!
    func config (weatherInfo : WeatherInfo) {
        infoLabel.text = weatherInfo.infoText
        infoImageView.image = weatherInfo.image
    }
}

//
//  AllLocationTableViewCell.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/14/20.
//

import UIKit

class AllLocationTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var currentLocationIconImage: UIImageView!
}

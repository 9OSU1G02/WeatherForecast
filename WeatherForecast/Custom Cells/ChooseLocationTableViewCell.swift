//
//  ChooseLocationTableViewCell.swift
//  WeatherForecast
//
//  Created by Nguyen Quoc Huy on 11/14/20.
//

import UIKit

class ChooseLocationTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var countryName: UILabel!
    
    
}

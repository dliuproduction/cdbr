//
//  ParameterCell.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-21.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit

class ParameterCell: UITableViewCell {

    @IBOutlet weak var telephoneOutlet: UILabel!
    @IBOutlet weak var operatorNameOutlet: UILabel!
    @IBOutlet weak var locationOutlet: UILabel!
    @IBOutlet weak var ownerNameOutlet: UILabel!
    @IBOutlet weak var charityNameOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        telephoneOutlet.adjustsFontSizeToFitWidth = true
        operatorNameOutlet.adjustsFontSizeToFitWidth = true
        locationOutlet.adjustsFontSizeToFitWidth = true
        ownerNameOutlet.adjustsFontSizeToFitWidth = true
        charityNameOutlet.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    
}

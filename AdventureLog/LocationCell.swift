//
//  LocationCell.swift
//  AdventureLog
//
//  Created by Zachary Cooper on 11/1/20.
//

import Foundation;
import UIKit;

class LocationCell : UITableViewCell {
    
    var loc: Location? = nil;
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var city: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}

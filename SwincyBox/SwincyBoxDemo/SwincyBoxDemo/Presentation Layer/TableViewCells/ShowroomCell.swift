//
//  ShowroomCell.swift
//  SwincyBoxDemo
//
//  Created by Matthew Paul Harding on 24/06/2022.
//

import UIKit

class ShowroomCell: UITableViewCell {

    @IBOutlet var brandNameLabel: UILabel?
    @IBOutlet var availableCarsLabel: UILabel?
    @IBOutlet var onDisplayLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

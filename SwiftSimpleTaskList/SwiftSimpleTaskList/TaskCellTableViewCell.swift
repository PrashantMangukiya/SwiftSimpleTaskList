//
//  TaskCellTableViewCell.swift
//  SwiftSimpleTaskList
//
//  Created by Prashant on 04/09/15.
//  Copyright (c) 2015 PrashantKumar Mangukiya. All rights reserved.
//

import UIKit

// custom class for table view cell
class TaskCellTableViewCell: UITableViewCell {

    // task color preview box
    @IBOutlet var colorPreview: UIView!
    
    // task title
    @IBOutlet var Title: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // make color preview box circle
        self.colorPreview.layer.cornerRadius = self.colorPreview.frame.width/2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }

}

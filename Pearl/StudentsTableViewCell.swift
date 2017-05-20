//
//  StudentsTableViewCell.swift
//  Pearl
//
//  Created by Jasen Henderson on 5/18/17.
//  Copyright © 2017 Otter. All rights reserved.
//

import UIKit

class StudentsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var studentNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

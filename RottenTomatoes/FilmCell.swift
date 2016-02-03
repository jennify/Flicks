//
//  FilmCell.swift
//  RottenTomatoes
//
//  Created by Jennifer Lee on 2/2/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit

class FilmCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var overviewText: UITextView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!


}

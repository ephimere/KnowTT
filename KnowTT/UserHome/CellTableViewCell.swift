//
//  CellTableViewCell.swift
//  KnowTT
//
//  Created by Cris Gomez Lopez on 26/11/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit


class CellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var noteContent: UILabel!
    @IBOutlet weak var distance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

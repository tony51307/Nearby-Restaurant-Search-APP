//
//  DetailTableViewCell.swift
//  Restaurant_Search_Machine
//
//  Created by mac03 on 2020/6/5.
//  Copyright © 2020 mac03. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var shopName: UILabel!
    @IBOutlet weak var detail: UILabel!
    
    @IBOutlet var rate: UILabel!
    @IBOutlet var address: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

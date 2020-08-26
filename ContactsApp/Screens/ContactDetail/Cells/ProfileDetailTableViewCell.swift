//
//  ProfileDetailTableViewCell.swift
//  ContactsApp
//
//  Created by Siroson on 2020-08-26.
//  Copyright © 2020 Siroson. All rights reserved.
//

import UIKit

class ProfileDetailTableViewCell: UITableViewCell {
    
    static let identifier = "ProfileDetailTableViewCell"
    
    @IBOutlet weak var placeholderLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

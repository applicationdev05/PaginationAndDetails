//
//  UserCell.swift
//  PaginationAndDetails
//
//  Created by Rajat Pandya on 25/04/24.
//

import UIKit

final class UserCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    static let cellIdentifier: String = "UserCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // Configure the cell with the model
    func configure(with model: User) {
        self.titleLabel.text = model.title.capitalized
        self.idLabel.text = "user id: \(model.id)"
    }
    
    
}

//
//  MenuTableViewCell.swift
//
//
//  Created by Randy Ting on 10/8/15.
//
//

import UIKit

class MenuTableViewCell: UITableViewCell {
  
  override func awakeFromNib() {
    super.awakeFromNib()
    layoutMargins = UIEdgeInsetsZero
    preservesSuperviewLayoutMargins = false
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}

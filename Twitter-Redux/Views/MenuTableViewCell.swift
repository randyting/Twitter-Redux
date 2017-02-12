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
    layoutMargins = UIEdgeInsets.zero
    preservesSuperviewLayoutMargins = false
  }
}

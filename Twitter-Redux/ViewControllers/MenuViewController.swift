//
//  MenuViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/8/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol MenuViewControllerDelegate {
  @objc optional func menuViewController(_ menuViewController: MenuViewController, selectedViewController: UIViewController)
}

class MenuViewController: UIViewController {
  
  // MARK: - Constants
  let cellReuseIdentifier = "com.randy.menuCellReuseIdentifer"
  
  // MARK: - Xib Objects
  @IBOutlet fileprivate weak var menuTableView: UITableView!
  
  // MARK: - Class Static Constants
  struct Constants {
    static let menuWidth = CGFloat(250)
  }
  
  // MARK: - Instance Variables
  weak var delegate: AnyObject?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupTableView(menuTableView)
  }
  
  // MARK: - Initial Setup
  fileprivate func setupTableView(_ tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    let menuTableViewCellNib = UINib(nibName: "MenuTableViewCell", bundle: nil)
    tableView.register(menuTableViewCellNib, forCellReuseIdentifier: cellReuseIdentifier)
    tableView.separatorInset = UIEdgeInsets.zero
    
    tableView.backgroundColor = UIColor.lightGray
    
    let footerView = UIView(frame: CGRect.zero)
        tableView.tableFooterView = footerView
  }
  
  fileprivate func setupNavigationBar() {
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(logoutUser(_:)))
  }
  
  // MARK: - Behavior
  func logoutUser(_ sender: UIBarButtonItem) {
    UserManager.sharedInstance.currentUser?.logout()
    NotificationCenter.default.post(name: Notification.Name(rawValue: userDidLogoutNotification), object: self)
  }
}

// MARK: - TableViewDelegate and TableViewDatasource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = menuTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
    
    cell.textLabel!.text = MenuVCManager.sharedInstance.vcTitleArray[indexPath.row]
    cell.imageView!.image = MenuVCManager.sharedInstance.vcImageArray[indexPath.row]
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    
    if UserManager.sharedInstance.currentUser != nil {
      delegate?.menuViewController?(self, selectedViewController: MenuVCManager.sharedInstance.vcArray[indexPath.row])
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MenuVCManager.sharedInstance.vcArray.count
  }
  
}

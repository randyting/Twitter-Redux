//
//  MenuViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/8/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol MenuViewControllerDelegate {
  optional func menuViewController(menuViewController: MenuViewController, selectedViewController: UIViewController)
}

class MenuViewController: UIViewController {
  
  // MARK: - Constants
  let cellReuseIdentifier = "com.randy.menuCellReuseIdentifer"
  
  // MARK: - Xib Objects
  @IBOutlet private weak var menuTableView: UITableView!
  
  // MARK: - Class Static Constants
  struct Constants {
    static let menuWidth = CGFloat(250)
  }
  
  // MARK: - Instance Variables
  weak var delegate: AnyObject?
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logoutUser:")
    
    setupTableView(menuTableView)
  }
  
  // MARK: - Initial Setup
  private func setupTableView(tableView: UITableView) {
    tableView.delegate = self
    tableView.dataSource = self
    let menuTableViewCellNib = UINib(nibName: "MenuTableViewCell", bundle: nil)
    tableView.registerNib(menuTableViewCellNib, forCellReuseIdentifier: cellReuseIdentifier)
  }
  
  // MARK: - Behavior
  func logoutUser(sender: UIBarButtonItem){
    UserManager.sharedInstance.currentUser?.logout()
    NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: self)
  }
}

// MARK: - TableViewDelegate and TableViewDatasource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = menuTableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
    
    cell.textLabel!.text = MenuVCManager.sharedInstance.vcTitleArray[indexPath.row]
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if UserManager.sharedInstance.currentUser != nil {
      delegate?.menuViewController?(self, selectedViewController: MenuVCManager.sharedInstance.vcArray[indexPath.row])
    }
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MenuVCManager.sharedInstance.vcArray.count
  }
  
}


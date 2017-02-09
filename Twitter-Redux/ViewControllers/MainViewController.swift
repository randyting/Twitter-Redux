//
//  MainViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/8/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
  
  // MARK: - Constants
  fileprivate let containerShownXConstraintValue = CGFloat(0)
  fileprivate let containerHiddenXConstraintValue = MenuViewController.Constants.menuWidth
  
  // MARK: - Xib Objects
  @IBOutlet weak var containerView: UIView!
  @IBOutlet fileprivate weak var containerViewCenterXConstraint: NSLayoutConstraint!
  
  // MARK: - Instance Variables
  fileprivate var beganPanGestureContainerCenterX: CGFloat!
  fileprivate var containerVelocity: CGFloat!
  fileprivate var containerShouldMove = false
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupShadowBehindView(containerView)
    setupObservers()
    containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(MainViewController.onContainerViewPanGesture(_:))))
  }
  
  // MARK: - Setup
  fileprivate func setupObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onUserLogin(_:)), name: NSNotification.Name(rawValue: userDidLoginNotification), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.onUserLogout(_:)), name: NSNotification.Name(rawValue: userDidLogoutNotification), object: nil)
  }
  
  fileprivate func setupShadowBehindView(_ view: UIView) {
    view.layer.masksToBounds = false
    view.layer.shadowOffset = CGSize(width: -5, height: 0)
    view.layer.shadowRadius = 5
    view.layer.shadowOpacity = 0.5
  }
  
  // MARK: - Behavior
  func onUserLogin(_ notification: Notification) {
    selectViewController(MenuVCManager.sharedInstance.vcArray[0])
  }
  
  func onUserLogout(_ notification: Notification) {
    let loginVC = TwitterLoginViewController()
    selectViewController(loginVC)
  }
  
  func onContainerViewPanGesture(_ sender: UIPanGestureRecognizer) {
    
    let state = sender.state
    
    switch state {
    case .began:
      beganPanGestureContainerCenterX = containerViewCenterXConstraint.constant
    case .changed:
      containerVelocity = sender.velocity(in: view).x
      moveContainerView(withTranslation: sender.translation(in: view))
    case .ended:
      if containerShouldMove {
        if containerVelocity >= 0 {
          hideContainerView()
        } else {
          showContainerView()
        }
        containerShouldMove = false
      }
    case .cancelled:
      containerViewCenterXConstraint.constant = beganPanGestureContainerCenterX
    case .possible:
      break
    case .failed:
      break
    }
  }
  
  fileprivate func moveContainerView(withTranslation translation: CGPoint) {
    if containerViewCenterXConstraint.constant >= containerShownXConstraintValue &&
      containerViewCenterXConstraint.constant <= containerHiddenXConstraintValue {
      containerViewCenterXConstraint.constant = beganPanGestureContainerCenterX + translation.x
      
      if containerViewCenterXConstraint.constant < containerShownXConstraintValue {
        containerViewCenterXConstraint.constant = containerShownXConstraintValue
      } else if containerViewCenterXConstraint.constant > containerHiddenXConstraintValue {
        containerViewCenterXConstraint.constant = containerHiddenXConstraintValue
      }
      containerShouldMove = true
    }
  }
  
  fileprivate func hideContainerView() {
    UIView.animate(withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 1.0,
      options: UIViewAnimationOptions(),
      animations: { () -> Void in
        self.containerViewCenterXConstraint.constant = self.containerHiddenXConstraintValue
        self.view.layoutIfNeeded()
      }, completion: nil)
  }
  
  fileprivate func showContainerView() {
    UIView.animate(withDuration: 0.5,
      delay: 0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 1.0,
      options: UIViewAnimationOptions(),
      animations: { () -> Void in
        self.containerViewCenterXConstraint.constant = self.containerShownXConstraintValue
        self.view.layoutIfNeeded()
      }, completion: nil)
  }
  
  func selectViewController(_ selectedViewController: UIViewController) {
    
    if let currentViewController = MenuVCManager.sharedInstance.currentViewController {
      currentViewController.willMove(toParentViewController: nil)
      currentViewController.view.removeFromSuperview()
      currentViewController.removeFromParentViewController()
    }
    self.addChildViewController(selectedViewController)
    selectedViewController.view.frame = containerView.bounds
    selectedViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    containerView.addSubview(selectedViewController.view)
    selectedViewController.didMove(toParentViewController: self)
    
    MenuVCManager.sharedInstance.currentViewController = selectedViewController
    showContainerView()
  }
  
  // MARK: - Deinit
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
}

// MARK: - MenuViewController Delegate
extension MainViewController: MenuViewControllerDelegate {
  func menuViewController(_ menuViewController: MenuViewController, selectedViewController: UIViewController) {
    selectViewController(selectedViewController)
    showContainerView()
  }
}

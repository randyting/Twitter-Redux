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
  let containerShownXConstraintValue = CGFloat(0)
  let containerHiddenXConstraintValue = MenuViewController.Constants.menuWidth
  
  // MARK: - Xib Objects
  @IBOutlet weak var containerView: UIView!
  @IBOutlet private weak var containerViewCenterXConstraint: NSLayoutConstraint!
  
  
  // MARK: - Instance Variables
  private var beganPanGestureContainerCenterX: CGFloat!
  private var containerVelocity: CGFloat!
  private var containerShouldMove = false
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupObservers()
    containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onContainerViewPanGesture:"))
  }
  
  // MARK: - Setup
  private func setupObservers() {
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "onUserLogin:", name: userDidLoginNotification, object: nil)
  }
  
  // MARK: - Behavior
  func onUserLogin(notification: NSNotification){
    selectViewController(MenuVCManager.sharedInstance.vcArray[0])
  }

  func onContainerViewPanGesture(sender: UIPanGestureRecognizer) {
    
    let state = sender.state
    
    switch state {
    case .Began:
      beganPanGestureContainerCenterX = containerViewCenterXConstraint.constant
    case .Changed:
      containerVelocity = sender.velocityInView(view).x
      
      if (containerViewCenterXConstraint.constant >= containerShownXConstraintValue &&
        containerViewCenterXConstraint.constant <= containerHiddenXConstraintValue){
          containerViewCenterXConstraint.constant = beganPanGestureContainerCenterX + sender.translationInView(view).x
          
          if containerViewCenterXConstraint.constant < containerShownXConstraintValue {
            containerViewCenterXConstraint.constant = containerShownXConstraintValue
          } else if containerViewCenterXConstraint.constant > containerHiddenXConstraintValue {
            containerViewCenterXConstraint.constant = containerHiddenXConstraintValue
          }
          containerShouldMove = true
      }
    case .Ended:
      if containerShouldMove {
        if containerVelocity >= 0 {
          hideContainerView()
        } else {
          showContainerView()
        }
        containerShouldMove = false
      }
    case .Cancelled:
      containerViewCenterXConstraint.constant = beganPanGestureContainerCenterX
    case .Possible:
      break
    case .Failed:
      break
    }
  }
  
  private func hideContainerView(){
    UIView.animateWithDuration(0.5,
      delay: 0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 1.0,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
        self.containerViewCenterXConstraint.constant = self.containerHiddenXConstraintValue
        self.view.layoutIfNeeded()
      }, completion: nil)
  }
  
  private func showContainerView(){
    UIView.animateWithDuration(0.5,
      delay: 0,
      usingSpringWithDamping: 1.0,
      initialSpringVelocity: 1.0,
      options: UIViewAnimationOptions.CurveEaseInOut,
      animations: { () -> Void in
        self.containerViewCenterXConstraint.constant = self.containerShownXConstraintValue
        self.view.layoutIfNeeded()
      }, completion: nil)
  }
  
  func selectViewController(selectedViewController: UIViewController) {
    
    if let currentViewController = MenuVCManager.sharedInstance.currentViewController {
      currentViewController.willMoveToParentViewController(nil)
      currentViewController.view.removeFromSuperview()
      currentViewController.removeFromParentViewController()
    }
    self.addChildViewController(selectedViewController)
    selectedViewController.view.frame = containerView.bounds
    selectedViewController.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
    containerView.addSubview(selectedViewController.view)
    selectedViewController.didMoveToParentViewController(self)
    
    MenuVCManager.sharedInstance.currentViewController = selectedViewController
  }
  
  // MARK: - Deinit
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
}

// MARK: - MenuViewController Delegate
extension MainViewController: MenuViewControllerDelegate {
  func menuViewController(menuViewController: MenuViewController, selectedViewController: UIViewController) {
    selectViewController(selectedViewController)
    showContainerView()
  }
}

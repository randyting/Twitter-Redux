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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onContainerViewPanGesture:"))
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                    UIView.animateWithDuration(0.5,
                        delay: 0,
                        usingSpringWithDamping: 1.0,
                        initialSpringVelocity: 1.0,
                        options: UIViewAnimationOptions.CurveEaseInOut,
                        animations: { () -> Void in
                            self.containerViewCenterXConstraint.constant = self.containerHiddenXConstraintValue
                            self.view.layoutIfNeeded()
                        }, completion: nil)
                } else {
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        self.containerViewCenterXConstraint.constant = self.containerShownXConstraintValue
                    })
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
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

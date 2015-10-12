//
//  TwitterUserProfileViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/10/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterUserProfileViewController: UIViewController {
  
  @IBOutlet private weak var profileScrollView: UIScrollView!
  @IBOutlet private weak var contentView: UIView!
  @IBOutlet private weak var leftBackgroundImageView: UIImageView!
  @IBOutlet private weak var rightBackgroundImageView: UIImageView!
  @IBOutlet private weak var profileImageView: UIImageView!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var userScreennameLabel: UILabel!
  @IBOutlet private weak var userDescriptionLabel: UILabel!
  @IBOutlet private weak var pageControl: UIPageControl!
  @IBOutlet private weak var statusCountLabel: UILabel!
  @IBOutlet private weak var friendsCountLabel: UILabel!
  @IBOutlet private weak var followerCountLabel: UILabel!
  @IBOutlet private weak var statusCountContainerView: UIView!
  @IBOutlet private weak var friendsCountContainerView: UIView!
  @IBOutlet private weak var followerCountContainerView: UIView!
  
  @IBOutlet private weak var profileScrollViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var contentViewHeightConstraint: NSLayoutConstraint!
  
  private var backgroundImage: UIImage?
  private var beganPanGestureViewHeightY: CGFloat!
  var user: TwitterUser!
  
  override func viewDidLoad() {
    
    edgesForExtendedLayout = .None
    
    if user == UserManager.sharedInstance.currentUser {
      setupNavigationBar()
    }
    setupAppearance()
    setupPaging()
    setupInitialValues()
    setupGestureRecognizer()
  }
  
  private func setupNavigationBar(){
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "compose"), style: .Plain, target: self, action: "createNewTweet:")
    if user == UserManager.sharedInstance.currentUser {
      self.title = "Me"
    } else {
      self.title = user.name
    }
  }
  
  private func setupAppearance(){
    statusCountContainerView.layer.borderWidth = 0.5
    statusCountContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
    friendsCountContainerView.layer.borderWidth = 0.5
    friendsCountContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
    followerCountContainerView.layer.borderWidth = 0.5
    followerCountContainerView.layer.borderColor = UIColor.lightGrayColor().CGColor
    
    profileImageView.layer.cornerRadius = 4.0
    profileImageView.clipsToBounds = true
  }
  
  private func setupInitialValues(){
    leftBackgroundImageView.setImageWithURL(NSURL(string: user.profileBannerImageURLString ?? user.profileBackgroundImageURLString))
    rightBackgroundImageView.setImageWithURL(NSURL(string: user.profileBannerImageURLString ?? user.profileBackgroundImageURLString))
    profileImageView.setImageWithURL(NSURL(string: user.profileImageURLString))
    userNameLabel.text = user.name
    userScreennameLabel.text = "@ \(user.screenname)"
    userDescriptionLabel.text = user.userDescription
    statusCountLabel.text = String(user.statusesCount)
    friendsCountLabel.text = String(user.friendsCount)
    followerCountLabel.text = String(user.followersCount)
  }
  
  private func setupPaging(){
    profileScrollView.delegate = self
    profileScrollView.pagingEnabled = true
    profileScrollView.showsHorizontalScrollIndicator = false
  }
  
  private func setupGestureRecognizer() {
    let blurGestureRecognizer = UIPanGestureRecognizer(target: self, action: "onPanGesture:")
    blurGestureRecognizer.delegate = self
    view.addGestureRecognizer(blurGestureRecognizer)
  }
  
  func onPanGesture(sender: UIPanGestureRecognizer) {
    
    switch sender.state {
    case .Began:
      beganPanGestureViewHeightY = profileScrollViewHeightConstraint.constant
      backgroundImage = leftBackgroundImageView.image
    case .Cancelled:
      break
    case .Changed:
      if sender.translationInView(view).y > 0 {
        profileScrollViewHeightConstraint.constant = beganPanGestureViewHeightY + sender.translationInView(view).y
        contentViewHeightConstraint.constant = beganPanGestureViewHeightY + sender.translationInView(view).y
        leftBackgroundImageView.image = backgroundImage?.blurredImageWithRadius(abs(sender.translationInView(view).y), iterations: 2, tintColor: nil)
        rightBackgroundImageView.image = leftBackgroundImageView.image
      }
    case .Ended:
      UIView.animateWithDuration(0.5,
        delay: 0,
        usingSpringWithDamping: 1.0,
        initialSpringVelocity: 1.0,
        options: UIViewAnimationOptions.CurveEaseInOut,
        animations: { () -> Void in
          self.profileScrollViewHeightConstraint.constant = self.beganPanGestureViewHeightY
          self.contentViewHeightConstraint.constant = self.beganPanGestureViewHeightY
          self.leftBackgroundImageView.image = self.backgroundImage
          self.rightBackgroundImageView.image = self.backgroundImage
          self.view.layoutIfNeeded()
        }, completion: nil)
    case .Failed:
      break
    case .Possible:
      break
    }
  }
  
  func createNewTweet(sender: UIBarButtonItem) {
    NewTweetViewController.presentNewTweetVCInReplyToTweet(nil, forViewController: self)
  }
  
  @IBAction func pageControlDidPage(sender: UIPageControl) {
    let xOffset = profileScrollView.bounds.width * CGFloat(pageControl.currentPage)
    profileScrollView.setContentOffset(CGPointMake(xOffset,0) , animated: true)
  }
  
}

extension TwitterUserProfileViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    // Respond only if gesture is a vertical gesture
    let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocityInView(view)
    return fabs(velocity.y) > fabs(velocity.x)
  }
}

extension TwitterUserProfileViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
  }
}

extension TwitterUserProfileViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  func newTweetViewController(newTweetViewController: NewTweetViewController, didPostTweetText: String) {
    dismissViewControllerAnimated(true, completion: nil)
  }
}
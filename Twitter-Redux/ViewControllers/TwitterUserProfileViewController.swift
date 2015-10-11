//
//  TwitterUserProfileViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/10/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterUserProfileViewController: UIViewController {
  
  @IBOutlet weak var profileScrollView: UIScrollView!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var leftBackgroundImageView: UIImageView!
  @IBOutlet weak var rightBackgroundImageView: UIImageView!
  @IBOutlet weak var profileImageView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userScreennameLabel: UILabel!
  @IBOutlet weak var userDescriptionLabel: UILabel!
  @IBOutlet weak var pageControl: UIPageControl!
  @IBOutlet weak var statusCountLabel: UILabel!
  @IBOutlet weak var friendsCountLabel: UILabel!
  @IBOutlet weak var followerCountLabel: UILabel!
  @IBOutlet weak var statusCountContainerView: UIView!
  @IBOutlet weak var friendsCountContainerView: UIView!
  @IBOutlet weak var followerCountContainerView: UIView!
  
  @IBOutlet weak var profileScrollViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
  
  var backgroundImage: UIImage?
  
  var beganPanGestureViewHeightY: CGFloat!
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
    let newTweetButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "createNewTweet:")
    navigationItem.rightBarButtonItem = newTweetButton
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
    view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: "onPanGesture:"))
  }
  
  func onPanGesture(sender: UIPanGestureRecognizer) {
    
    switch sender.state {
    case .Began:
      beganPanGestureViewHeightY = profileScrollViewHeightConstraint.constant
      backgroundImage = leftBackgroundImageView.image
    case .Cancelled:
      break
    case .Changed:
      profileScrollViewHeightConstraint.constant = beganPanGestureViewHeightY + sender.translationInView(view).y
      contentViewHeightConstraint.constant = beganPanGestureViewHeightY + sender.translationInView(view).y
      leftBackgroundImageView.image = backgroundImage?.blurredImageWithRadius(abs(sender.translationInView(view).y), iterations: 2, tintColor: nil)
      rightBackgroundImageView.image = leftBackgroundImageView.image
    case .Ended:
      UIView.animateWithDuration(0.5,
        delay: 0,
        usingSpringWithDamping: 1.0,
        initialSpringVelocity: 1.0,
        options: UIViewAnimationOptions.CurveEaseInOut,
        animations: { () -> Void in
          self.profileScrollViewHeightConstraint.constant = self.beganPanGestureViewHeightY
          self.contentViewHeightConstraint.constant = self.beganPanGestureViewHeightY
          self.view.layoutIfNeeded()
        }, completion: { (Bool) -> Void in
          self.leftBackgroundImageView.image = self.backgroundImage
          self.rightBackgroundImageView.image = self.leftBackgroundImageView.image
      })
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
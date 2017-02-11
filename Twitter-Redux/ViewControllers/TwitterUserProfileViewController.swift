//
//  TwitterUserProfileViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/10/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

class TwitterUserProfileViewController: UIViewController {
  
  @IBOutlet fileprivate weak var profileScrollView: UIScrollView!
  @IBOutlet fileprivate weak var contentView: UIView!
  @IBOutlet fileprivate weak var leftBackgroundImageView: UIImageView!
  @IBOutlet fileprivate weak var rightBackgroundImageView: UIImageView!
  @IBOutlet fileprivate weak var profileImageView: UIImageView!
  @IBOutlet fileprivate weak var userNameLabel: UILabel!
  @IBOutlet fileprivate weak var userScreennameLabel: UILabel!
  @IBOutlet fileprivate weak var userDescriptionLabel: UILabel!
  @IBOutlet fileprivate weak var pageControl: UIPageControl!
  @IBOutlet fileprivate weak var statusCountLabel: UILabel!
  @IBOutlet fileprivate weak var friendsCountLabel: UILabel!
  @IBOutlet fileprivate weak var followerCountLabel: UILabel!
  @IBOutlet fileprivate weak var statusCountContainerView: UIView!
  @IBOutlet fileprivate weak var friendsCountContainerView: UIView!
  @IBOutlet fileprivate weak var followerCountContainerView: UIView!
  
  @IBOutlet fileprivate weak var profileScrollViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var contentViewHeightConstraint: NSLayoutConstraint!
  
  fileprivate var backgroundImage: UIImage?
  fileprivate var beganPanGestureViewHeightY: CGFloat!
  var user: TwitterUser!
  
  override func viewDidLoad() {
    
    edgesForExtendedLayout = UIRectEdge()
    
    if user == UserManager.sharedInstance.currentUser {
      setupNavigationBar()
    }
    setupAppearance()
    setupPaging()
    setupInitialValues()
    setupGestureRecognizer()
  }
  
  fileprivate func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "compose"), style: .plain, target: self, action: #selector(TwitterUserProfileViewController.createNewTweet(_:)))
    if user == UserManager.sharedInstance.currentUser {
      self.title = "Me"
    } else {
      self.title = user.name
    }
  }
  
  fileprivate func setupAppearance() {
    statusCountContainerView.layer.borderWidth = 0.5
    statusCountContainerView.layer.borderColor = UIColor.lightGray.cgColor
    friendsCountContainerView.layer.borderWidth = 0.5
    friendsCountContainerView.layer.borderColor = UIColor.lightGray.cgColor
    followerCountContainerView.layer.borderWidth = 0.5
    followerCountContainerView.layer.borderColor = UIColor.lightGray.cgColor
    
    profileImageView.layer.cornerRadius = 4.0
    profileImageView.clipsToBounds = true
  }
  
  fileprivate func setupInitialValues() {
    leftBackgroundImageView.setImageWith(URL(string: user.profileBannerImageURLString ?? user.profileBackgroundImageURLString))
    rightBackgroundImageView.setImageWith(URL(string: user.profileBannerImageURLString ?? user.profileBackgroundImageURLString))
    profileImageView.setImageWith(URL(string: user.profileImageURLString))
    userNameLabel.text = user.name
    userScreennameLabel.text = "@ \(user.screenname)"
    userDescriptionLabel.text = user.userDescription
    statusCountLabel.text = String(user.statusesCount)
    friendsCountLabel.text = String(user.friendsCount)
    followerCountLabel.text = String(user.followersCount)
  }
  
  fileprivate func setupPaging() {
    profileScrollView.delegate = self
    profileScrollView.isPagingEnabled = true
    profileScrollView.showsHorizontalScrollIndicator = false
  }
  
  fileprivate func setupGestureRecognizer() {
    let blurGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TwitterUserProfileViewController.onPanGesture(_:)))
    blurGestureRecognizer.delegate = self
    view.addGestureRecognizer(blurGestureRecognizer)
  }
  
  func onPanGesture(_ sender: UIPanGestureRecognizer) {
    
    switch sender.state {
    case .began:
      beganPanGestureViewHeightY = profileScrollViewHeightConstraint.constant
      backgroundImage = leftBackgroundImageView.image
    case .cancelled:
      break
    case .changed:
      if sender.translation(in: view).y > 0 {
        profileScrollViewHeightConstraint.constant = beganPanGestureViewHeightY + sender.translation(in: view).y
        contentViewHeightConstraint.constant = beganPanGestureViewHeightY + sender.translation(in: view).y
        leftBackgroundImageView.image = backgroundImage?.blurredImage(withRadius: abs(sender.translation(in: view).y), iterations: 2, tintColor: nil)
        rightBackgroundImageView.image = leftBackgroundImageView.image
      }
    case .ended:
      UIView.animate(withDuration: 0.5,
        delay: 0,
        usingSpringWithDamping: 1.0,
        initialSpringVelocity: 1.0,
        options: UIViewAnimationOptions(),
        animations: { () -> Void in
          self.profileScrollViewHeightConstraint.constant = self.beganPanGestureViewHeightY
          self.contentViewHeightConstraint.constant = self.beganPanGestureViewHeightY
          self.leftBackgroundImageView.image = self.backgroundImage
          self.rightBackgroundImageView.image = self.backgroundImage
          self.view.layoutIfNeeded()
        }, completion: nil)
    case .failed:
      break
    case .possible:
      break
    }
  }
  
  func createNewTweet(_ sender: UIBarButtonItem) {
    NewTweetViewController.presentNewTweetViewController(inReplyToTweet: nil, forViewController: self)
  }
  
  @IBAction func pageControlDidPage(_ sender: UIPageControl) {
    let xOffset = profileScrollView.bounds.width * CGFloat(pageControl.currentPage)
    profileScrollView.setContentOffset(CGPoint(x: xOffset, y: 0), animated: true)
  }
  
}

extension TwitterUserProfileViewController: UIGestureRecognizerDelegate {
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    // Respond only if gesture is a vertical gesture
    let velocity = (gestureRecognizer as! UIPanGestureRecognizer).velocity(in: view)
    return fabs(velocity.y) > fabs(velocity.x)
  }
}

extension TwitterUserProfileViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.bounds.width)
  }
}

extension TwitterUserProfileViewController: NewTweetViewControllerDelegate {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool) {
    dismiss(animated: true, completion: nil)
  }
  
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didPostTweetText: String) {
    dismiss(animated: true, completion: nil)
  }
}

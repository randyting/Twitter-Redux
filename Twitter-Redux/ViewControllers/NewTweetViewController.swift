//
//  NewTweetViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/10/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol NewTweetViewControllerDelegate {
  func newTweetViewController(newTweetViewController: NewTweetViewController, didPostTweetText: String)
  func newTweetViewController(newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool)
}

class NewTweetViewController: UIViewController {
  
  // MARK: - Constants
  private let maxTweetLength = 140
  
  // MARK: - Storyboard Objects
  @IBOutlet private weak var userScreennameLabel: UILabel!
  @IBOutlet private weak var userNameLabel: UILabel!
  @IBOutlet private weak var profileImageView: UIImageView!
  @IBOutlet private weak var tweetTextView: UITextView!
  @IBOutlet private weak var tweetTextViewBottomToSuperHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Properties
  weak var delegate: AnyObject?
  var currentUser: TwitterUser!
  
  var inReplyToStatusID: String?
  var inReplyToUserScreenname: String?
  var characterCountBarButtonItem: UIBarButtonItem!
  
  // MARK: - Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupNavigationBar()
    setupTextView(tweetTextView)
    setupAppearance()
    setupInitialValues()
    
  }
  
  // MARK: - Initial Setup
  private func setupAppearance(){
    // Aligns text to top in text view
    automaticallyAdjustsScrollViewInsets = false
    edgesForExtendedLayout = .None
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "willShowKeyboard:", name: UIKeyboardWillShowNotification, object: nil)
    
    profileImageView.layer.cornerRadius = 4.0
    profileImageView.clipsToBounds = true
  }
  
  private func setupTextView(textView: UITextView) {
    textView.keyboardType = .Twitter
    textView.becomeFirstResponder()
    textView.delegate = self
  }
  
  private func setupInitialValues(){
    currentUser = TwitterUser.currentUser
    profileImageView.setImageWithURL(currentUser.profileImageURL())
    userNameLabel.text = currentUser.name
    userScreennameLabel.text = "@" + currentUser.screenname
    if let inReplyToUserScreenname = inReplyToUserScreenname {
      tweetTextView.text = "@" + inReplyToUserScreenname + " "
    }
    characterCountBarButtonItem.title = String(maxTweetLength - (tweetTextView.text as NSString).length)
  }
  
  private func setupNavigationBar() {
    self.title = "New Tweet"
    let tweetBarButtonItem = UIBarButtonItem(image: UIImage(named: "twitter"), style: .Plain, target: self, action: "onTapTweetBarButton:")
    characterCountBarButtonItem = UIBarButtonItem()
    characterCountBarButtonItem.tintColor = UIColor.darkGrayColor()
    navigationItem.rightBarButtonItems = [tweetBarButtonItem, characterCountBarButtonItem]
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "xmark"), style: .Plain, target: self, action: "onTapCancelBarButton:")    
  }
  
  // MARK: - Behavior
  func willShowKeyboard(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let kbSize = ((userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue().size)!
      tweetTextViewBottomToSuperHeightConstraint.constant = kbSize.height
    }
  }
  
  func onTapCancelBarButton(sender: UIBarButtonItem) {
    tweetTextView.resignFirstResponder()
    self.delegate?.newTweetViewController!(self, didCancelNewTweet: true)
  }
  
  func onTapTweetBarButton(sender: UIBarButtonItem) {
    tweetTextView.resignFirstResponder()
    if tweetTextView.text.characters.count > 0 {
      TwitterUser.tweetText(tweetTextView.text, inReplyToStatusID: inReplyToStatusID, completion:
        {(success: Bool?, error: NSError?) -> () in
          if let error = error {
            print(error.localizedDescription)
          } else {
            self.delegate?.newTweetViewController!(self, didPostTweetText: self.tweetTextView.text)
          }
      })
    }
  }
  
  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: - Class Methods
  class func presentNewTweetVCInReplyToTweet(tweet: Tweet?, forViewController viewController: UIViewController!) {
    let vc = NewTweetViewController()
    vc.inReplyToStatusID = tweet?.idString
    vc.inReplyToUserScreenname = tweet?.userScreenname
    vc.delegate = viewController
    let navVC = UINavigationController(rootViewController: vc)
    viewController.presentViewController(navVC, animated: true, completion: nil)
  }
}

extension NewTweetViewController: UITextViewDelegate {
  
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    let currentString: NSString = tweetTextView.text
    let newString: NSString =
    currentString.stringByReplacingCharactersInRange(range, withString: text)
    return newString.length <= maxTweetLength
  }
  
  func textViewDidChange(textView: UITextView) {
    let text = textView.text as NSString
    if text.length == 0 {
      characterCountBarButtonItem.title = ""
    } else {
      characterCountBarButtonItem.title = String(maxTweetLength - text.length)
    }
  }
  
}

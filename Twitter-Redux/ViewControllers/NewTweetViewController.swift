//
//  NewTweetViewController.swift
//  Twitter-Redux
//
//  Created by Randy Ting on 10/10/15.
//  Copyright © 2015 Randy Ting. All rights reserved.
//

import UIKit

@objc protocol NewTweetViewControllerDelegate {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didPostTweetText: String)
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool)
}

class NewTweetViewController: UIViewController {
  
  // MARK: - Constants
  fileprivate let maxTweetLength = 140
  
  // MARK: - Storyboard Objects
  @IBOutlet fileprivate weak var userScreennameLabel: UILabel!
  @IBOutlet fileprivate weak var userNameLabel: UILabel!
  @IBOutlet fileprivate weak var profileImageView: UIImageView!
  @IBOutlet fileprivate weak var tweetTextView: UITextView!
  @IBOutlet fileprivate weak var tweetTextViewBottomToSuperHeightConstraint: NSLayoutConstraint!
  
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
  fileprivate func setupAppearance(){
    // Aligns text to top in text view
    automaticallyAdjustsScrollViewInsets = false
    edgesForExtendedLayout = UIRectEdge()
    
    NotificationCenter.default.addObserver(self, selector: #selector(NewTweetViewController.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
    profileImageView.layer.cornerRadius = 4.0
    profileImageView.clipsToBounds = true
  }
  
  fileprivate func setupTextView(_ textView: UITextView) {
    textView.keyboardType = .twitter
    textView.becomeFirstResponder()
    textView.delegate = self
  }
  
  fileprivate func setupInitialValues(){
    currentUser = TwitterUser.currentUser
    profileImageView.setImageWith(currentUser.profileImageURL() as URL!)
    userNameLabel.text = currentUser.name
    userScreennameLabel.text = "@" + currentUser.screenname
    if let inReplyToUserScreenname = inReplyToUserScreenname {
      tweetTextView.text = "@" + inReplyToUserScreenname + " "
    }
    characterCountBarButtonItem.title = String(maxTweetLength - (tweetTextView.text as NSString).length)
  }
  
  fileprivate func setupNavigationBar() {
    self.title = "New Tweet"
    let tweetBarButtonItem = UIBarButtonItem(image: UIImage(named: "twitter"), style: .plain, target: self, action: #selector(NewTweetViewController.onTapTweetBarButton(_:)))
    characterCountBarButtonItem = UIBarButtonItem()
    characterCountBarButtonItem.tintColor = UIColor.white
    navigationItem.rightBarButtonItems = [tweetBarButtonItem, characterCountBarButtonItem]
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "xmark"), style: .plain, target: self, action: #selector(NewTweetViewController.onTapCancelBarButton(_:)))    
  }
  
  // MARK: - Behavior
  func willShowKeyboard(_ notification: Notification) {
    if let userInfo = notification.userInfo {
      let kbSize = ((userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
      tweetTextViewBottomToSuperHeightConstraint.constant = kbSize.height
    }
  }
  
  func onTapCancelBarButton(_ sender: UIBarButtonItem) {
    tweetTextView.resignFirstResponder()
    self.delegate?.newTweetViewController!(self, didCancelNewTweet: true)
  }
  
  func onTapTweetBarButton(_ sender: UIBarButtonItem) {
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
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Class Methods
  class func presentNewTweetVCInReplyToTweet(_ tweet: Tweet?, forViewController viewController: UIViewController!) {
    let vc = NewTweetViewController()
    vc.inReplyToStatusID = tweet?.idString
    vc.inReplyToUserScreenname = tweet?.userScreenname
    vc.delegate = viewController
    let navVC = UINavigationController(rootViewController: vc)
    viewController.present(navVC, animated: true, completion: nil)
  }
}

extension NewTweetViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentString: NSString = tweetTextView.text as NSString
    let newString: NSString =
    currentString.replacingCharacters(in: range, with: text) as NSString
    return newString.length <= maxTweetLength
  }
  
  func textViewDidChange(_ textView: UITextView) {
    let text = textView.text as NSString
    if text.length == 0 {
      characterCountBarButtonItem.title = ""
    } else {
      characterCountBarButtonItem.title = String(maxTweetLength - text.length)
    }
  }
  
}

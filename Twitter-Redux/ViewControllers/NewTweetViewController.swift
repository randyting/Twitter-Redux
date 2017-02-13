import UIKit

protocol NewTweetViewControllerDelegate: class {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didPostTweetText: String)
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool)
}

class NewTweetViewController: UIViewController {
  
  // MARK: - Constants
  
  fileprivate enum NewTweetViewControllerConstants {
    static fileprivate let maxTweetLength = 140
    static fileprivate let profileImageViewCornerRadius: CGFloat = 4.0
    static fileprivate let navigationBarTitle = "New Tweet"
    static fileprivate let tweetButtonImageName = "twitter"
    static fileprivate let dismissButtonImageName = "xmark"
  }
  
  // MARK: - Interface Builder
  
  @IBOutlet fileprivate weak var userScreennameLabel: UILabel!
  @IBOutlet fileprivate weak var userNameLabel: UILabel!
  @IBOutlet fileprivate weak var profileImageView: UIImageView!
  @IBOutlet fileprivate weak var tweetTextView: UITextView!
  @IBOutlet fileprivate weak var textViewBottomToSuperHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Properties
  
  fileprivate weak var delegate: NewTweetViewControllerDelegate?
  
  fileprivate var currentUser: TwitterUser!
  fileprivate var inReplyToStatusID: String?
  fileprivate var inReplyToUserScreenname: String?
  fileprivate var characterCountBarButtonItem: UIBarButtonItem!
  fileprivate var remainingCharacterCountString: String {
    return String(NewTweetViewControllerConstants.maxTweetLength - tweetTextView.text.characters.count)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationBar()
    setupTextView(tweetTextView)
    setupAppearance()
    setupInitialValues()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Initial Setup
  
  fileprivate func setupAppearance() {
    automaticallyAdjustsScrollViewInsets = false
    edgesForExtendedLayout = UIRectEdge()
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(willShowKeyboard(_:)),
                                           name: NSNotification.Name.UIKeyboardWillShow,
                                           object: nil)
    
    profileImageView.layer.cornerRadius = NewTweetViewControllerConstants.profileImageViewCornerRadius
    profileImageView.clipsToBounds = true
  }
  
  fileprivate func setupTextView(_ textView: UITextView) {
    textView.keyboardType = .twitter
    textView.becomeFirstResponder()
    textView.delegate = self
  }
  
  fileprivate func setupInitialValues() {
    currentUser = TwitterUser.currentUser
    profileImageView.setImageWith(currentUser.profileImageURL())
    userNameLabel.text = currentUser.name
    userScreennameLabel.text = "@" + currentUser.screenname
    if let inReplyToUserScreenname = inReplyToUserScreenname {
      tweetTextView.text = "@" + inReplyToUserScreenname + " "
    }
    characterCountBarButtonItem.title = remainingCharacterCountString
  }
  
  fileprivate func setupNavigationBar() {
    title = NewTweetViewControllerConstants.navigationBarTitle
    let tweetBarButtonItem = UIBarButtonItem(image: UIImage(named: NewTweetViewControllerConstants.tweetButtonImageName),
                                             style: .plain,
                                             target: self,
                                             action: #selector(onTapTweetBarButton(_:)))
    characterCountBarButtonItem = UIBarButtonItem()
    characterCountBarButtonItem.tintColor = UIColor.white
    navigationItem.rightBarButtonItems = [tweetBarButtonItem, characterCountBarButtonItem]
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: NewTweetViewControllerConstants.dismissButtonImageName),
                                                       style: .plain,
                                                       target: self,
                                                       action: #selector(onTapCancelBarButton(_:)))
  }
  
  // MARK: - Behavior
  
  @objc fileprivate func willShowKeyboard(_ notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    
    let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size // swiftlint:disable:this force_cast
    textViewBottomToSuperHeightConstraint.constant = keyboardSize.height
  }
  
  @objc fileprivate func onTapCancelBarButton(_ sender: UIBarButtonItem) {
    tweetTextView.resignFirstResponder()
    delegate?.newTweetViewController(self, didCancelNewTweet: true)
  }
  
  @objc fileprivate func onTapTweetBarButton(_ sender: UIBarButtonItem) {
    guard !tweetTextView.text.characters.isEmpty else { return }
    
    tweetTextView.resignFirstResponder()
    TwitterUser.tweetText(tweetTextView.text, inReplyToStatusID: inReplyToStatusID) {[weak self] (_, error: Error?) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        guard let strongSelf = self else { return }
        strongSelf.delegate?.newTweetViewController(strongSelf, didPostTweetText: strongSelf.tweetTextView.text)
      }
    }
  }
  
  // MARK: - Class Methods
  
  /// Presents a NewTweetViewController modally so that the user can either compose a new tweet or reply to a tweet.
  ///
  /// - Parameters:
  ///   - tweet: The tweet to reply to. Pass in nil if composing a new tweet.
  ///   - viewController: The view controller presenting the NewTweetViewController.
  ///
  /// - Returns: Void
  
  class func presentNewTweetViewController(inReplyToTweet tweet: Tweet?,
                                           forViewController viewController: NewTweetViewControllerDelegate!) {
    let newTweetViewController = NewTweetViewController()
    newTweetViewController.inReplyToStatusID = tweet?.idString
    newTweetViewController.inReplyToUserScreenname = tweet?.userScreenname
    newTweetViewController.delegate = viewController
    let newNavigationController = UINavigationController(rootViewController: newTweetViewController)
    (viewController as? UIViewController)?.present(newNavigationController, animated: true, completion: nil)
  }
  
}

// MARK: - UITextViewDelegate

extension NewTweetViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView,
                shouldChangeTextIn range: NSRange,
                replacementText text: String) -> Bool {
    let currentString = tweetTextView.text as NSString
    let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
    return newString.length <= NewTweetViewControllerConstants.maxTweetLength
  }
  
  func textViewDidChange(_ textView: UITextView) {
    characterCountBarButtonItem.title = textView.text.characters.isEmpty ? "" : remainingCharacterCountString
  }
  
}

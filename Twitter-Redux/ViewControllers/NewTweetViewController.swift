import UIKit

protocol NewTweetViewControllerDelegate: class {
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didPostTweetText: String)
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool)
}

class NewTweetViewController: UIViewController {
  
  // MARK: - Constants
  
  fileprivate struct NewTweetViewControllerConstants {
    fileprivate static let maxTweetLength = 140
    fileprivate static let profileImageViewCornerRadius: CGFloat = 4.0
    fileprivate static let navigationBarTitle = "New Tweet"
    fileprivate static let tweetButtonImageName = "twitter"
  }
  
  // MARK: - Interface Builder
  
  @IBOutlet fileprivate weak var userScreennameLabel: UILabel!
  @IBOutlet fileprivate weak var userNameLabel: UILabel!
  @IBOutlet fileprivate weak var profileImageView: UIImageView!
  @IBOutlet fileprivate weak var tweetTextView: UITextView!
  @IBOutlet fileprivate weak var textViewBottomToSuperHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Properties
  
  private weak var delegate: NewTweetViewControllerDelegate?
  
  fileprivate var currentUser: TwitterUser!
  fileprivate var inReplyToStatusID: String?
  fileprivate var inReplyToUserScreenname: String?
  fileprivate var characterCountBarButtonItem: UIBarButtonItem!
  
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
    
    NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    
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
    profileImageView.setImageWith(currentUser.profileImageURL() as URL!)
    userNameLabel.text = currentUser.name
    userScreennameLabel.text = "@" + currentUser.screenname
    if let inReplyToUserScreenname = inReplyToUserScreenname {
      tweetTextView.text = "@" + inReplyToUserScreenname + " "
    }
    characterCountBarButtonItem.title = String(NewTweetViewControllerConstants.maxTweetLength - (tweetTextView.text as NSString).length)
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
    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "xmark"), style: .plain, target: self, action: #selector(NewTweetViewController.onTapCancelBarButton(_:)))    
  }
  
  // MARK: - Behavior
  func willShowKeyboard(_ notification: Notification) {
    if let userInfo = notification.userInfo {
      let kbSize = ((userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size)!
      textViewBottomToSuperHeightConstraint.constant = kbSize.height
    }
  }
  
  func onTapCancelBarButton(_ sender: UIBarButtonItem) {
    tweetTextView.resignFirstResponder()
    delegate?.newTweetViewController(self, didCancelNewTweet: true)
  }
  
  func onTapTweetBarButton(_ sender: UIBarButtonItem) {
    tweetTextView.resignFirstResponder()
    if tweetTextView.text.characters.count > 0 {
      TwitterUser.tweetText(tweetTextView.text, inReplyToStatusID: inReplyToStatusID, completion: {(_, error: Error?) -> Void in
          if let error = error {
            print(error.localizedDescription)
          } else {
            self.delegate?.newTweetViewController(self, didPostTweetText: self.tweetTextView.text)
          }
      })
    }
  }
  
  // MARK: - Class Methods
  class func presentNewTweetVCInReplyToTweet(_ tweet: Tweet?, forViewController viewController: NewTweetViewControllerDelegate!) {
    let newTweetViewController = NewTweetViewController()
    newTweetViewController.inReplyToStatusID = tweet?.idString
    newTweetViewController.inReplyToUserScreenname = tweet?.userScreenname
    newTweetViewController.delegate = viewController
    let newNavigationController = UINavigationController(rootViewController: newTweetViewController)
    (viewController as? UIViewController)?.present(newNavigationController, animated: true, completion: nil)
  }
}

extension NewTweetViewController: UITextViewDelegate {
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    let currentString: NSString = tweetTextView.text as NSString
    let newString: NSString =
    currentString.replacingCharacters(in: range, with: text) as NSString
    return newString.length <= NewTweetViewControllerConstants.maxTweetLength
  }
  
  func textViewDidChange(_ textView: UITextView) {
    let text = textView.text as NSString
    if text.length == 0 {
      characterCountBarButtonItem.title = ""
    } else {
      characterCountBarButtonItem.title = String(NewTweetViewControllerConstants.maxTweetLength - text.length)
    }
  }
  
}

import UIKit

protocol TweetTableViewCellDelegate: class {
  func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapReplyButton: UIButton)
  func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapProfileImage: UIImageView)
}

class TweetTableViewCell: UITableViewCell {
  
  // MARK: - Constants
  
  fileprivate enum TweetTableViewCellConstants {
    static fileprivate let favoriteButtonOnImage = #imageLiteral(resourceName: "favorite_on")
    static fileprivate let favoriteButtonOffImage = #imageLiteral(resourceName: "favorite")
    
    static fileprivate let retweetButtonOnImage = #imageLiteral(resourceName: "retweet_on")
    static fileprivate let retweetButtonOffImage = #imageLiteral(resourceName: "retweet")
    
    static fileprivate let replyIconImage = #imageLiteral(resourceName: "reply")
    static fileprivate let retweetIconImage = #imageLiteral(resourceName: "retweet")
    
    static fileprivate let profileViewCornerRadius: CGFloat = 4
    
    static fileprivate let retweetContainerVisibleHeight: CGFloat = 25
    static fileprivate let profileTopToContainerHeight: CGFloat = 15
  }
  
  // MARK: - Interface Builder
  
  @IBOutlet fileprivate weak var profileImageView: UIImageView!
  @IBOutlet fileprivate weak var tweetTextLabel: UILabel!
  @IBOutlet fileprivate weak var timeSinceCreatedDXTimestampLabel: DXTimestampLabel!
  @IBOutlet fileprivate weak var userNameLabel: UILabel!
  @IBOutlet fileprivate weak var userScreenNameLabel: UILabel!
  
  @IBOutlet fileprivate weak var replyButton: UIButton!
  
  @IBOutlet fileprivate weak var retweetButton: UIButton!
  @IBOutlet fileprivate weak var retweetCountLabel: UILabel!
  
  @IBOutlet fileprivate weak var favoriteButton: UIButton!
  @IBOutlet fileprivate weak var favoriteCountLabel: UILabel!
  
  @IBOutlet fileprivate weak var retweetOrReplyContainerView: UIView!
  @IBOutlet fileprivate weak var retweetContainerViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet fileprivate weak var retweetOrReplyIcon: UIImageView!
  @IBOutlet fileprivate weak var retweetOrReplyLabel: UILabel!
  
  @IBOutlet fileprivate weak var profileTopToContainerHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Properties
  
  var tweetToShow: Tweet!
  weak var delegate: TweetTableViewCellDelegate?
  
  var tweet: Tweet! {
    didSet {
      tweetToShow = tweet.originalTweet ?? tweet
      updateContent()
      setupProfileImageView()
      setupTweetLabels()
    }
  }
  
  // MARK: - Initial Setup
  
  fileprivate func setupProfileImageView() {
    profileImageView.layer.cornerRadius = TweetTableViewCellConstants.profileViewCornerRadius
    profileImageView.clipsToBounds = true
    profileImageView.setImageWith(tweetToShow.profileImageURL)
    profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapProfileImage(_:))))
  }
  
  fileprivate func setupTweetLabels() {
    tweetTextLabel.text = tweetToShow.text
    userNameLabel.text = tweetToShow.userName
    userScreenNameLabel.text = "@" + tweetToShow.userScreenname
    timeSinceCreatedDXTimestampLabel.timestamp = TwitterDateFormatter.sharedInstance.date(from: tweet.createdAt)
  }
  
  // MARK: - Update Data
  
  fileprivate func updateContent() {
    favoriteCountLabel.text = String(tweetToShow.favoriteCount)
    retweetCountLabel.text = String(tweetToShow.retweetCount)
    
    update(button: favoriteButton,
           withOnImage: TweetTableViewCellConstants.favoriteButtonOnImage,
           withOffImage: TweetTableViewCellConstants.favoriteButtonOffImage,
           basedOnState: tweetToShow.favorited)
    update(button: retweetButton,
           withOnImage: TweetTableViewCellConstants.retweetButtonOnImage,
           withOffImage: TweetTableViewCellConstants.retweetButtonOffImage,
           basedOnState: tweetToShow.retweeted)
    
    updateRetweetOrReplyViews()
  }
  
  fileprivate func update(button: UIButton,
                          withOnImage onImage: UIImage,
                          withOffImage offImage: UIImage,
                          basedOnState state: Bool) {
    button.setImage(state ? onImage : offImage, for: UIControlState())
  }
  
  fileprivate func updateRetweetOrReplyViews() {
    guard tweet.isRetweet || tweet.isReply else {
      setRetweetOrReplyViews(hidden: true)
      return
    }
    
    setRetweetOrReplyViews(hidden: false)
    retweetOrReplyIcon.image = tweet.isRetweet ? TweetTableViewCellConstants.retweetIconImage : TweetTableViewCellConstants.replyIconImage
    if let username = tweet.userName, let inReplyToScreenName = tweet.inReplyToScreenName {
      retweetOrReplyLabel.text = tweet.isRetweet ? "\(username) Retweeted" : "in reply to @\(inReplyToScreenName)"
    }
  }
  
  fileprivate func setRetweetOrReplyViews(hidden isHidden: Bool) {
    retweetOrReplyContainerView.isHidden = isHidden
    retweetContainerViewHeightConstraint.constant = isHidden ? 0 : TweetTableViewCellConstants.retweetContainerVisibleHeight
    profileTopToContainerHeightConstraint.constant = isHidden ? TweetTableViewCellConstants.profileTopToContainerHeight : 0
  }
  
  // MARK: - Behavior
  
  @IBAction func onTapRetweetButton(_ sender: AnyObject) {
    TwitterUser.toggleRetweetedState(forTweet: tweetToShow) { [weak self] (_, error) in
      guard let error = error else {
        guard let strongSelf = self else { return }
        strongSelf.updateContent()
        return
      }
      print("Toggle Retweeted Error: \(error.localizedDescription)")
    }
  }
  
  @IBAction func onTapFavoriteButton(_ sender: UIButton) {
    TwitterUser.toggleFavoritedState(forTweet: tweetToShow) { [weak self] (_, error) in
      guard let error = error else {
        guard let strongSelf = self else { return }
        strongSelf.updateContent()
        return
      }
      print("Toggle Favorited Error: \(error.localizedDescription)")
    }
  }
  
  @IBAction func onTapReplyButton(_ sender: UIButton) {
    delegate?.tweetTableViewCell(self, didTapReplyButton: sender)
  }
  
  func onTapProfileImage(_ sender: UITapGestureRecognizer) {
    delegate?.tweetTableViewCell(self, didTapProfileImage: profileImageView)
  }
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    self.layoutMargins = UIEdgeInsets.zero
    self.preservesSuperviewLayoutMargins = false
  }
  
}

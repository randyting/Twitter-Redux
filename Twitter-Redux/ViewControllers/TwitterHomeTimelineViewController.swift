import UIKit

class TwitterHomeTimelineViewController: UIViewController {
  
  // MARK: - Constants
  
  fileprivate enum HomeTimelineViewControllerConstants {
    static fileprivate let tweetTableViewCellNibName = "TweetTableViewCell"
    static fileprivate let tweetsCellReuseIdentifier = "com.randy.tweetsCellReuseIdentifier"
    static fileprivate let tableViewEstimatedRowHeight: CGFloat = 300
    static fileprivate let title = "Home"
    static fileprivate let createNewTweetIconImageName = "compose"
    static fileprivate let numberOfAdditionalTweetsToLoad = 20
  }
  
  // MARK: - Properties
  
  /// This property is exposed internal only so that it can be used in a subclass.  Do not use it externally.
  var currentUser: TwitterUser!
  /// This property is exposed internal only so that it can be used in a subclass.  Do not use it externally.
  var tweets: [Tweet]?
  /// This property is exposed internal only so that it can be used in a subclass.  Do not use it externally.
  let refreshControl = UIRefreshControl()
  
  // MARK: - Interface Builder
  
  /// This is exposed internal only so that it can be used in a subclass.  Do not use it externally.
  @IBOutlet weak var tweetsTableView: UITableView!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupTweetsTableView(tweetsTableView)
    setupRefreshControl(refreshControl)
    setupNavigationBar()
    setupInitialValues()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    tweetsTableView.reloadData()
  }
  
  // MARK: - Initial Setup
  
  fileprivate func setupTweetsTableView(_ tableView: UITableView) {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.estimatedRowHeight = HomeTimelineViewControllerConstants.tableViewEstimatedRowHeight
    tableView.rowHeight = UITableViewAutomaticDimension
    let tweetTableViewCellNib = UINib(nibName: HomeTimelineViewControllerConstants.tweetTableViewCellNibName, bundle: nil)
    tableView.register(tweetTableViewCellNib, forCellReuseIdentifier: HomeTimelineViewControllerConstants.tweetsCellReuseIdentifier)
    tableView.separatorInset = UIEdgeInsets.zero
  }
  
  /// This method initializes all the data for the content to be displayed in this view controller.
  /// It is exposed internal so that it can be overridden in a subclass. Do not call it externally.
  func setupInitialValues() {
    title = HomeTimelineViewControllerConstants.title
    currentUser = UserManager.sharedInstance.currentUser
    refreshTweets()
  }
  
  fileprivate func setupRefreshControl(_ refreshControl: UIRefreshControl) {
    refreshControl.addTarget(self, action: #selector(refreshTweets), for: .valueChanged)
    tweetsTableView.insertSubview(refreshControl, at: 0)
    tweetsTableView.infiniteScrollIndicatorStyle = .gray
    tweetsTableView.addInfiniteScroll { (_) -> Void in
      self.loadOlderTweets()
    }
  }
  
  fileprivate func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: HomeTimelineViewControllerConstants.createNewTweetIconImageName ),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(createNewTweet(_:)))
  }
  
  // MARK: - Behavior
  
  @objc fileprivate func createNewTweet(_ sender: UIBarButtonItem) {
    NewTweetViewController.presentNewTweetViewController(inReplyToTweet: nil, forViewController: self)
  }
  
  /// This method is called to refresh all the tweets shown in this view controller.  It makes an Twitter API call to grab the latest timeline tweets.
  /// It is exposed internal so that it can be overridden in a subclass. Do not call it externally.
  func refreshTweets() {
    currentUser.homeTimelineWithParams(nil) { [weak self] (tweets, error) -> Void in
      guard let error = error else {
        guard let strongSelf = self else { return }
        strongSelf.tweets = tweets
        strongSelf.tweetsTableView.reloadData()
        DispatchQueue.main.async(execute: { () -> Void in
          strongSelf.refreshControl.endRefreshing()
        })
        return
      }
      print(error.localizedDescription)
    }
  }
  
  /// This method makes an Twitter API call to grab the next 20 older tweets on the timeline and appends them to the tableview model.
  /// It is exposed internal so that it can be overridden in a subclass. Do not call it externally.
  func loadOlderTweets() {
    guard let tweets = tweets, let lastTweetID = tweets.last?.id else {
      tweetsTableView.finishInfiniteScroll()
      return
    }
    
    let params = TwitterHomeTimelineParameters(withCount: HomeTimelineViewControllerConstants.numberOfAdditionalTweetsToLoad,
                                               withSinceID: nil,
                                               withMaxID: String(lastTweetID - 1))
    
    currentUser.homeTimelineWithParams(params) { [weak self] (tweets, error) -> Void in
      guard let error = error else {
        guard let strongSelf = self, let tweets = tweets else { return }
        strongSelf.tweets? += tweets
        strongSelf.tweetsTableView.reloadData()
        DispatchQueue.main.async { () -> Void in
          strongSelf.tweetsTableView.finishInfiniteScroll()
        }
        return
      }
      print(error.localizedDescription)
    }
  }
  
}

// MARK: - UITableViewDelegate

extension TwitterHomeTimelineViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let tweetDetailViewController = TweetDetailViewController()
    tweetDetailViewController.tweet = (tweetsTableView.cellForRow(at: indexPath) as! TweetTableViewCell).tweetToShow // swiftlint:disable:this force_cast
    navigationController?.pushViewController(tweetDetailViewController, animated: true)
  }
  
}

// MARK: - UITableViewDataSource

extension TwitterHomeTimelineViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tweetsTableView.dequeueReusableCell(withIdentifier: HomeTimelineViewControllerConstants.tweetsCellReuseIdentifier,
                                                   for: indexPath) as! TweetTableViewCell // swiftlint:disable:this force_cast
    cell.tweet = tweets?[indexPath.row]
    cell.delegate = self
    return cell
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets?.count ?? 0
  }
  
}

// MARK: - TweetTableViewCell Delegate

extension TwitterHomeTimelineViewController: TweetTableViewCellDelegate {
  
  func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapReplyButton: UIButton) {
    NewTweetViewController.presentNewTweetViewController(inReplyToTweet: tweetTableViewCell.tweetToShow, forViewController: self)
  }
  
  func tweetTableViewCell(_ tweetTableViewCell: TweetTableViewCell, didTapProfileImage: UIImageView) {
    TwitterUser.userWithScreenName(tweetTableViewCell.tweetToShow.userScreenname) { [weak self] (user, error) -> Void in
      guard let error = error else {
        guard let strongSelf = self else { return }
        let profileViewController = TwitterUserProfileViewController()
        profileViewController.user = user
        strongSelf.navigationController?.pushViewController(profileViewController, animated: true)
        return
      }
      print(error.localizedDescription)
    }
  }
  
}

// MARK: - NewTweetViewController Delegate

extension TwitterHomeTimelineViewController: NewTweetViewControllerDelegate {
  
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didPostTweetText: String) {
    dismiss(animated: true, completion: nil)
    refreshTweets()
  }
  
  func newTweetViewController(_ newTweetViewController: NewTweetViewController, didCancelNewTweet: Bool) {
    dismiss(animated: true, completion: nil)
  }
  
}

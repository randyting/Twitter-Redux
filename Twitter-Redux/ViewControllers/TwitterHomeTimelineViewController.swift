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
  
  var currentUser: TwitterUser!
  var tweets: [Tweet]?
  let refreshControl = UIRefreshControl()
  
  // MARK: - Interface Builder
  
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
  
  func setupInitialValues() {
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
    title = HomeTimelineViewControllerConstants.title
    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: HomeTimelineViewControllerConstants.createNewTweetIconImageName ),
                                                        style: .plain,
                                                        target: self,
                                                        action: #selector(createNewTweet(_:)))
  }
  
  // MARK: - Behavior
  
  func createNewTweet(_ sender: UIBarButtonItem) {
    NewTweetViewController.presentNewTweetViewController(inReplyToTweet: nil, forViewController: self)
  }
  
  func refreshTweets() {
    currentUser.homeTimelineWithParams(nil) { [weak self] (tweets, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        guard let strongSelf = self else { return }
        strongSelf.tweets = tweets
        strongSelf.tweetsTableView.reloadData()
        DispatchQueue.main.async(execute: { () -> Void in
          strongSelf.refreshControl.endRefreshing()
        })
      }
    }
  }
  
  func loadOlderTweets() {
    guard let tweets = tweets else {
      tweetsTableView.finishInfiniteScroll()
      return
    }
    
    let params = TwitterHomeTimelineParameters(withCount: HomeTimelineViewControllerConstants.numberOfAdditionalTweetsToLoad,
                                               withSinceID: nil,
                                               withMaxID: String(tweets.last!.id - 1))
    
    currentUser.homeTimelineWithParams(params) { [weak self] (tweets, error) -> Void in
      if let error = error {
        print(error.localizedDescription)
      } else {
        guard let strongSelf = self else { return }
        strongSelf.tweets? += tweets!
        strongSelf.tweetsTableView.reloadData()
        DispatchQueue.main.async { () -> Void in
          strongSelf.tweetsTableView.finishInfiniteScroll()
        }
      }
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
      if let error = error {
        print(error.localizedDescription)
      } else {
        guard let strongSelf = self else { return }
        let profileViewController = TwitterUserProfileViewController()
        profileViewController.user = user
        strongSelf.navigationController?.pushViewController(profileViewController, animated: true)
      }
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

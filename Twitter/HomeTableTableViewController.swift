//
//  HomeTableTableViewController.swift
//  Twitter
//
//  Created by Leo Samuelson on 2/9/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableTableViewController: UITableViewController {

       var tweetArray = [NSDictionary]()
       var numberOfTweets: Int!
    
    let myRefreshControl = UIRefreshControl()
    

    override func viewDidLoad() {
           super.viewDidLoad()
        loadTweet()
        myRefreshControl.addTarget(self, action: #selector(loadTweet), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        tableView.rowHeight = UITableView.automaticDimension
               tableView.estimatedRowHeight = 150
        
       }
    
     override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(animated)
           self.loadTweet()
       }

    @objc func loadTweet(){
        
        numberOfTweets = 20
        
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets,]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
        })
        
    }
    
    func loadMoreTweets(){
        
        let myURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweets]
        
        numberOfTweets = numberOfTweets + 20
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myURL, parameters: myParams, success: { (tweets: [NSDictionary]) in
                   
                   self.tweetArray.removeAll()
                   for tweet in tweets {
                       self.tweetArray.append(tweet)
                   }
                   
                   self.tableView.reloadData()
                   self.myRefreshControl.endRefreshing()
                   
               }, failure: { (Error) in
                   print("Could not retrieve tweets!")
               })
    }

       override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
           if indexPath.row + 1 == tweetArray.count {
               loadMoreTweets()
           }
       }
    
    
    @IBAction func onLogOut(_ sender: Any) {
        
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
         UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
   
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as! String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as! String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

    

}

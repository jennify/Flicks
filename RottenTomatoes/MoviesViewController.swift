//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Jennifer Lee on 2/1/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var filmTableView: UITableView!

    var movies : [NSDictionary]?
    var endpoint : String!
    var network_problem : Bool!
    var warning: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filmTableView.rowHeight = 200.0
        self.network_problem = false

        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.filmTableView.addSubview(refreshControl)
        
        
        self.loadDataFromNetwork(true, refreshControl: nil)
        
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movie = self.movies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        
        
        let cell = tableView .dequeueReusableCellWithIdentifier("com.codepath.examplecell") as!FilmCell
        cell.cellLabel.text = title
        cell.overviewText.text = overview
        
        if let posterPath = movie["poster_path"] as? String{
            let baseUrl = "http://image.tmdb.org/t/p/w500/"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.imageView?.setImageWithURL(imageUrl!)
        }
        return cell
    }
    
    func getRequest() {
        
    }

    func loadDataFromNetwork(has_hud: Bool, refreshControl: UIRefreshControl?) {
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a85ab2b0491c1b28caf575c41ef6ccd7"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        if has_hud {
            // Display HUD right before the request is made
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, errorOrNil) in
                if has_hud {
                    // Hide HUD once the network request comes back (must be done on main UI thread)
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                
                // Use the new data to update the data source
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.filmTableView.reloadData()
                    }
                }
                
                // Set warning label for user if there is a network error.
                if let _ = errorOrNil {
                    self.network_problem = true
                    self.warning.hidden = true
                } else {
                    self.network_problem = false
                    self.warning.hidden = true
                }
                
                // Reload the tableView now that there is new data
                self.filmTableView.reloadData()
                if let refreshControl = refreshControl {
                    // Tell the refreshControl to stop spinning
                    refreshControl.endRefreshing()
                }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self.loadDataFromNetwork(false, refreshControl: refreshControl)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: 380, height: 30))
        headerView.backgroundColor = UIColor(white: 0.2, alpha: 0.9)
        warning = headerView
        
        let warningLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 380, height: 30))
        warningLabel.text = "Network Error!"
        warningLabel.textColor = UIColor.whiteColor()
        warningLabel.textAlignment = NSTextAlignment.Center
        headerView.addSubview(warningLabel)

        self.warning.hidden = !self.network_problem
        
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = filmTableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailsViewController = segue.destinationViewController as! DetailsViewController
        detailsViewController.movie = movie
    }
}



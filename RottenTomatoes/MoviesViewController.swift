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

class MoviesViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {
    @IBOutlet weak var filmTableView: UITableView!
    @IBOutlet weak var network_error_view: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var movies : [NSDictionary]?
    var endpoint : String!
    var filtered_movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        filtered_movies = movies
        
        filmTableView.rowHeight = 200.0
        
        // Set up drag table view to refresh.
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        self.filmTableView.addSubview(refreshControl)
        
        // Populating first set of data.
        self.loadDataFromNetwork(true, refreshControl: nil)
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movie = self.filtered_movies![indexPath.row]
        let title = movie["title"] as? String
        let overview = movie["overview"] as? String
        
        // Reload table view with new content.
        let cell = tableView .dequeueReusableCellWithIdentifier("com.codepath.examplecell") as!FilmCell
        // Set selection color.
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 0.7)
        cell.selectedBackgroundView = backgroundView
        cell.cellLabel.text = title
        cell.overviewLabel.text = overview
        
        // Update image view in cell.
        if let posterPath = movie["poster_path"] as? String{
            let baseUrl = "http://image.tmdb.org/t/p/w500/"
            let imageUrl = NSURL(string: baseUrl + posterPath)
            
            // Fade in image.
            cell.imageView?.setImageWithURLRequest(
                NSURLRequest(URL: imageUrl!),
                placeholderImage: nil,
                success: { (imageRequest, imageResponse, image) -> Void in
                    if imageResponse != nil {
                        // Fade in image that isn't cached
                        cell.imageView?.alpha = 0.0
                        cell.imageView?.image = image
                        UIView.animateWithDuration(2, animations: { () -> Void in
                            cell.imageView?.alpha = 1.0
                        })
                    } else {
                        // Cached
                        cell.imageView?.image = image
                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
            })
        }
        
        return cell
    }
    
    func loadDataFromNetwork(has_hud: Bool, refreshControl: UIRefreshControl?) {

        // Create the NSURLRequest
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
                        self.movies = responseDictionary["results"] as? [NSDictionary]
                        self.filtered_movies = self.movies
                        self.filmTableView.reloadData()
                    }
                }

                // Set warning label for user if there is a network error.
                if let _ = errorOrNil {
                    self.network_error_view.hidden = false
                } else {
                    self.network_error_view.hidden = true
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let filtered_movies = self.filtered_movies {
            return filtered_movies.count
        } else {
            return 0
        }
    }
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filtered_movies = movies
        
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            
            filtered_movies = movies!.filter({(dataItem: NSDictionary) -> Bool in
                // If dataItem matches the searchText, return true to include it
                let title = dataItem["title"] as? String
                if title!.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        self.filmTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        // Pop up cancel button on search bar.
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        // Clear content on search bar.
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        // Reload original data after cancelation of search.
        self.filtered_movies = self.movies
        self.filmTableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = filmTableView.indexPathForCell(cell)
        let movie = filtered_movies![indexPath!.row]
        let detailsViewController = segue.destinationViewController as! DetailsViewController
        detailsViewController.movie = movie
    }
}



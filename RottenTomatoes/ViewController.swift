//
//  ViewController.swift
//  RottenTomatoes
//
//  Created by Jennifer Lee on 2/1/16.
//  Copyright © 2016 Jennifer Lee. All rights reserved.
//

import UIKit
import AFNetworking


class ViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var filmTableView: UITableView!

    var movies : [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        filmTableView.rowHeight = 200.0

        let apiKey = "a85ab2b0491c1b28caf575c41ef6ccd7"
        let url = NSURL(string:"http://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options: []) as? NSDictionary {
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    self.filmTableView.reloadData()
                }
            }
            
        });
        task.resume()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = filmTableView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        let detailsViewController = segue.destinationViewController as! DetailsViewController
        detailsViewController.movie = movie
    }
}



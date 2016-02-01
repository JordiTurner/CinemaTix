//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Jordi Turner on 1/15/16.
//  Copyright © 2016 Jordi Turner. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var NetworkErrorLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    

    
    
    
    
    var movies: [NSDictionary]?
    var data: [String]?
    var posterData: [String]?
    var filteredData: [String]!
    var filteredPosters: [String]!
    var totalIndexes: [Int]?
    var filteredIndexes: [Int]!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HideCells()
        ShowCells()
        
        
        
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        CollectionView.insertSubview(refreshControl, atIndex: 0)
        
        CollectionView.dataSource = self
        CollectionView.delegate = self
        searchBar.delegate = self
        
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = (responseDictionary["results"] as! [NSDictionary])
                            var MovieTitles: [String] = []
                            var MoviePosters: [String] = []
                            var MovieIndexes: [Int] = []
                            for var index = 0; index < self.movies!.count; ++index {
                                let MovieInfo = self.movies![index] as NSDictionary
                                MovieTitles.append(MovieInfo["title"] as! String)
                                MoviePosters.append(MovieInfo["poster_path"] as! String)
                                MovieIndexes.append(index)
                                
                            }
                            self.data = MovieTitles
                            self.filteredData = self.data
                            
                            self.posterData=MoviePosters
                            self.filteredPosters = self.posterData
                            
                            self.totalIndexes = MovieIndexes
                            self.filteredIndexes = self.totalIndexes
                            
                            self.CollectionView.reloadData()
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                    }
                }
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let filteredData = filteredData {
            NetworkErrorLabel.hidden = true
            return filteredData.count
        } else {
            NetworkErrorLabel.hidden = false
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("IdentifierCollectionCell", forIndexPath: indexPath) as! CollectionMovieCell
        
        let posterPath = filteredPosters[indexPath.row]
        let baseUrl = "https://image.tmdb.org/t/p/w342"
        let imageUrl = NSURL(string: baseUrl+posterPath)
        cell.CollectionTitleLabel.text = filteredData[indexPath.row]
        cell.CollectionPoster.setImageWithURL(imageUrl!)
        let imageRequest = NSURLRequest(URL: imageUrl!)
        cell.CollectionPoster.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.CollectionPoster.alpha = 0.0
                    cell.CollectionPoster.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.CollectionPoster.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.CollectionPoster.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        
        
        
        
        
        
        
        
        return cell
    }
    
    
    // Makes a network request to get updated data
    // Updates the tableView with the new data
    // Hides the RefreshControl
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                // ... Use the new data to update the data source ...
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()	
        });
        task.resume()
        
        
    }
    
    
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = data
            filteredPosters = posterData
            filteredIndexes = totalIndexes
            
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            
            
            var tempTitleList: [String] = []
            var tempPosterList: [String] = []
            // Go through each element in data
            for var filterIndex = 0; filterIndex < data!.count; ++filterIndex {
            
                // For each that matches the filter
                
                if data![filterIndex].containsString(searchText) {
                    // Add index to temporary list
                    tempPosterList.append(posterData![filterIndex])
                    tempTitleList.append(data![filterIndex])
                    
                    print("a match!")
                }
            }
            // Change filtered list to temporary list
            filteredData = tempTitleList
            filteredPosters = tempPosterList

        }
        CollectionView.reloadData()
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    func ShowCells(){
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:{
            self.CollectionView.alpha = 1
        }, completion: nil)
    }
    
    func HideCells(){
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations:{
            self.CollectionView.alpha = 0
        }, completion: nil)
    }

}

 //
//  DetailViewController.swift
//  CinemaTix
//
//  Created by Jordi Turner on 2/1/16.
//  Copyright © 2016 Jordi Turner. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    var movie: NSDictionary!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        scrollView.contentSize = CGSize (width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String

        
        titleLabel.text = title.uppercaseString 
        overviewLabel.text = overview
        overviewLabel.sizeToFit()
        
        if let posterPath = movie["poster_path"] as? String {
            let smallBaseUrl = "https://image.tmdb.org/t/p/w342"
            let largeBaseUrl = "https://image.tmdb.org/t/p/original"
            let smallImageUrl = NSURL(string: smallBaseUrl+posterPath)
            let largeImageUrl = NSURL(string: largeBaseUrl+posterPath)
            let smallImageRequest = NSURLRequest(URL: smallImageUrl!)
            let largeImageRequest = NSURLRequest(URL: largeImageUrl!)
                        posterImageView.setImageWithURLRequest(
                smallImageRequest,
                placeholderImage: nil,
                success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                    
                    // imageResponse will be nil if the image is cached
                    if smallImageResponse != nil {
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = smallImage
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.posterImageView.alpha = 1.0
                            }, completion: { (sucess) -> Void in
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                // per ImageView. This code must be in the completion block.
                                self.posterImageView.setImageWithURLRequest(
                                    largeImageRequest,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        self.posterImageView.image = largeImage;
                                    },
                                    failure: { (request, response, error) -> Void in
                                        self.posterImageView.image = UIImage(named: "error")
                                        
                                })
                        })} else {
                        self.posterImageView.alpha = 0.0
                        self.posterImageView.image = smallImage
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.posterImageView.alpha = 1.0
                            }, completion: { (sucess) -> Void in
                                // The AFNetworking ImageView Category only allows one request to be sent at a time
                                // per ImageView. This code must be in the completion block.
                                self.posterImageView.setImageWithURLRequest(
                                    largeImageRequest,
                                    placeholderImage: smallImage,
                                    success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                        self.posterImageView.image = largeImage;
                                    },
                                    failure: { (request, response, error) -> Void in
                                        self.posterImageView.image = UIImage(named: "error")
                                        
                                })
                        })                    }
                },
                failure: { (imageRequest, imageResponse, error) -> Void in
                    self.posterImageView.image = UIImage(named: "error")
            })

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

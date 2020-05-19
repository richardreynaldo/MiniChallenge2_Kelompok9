//
//  mainPageViewController.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Laurentius Richard Reynaldo on 17/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit

class mainPageViewController: UIViewController {

    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var imageArray = [UIImage]()
    let webViewController = WebViewController.shared
    
    var user = WebViewController.InstagramTestUser(access_token: "", user_id: 0)
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var joinedDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainScrollView.isPagingEnabled = true
        imageArray = [#imageLiteral(resourceName: "Hedgehog3"),#imageLiteral(resourceName: "Hedgehog1"),#imageLiteral(resourceName: "Hedgehog5")]
        
        for i in 0..<imageArray.count {
            let imageView = UIImageView()
            imageView.image = imageArray[i]
            imageView.contentMode = .scaleToFill
            let xPosition = self.view.frame.width * CGFloat(i)
            imageView.frame = CGRect(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
            
            mainScrollView.contentSize.width = mainScrollView.frame.width * CGFloat( i + 1)
            mainScrollView.addSubview(imageView)
        }
        
        if self.user.user_id != 0 {
            let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
            indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            indicator.center = view.center
            self.view.addSubview(indicator)
            self.view.bringSubviewToFront(indicator)
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            indicator.startAnimating()
            self.webViewController.getInstagramUsername(testUserData: self.user) { [weak self] (username) in
                DispatchQueue.main.async {
                    self?.userName.text = username.username
                    self?.joinedDate.text = username.id
                    indicator.stopAnimating()
                }
            }
        }
        
        

        // Do any additional setup after loading the view.
    }
    
    
    
    
    
    


}

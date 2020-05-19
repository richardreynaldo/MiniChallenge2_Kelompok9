//
//  mainPageViewController.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Laurentius Richard Reynaldo on 17/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit

class mainPageViewController: UIViewController {

    let webViewController = WebViewController.shared
    
    var user = WebViewController.InstagramTestUser(access_token: "", user_id: 0)
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var joinedDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

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
    var dataArray = [WebViewController.InstagramMedia.InstagramCaption]()
    var selectImage: UIImageView?
    
    var user = WebViewController.InstagramTestUser(access_token: "", user_id: 0)
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var joinedDate: UILabel!
    @IBOutlet weak var totalPhoto: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageArray = [#imageLiteral(resourceName: "Hedgehog3"),#imageLiteral(resourceName: "Hedgehog1"),#imageLiteral(resourceName: "Hedgehog5")]
        dataArray = []
        let mediaGroup = DispatchGroup()
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        let tap = CustomImageTapGesture.init(target: self, action: #selector(handleTap))
        
        if self.user.user_id != 0 {
            indicator.startAnimating()
            self.webViewController.getInstagramUsername(testUserData: self.user) { [weak self] (username) in
                DispatchQueue.main.async {
                    self?.userName.text = username.username
                    self?.joinedDate.text = username.id
                    indicator.stopAnimating()
                }
            }
            indicator.startAnimating()
            mediaGroup.enter()
            self.webViewController.getInstagramPostCaption(testUserData: self.user) { [weak self] (caption) in
                for k in 0..<caption.data.count {
                    if caption.data[k].mediaType == "IMAGE" {
                        self?.dataArray.append(caption.data[k])
                    }
                }
                DispatchQueue.main.async {
                    self?.totalPhoto.text = "\(caption.data.count)"
                    indicator.stopAnimating()
                }
                mediaGroup.leave()
            }
        }
        
        mediaGroup.notify(queue: .main) {
            indicator.startAnimating()
            print("Total Image: \(self.dataArray.count)")
            self.mainScrollView.isPagingEnabled = true
            let imageGroup = DispatchGroup()
            let x = self.dataArray.count
            for j in 0..<self.dataArray.count {
                self.webViewController.getInstagramMedia(mediaID: self.dataArray[j].id, testUserData: self.user) { [weak self] (picture) in
                    self?.profilePicture.downloaded(from: picture.mediaURL)
                    imageGroup.enter()
                    var imageView: UIImageView?
                    DispatchQueue.main.async {
                        imageView = UIImageView()
                        imageView?.downloaded(from: picture.mediaURL)
                        imageGroup.leave()
                    }
                    imageGroup.notify(queue: .main) {
                        tap.imageTap = imageView
                        tap.numberOfTapsRequired = 1
                        imageView?.addGestureRecognizer(tap)
                        imageView?.contentMode = .scaleToFill
                        let xPosition = (self?.view.frame.width)! * CGFloat(j)
                        imageView?.frame = CGRect(x: xPosition, y: 0, width: (self?.mainScrollView.frame.width)!, height: (self?.mainScrollView.frame.height)!)            
                        self?.mainScrollView.contentSize.width = (self?.mainScrollView.frame.width)! * CGFloat(x)
                        self?.mainScrollView.addSubview(imageView!)
                    }
                }
            }
            imageGroup.notify(queue: .main) {
                indicator.stopAnimating()
            }
        }
        
//        print(self.mediaArray)
        
//        mainScrollView.isPagingEnabled = true
//
//        for i in 0..<imageArray.count {
//            let imageView = UIImageView()
//            imageView.image = imageArray[i]
//            imageView.contentMode = .scaleToFill
//            let xPosition = self.view.frame.width * CGFloat(i)
//            imageView.frame = CGRect(x: xPosition, y: 0, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height)
//
//            mainScrollView.contentSize.width = mainScrollView.frame.width * CGFloat( i + 1)
//            mainScrollView.addSubview(imageView)
//        }
        
        

        // Do any additional setup after loading the view.
    }
    
//    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
    @objc func handleTap(recognizer: CustomImageTapGesture) {
        // handling code
        selectImage = recognizer.imageTap
        self.performSegue(withIdentifier: "detailMain", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailMain" {
            if let detailPage = segue.destination as? detailPageViewController {
                detailPage.selectedImage = selectImage
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class CustomImageTapGesture: UITapGestureRecognizer {
    var imageTap: UIImageView?
}

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

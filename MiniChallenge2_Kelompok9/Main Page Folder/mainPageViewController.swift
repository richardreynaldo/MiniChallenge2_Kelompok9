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
    
    @IBOutlet weak var discoveryCount: UILabel!
    @IBOutlet weak var reachRate: UILabel!
    @IBOutlet weak var loveCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var postSummary: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    } 
    
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        postSummary.addGestureRecognizer(tap)
        let customTap = CustomImageTapGesture.init(target: self, action: #selector(handleCustomTap))
        
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
                        customTap.imageTap = imageView
                        customTap.numberOfTapsRequired = 1
                        imageView?.addGestureRecognizer(customTap)
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        self.openCameraAndLibrary()
    }
    @objc func handleCustomTap(recognizer: CustomImageTapGesture) {
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

// Extension to make more structured
extension mainPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // MARK: Func to open camera and library function
    func openCameraAndLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let actionAlert = UIAlertController(title: "Browse attachment", message: "Choose source", preferredStyle: .alert)
        actionAlert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated:true, completion: nil)
            }else{
                print("Camera is not available at this device")
            }
        })) // give an option in alert controller to open camera
        
        actionAlert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            self.present(imagePicker, animated:true, completion: nil)
        })) // give the second option in alert controller to open Photo library
        
        actionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) // give the third option in alert controller to cancel the form
        
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageTaken = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.selectImage?.image = imageTaken
                // request to analyse process on execute
                self.webViewController.getTextFromPhoto(image: imageTaken) { [weak self] (text) in
                    let splitText = text.parsedResults[0].parsedText.components(separatedBy: "\r\n")
                    var engage = "", reach = "", like = "", comment = ""
                    for m in 0..<splitText.count {
                        switch splitText[m] {
                        case "Accounts reached":
                            engage = splitText[m+1]
                        case "Follows":
                            reach = splitText[m-1]
                        case "Profile Visits":
                            like = splitText[m-2]
                        case "Post Insights":
                            comment = splitText[m+1]
                        default:
                            continue
                        }
                    }
                    DispatchQueue.main.async {
                        self?.reachRate.text = engage
                        self?.discoveryCount.text = reach
                        self?.loveCount.text = like
                        self?.commentCount.text = comment
                    }
                }
            }
        }
    }
}

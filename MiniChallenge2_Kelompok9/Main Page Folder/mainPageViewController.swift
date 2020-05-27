//
//  mainPageViewController.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Laurentius Richard Reynaldo on 17/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit

class mainPageViewController: UIViewController, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var imageArray = [UIImage]()
    let webViewController = WebViewController.shared
    var dataArray = [WebViewController.InstagramMedia.InstagramCaption]()
    var selectImage: UIImage?
    var imagePosition: Int = 0
    var customArray = [CustomImageSorting]()
    
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
    @IBOutlet var leftScroll: UISwipeGestureRecognizer!
    @IBOutlet var rightScroll: UISwipeGestureRecognizer!
    
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
        customArray = []
        let mediaGroup = DispatchGroup()
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        indicator.center = view.center
        self.view.addSubview(indicator)
        self.view.bringSubviewToFront(indicator)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let summaryTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSummaryTap(_:)))
        postSummary.addGestureRecognizer(summaryTap)
        
        let customTap = CustomImageTapGesture.init(target: self, action: #selector(handleCustomTap))
        
        let scrollTap = UITapGestureRecognizer(target: self, action: #selector(self.handleScrollTap))
//        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleImageSwipe(_:)))
//        leftGesture.direction = .left
//        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleImageSwipe(_:)))
//        leftGesture.delegate = self
//        rightGesture.delegate = self
        scrollTap.delegate = self
        mainScrollView.addGestureRecognizer(scrollTap)
//        mainScrollView.addGestureRecognizer(leftGesture)
//        mainScrollView.addGestureRecognizer(rightGesture)
        
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
                    self?.profilePicture.downloaded(from: picture.mediaURL, imageGroup: nil)
                    imageGroup.enter()
                    var imageView: UIImageView?
                    DispatchQueue.main.async {
                        imageView = UIImageView()
                        imageView?.downloaded(from: picture.mediaURL, imageGroup: imageGroup)
//                        imageGroup.leave()
                    }
                    imageGroup.notify(queue: .main) {
                        customTap.imageTap = imageView
                        customTap.numberOfTapsRequired = 1
                        imageView?.addGestureRecognizer(customTap)
                        let customSort = CustomImageSorting()
                        customSort.imageData = imageView?.image!
                        customSort.timestamp = picture.timestamp.toDate()
                        let tempIdx = self?.customArray.insertionIndexOf(customSort) { $0.timestamp!.compare($1.timestamp!) == ComparisonResult.orderedDescending }
                        self?.customArray.insert(customSort, at: tempIdx!)
//                        if self?.customArray.count == 0 {
//                            self?.imageArray.append(imageView!.image!)
//                            self?.customArray.append(customSort)
//                        }else{
//                            for p in 0..<self!.customArray.count {
//                                if  (self?.customArray[p].timestamp)!.compare(customSort.timestamp!) == ComparisonResult.orderedAscending {
//                                    let temp = self?.customArray[p]
//                                    self?.customArray[p] = customSort
//                                    self?.customArray.append(temp!)
//                                    let tmp = self?.imageArray[p]
//                                    self?.imageArray[p] = imageView!.image!
//                                    self?.imageArray.append(tmp!)
//                                }else{
//                                    self?.customArray.append(customSort)
//                                    self?.imageArray.append(imageView!.image!)
//                                }
//                            }
//                        }
//                        self?.imageArray.append(imageView!.image!)
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
    
    @objc func handleSummaryTap(_ sender: UITapGestureRecognizer? = nil) {
        self.openCameraAndLibrary()
    }
    @objc func handleCustomTap(recognizer: CustomImageTapGesture) {
        // handling code
        print("custom tap")
        selectImage = recognizer.imageTap?.image
        self.performSegue(withIdentifier: "detailMain", sender: self)
    }
    @IBAction func handleImageSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender{
        case rightScroll:
            if imagePosition <= 0 {
                imagePosition = 0
            }else{
                imagePosition -= 1
            }
        case leftScroll:
            if (imagePosition >= (customArray.count-1)) {
                imagePosition = customArray.count - 1
            }else {
                imagePosition += 1
            }
        default:
            return
        }
        print(imagePosition)
    }
//    @objc func handleSwipeManual(_ sender: UISwipeGestureRecognizer) {
//        switch sender.direction{
//        case UISwipeGestureRecognizer.Direction.right:
//            imagePosition += 1
//        case UISwipeGestureRecognizer.Direction.left:
//            imagePosition -= 1
//        default:
//            return
//        }
//        print(imagePosition)
//    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

//        if (gestureRecognizer == mainS.panRecognizer || gestureRecognizer == mainScene.pinchRecognizer) && otherGestureRecognizer == mainScene.tapRecognizer {
        return true
//        }
//        return false
    }
    @objc func handleScrollTap(tap: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "detailMain", sender: self)
//        let location = tap.location(in: tap.view)
        // get the tag for the clicked imageView
//        guard let tag = tap.view?.tag else { return }

//        for n in 0..<mainScrollView.subviews.count{
//            let subViewTapped = mainScrollView.subviews[n]
//            if subViewTapped.frame.contains(location) {
        // iterate through your scrollViews subviews
           // and check if it´s an imageView
//           for case let imageView as UIImageView in mainScrollView.subviews {
               // check if the tag matches the clicked tag
//               if imageView.tag == tag {
                   // this is the tag the user has clicked on
                   // highlight it here
//                selectImage = imageView.image
//                print("tapped subview at index\(n)")
                // do your stuff here
//            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailMain" {
            let navPage = segue.destination as! UINavigationController
            let detailPage = navPage.topViewController as! detailPageViewController
//            detailPage.selectedImage = selectImage
            detailPage.selectedImage = customArray[imagePosition].imageData
//            detailPage.selectedImage = imageArray[imagePosition]
            print(imagePosition)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class CustomImageTapGesture: UITapGestureRecognizer {
    var imageTap: UIImageView!
}

class CustomImageSorting {
    var imageData: UIImage!
    var timestamp: Date?
}

extension String {
    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: self)
    }
}

extension Array {
    func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

extension UIImageView {
    func downloaded(from url: URL, imageGroup: DispatchGroup?, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
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
                if imageGroup != nil {
                    imageGroup?.leave()
                }
            }
        }.resume()
    }
    func downloaded(from link: String, imageGroup: DispatchGroup?, contentMode mode: UIView.ContentMode = .scaleAspectFit) {  // for swift 4.2 syntax just use ===> mode: UIView.ContentMode
        guard let url = URL(string: link) else { return }
        downloaded(from: url, imageGroup: imageGroup, contentMode: mode)
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
                self.selectImage? = imageTaken
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

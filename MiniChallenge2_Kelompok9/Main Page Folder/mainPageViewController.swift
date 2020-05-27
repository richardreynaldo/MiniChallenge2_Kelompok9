//
//  mainPageViewController.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Laurentius Richard Reynaldo on 17/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit
import CoreML
import Vision

class mainPageViewController: UIViewController, UIGestureRecognizerDelegate {

    // Create request to CoreML
       lazy var analyseRequest: VNCoreMLRequest = {
           do {
               let model = try VNCoreMLModel(for: ContentType().model) // Initiate the ML Model to our request
               let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
                   self?.processToAnalyse(for: request, error: error) // Ask the machine to process evaluate the object request and give the result based on the ML Model.
               }
               request.imageCropAndScaleOption = .centerCrop
               return request
           } catch {
               fatalError("Failed to load ML Model: \(error)")
           }
       }()
    
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
//    @IBOutlet weak var totalPhoto: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet var leftScroll: UISwipeGestureRecognizer!
    @IBOutlet var rightScroll: UISwipeGestureRecognizer!
    
    //Tutorial View Outlet
    
    @IBOutlet weak var tutor1View: UIView!
    @IBOutlet weak var tutor2View: UIView!
    @IBOutlet weak var tutor3View: UIView!
    @IBOutlet weak var tutor4View: UIView!
    @IBOutlet weak var tutor5View: UIView!
    
    @IBOutlet weak var manualButton: UIButton!
    @IBOutlet weak var adviseView: UIView!
    @IBOutlet weak var adviseText: UILabel!
    @IBOutlet weak var typeText: UILabel!
    
    //Define CollectionView and CollectionView ID
    @IBOutlet weak var accountGrowthCollectionView: UICollectionView!
    var accountGrowthCollectionViewId = "AccountGrowthCollectionViewCell"
    var accountCategory = [AccountGrowthCategory]()
    var imageAccountGrowth = ["followers icon", "profile visit icon", "total post icon" ]
    var categoryNameAccountGrowth = ["Followers","Profile Visit","Total Post"]
    var categoryValueAccountGrowth = ["26.7k", "40.1k", "100"]
    //---------------------------------------------
    
    //Function Tutorial
    
    @IBAction func tutor1Button(_ sender: Any) {
        tutor1View.alpha = 0
        tutor3View.alpha = 1
    }
    @IBAction func skip1Button(_ sender: Any) {
        tutor1View.alpha = 0
    }
    @IBAction func tutor3Button(_ sender: Any) {
        tutor3View.alpha = 0
        tutor2View.alpha = 1
    }
    @IBAction func skip3Button(_ sender: Any) {
        tutor3View.alpha = 0
    }
    @IBAction func tutor2Button(_ sender: Any) {
        tutor2View.alpha = 0
        tutor4View.alpha = 1
    }
    @IBAction func skip2Button(_ sender: Any) {
        tutor2View.alpha = 0
    }
    @IBAction func tutor4Button(_ sender: Any) {
        tutor4View.alpha = 0
        tutor5View.alpha = 1
    }
    @IBAction func skip4Button(_ sender: Any) {
        tutor4View.alpha = 0
        
    }
    @IBAction func tutor5Button(_ sender: Any) {
        tutor5View.alpha = 0
    }
    @IBAction func skip5Button(_ sender: Any) {
        tutor5View.alpha = 0
    }
    
    var dismissResult = 0
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        tutor1View.alpha = 1
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
//        summaryTap.view?.tag = 101
//        postSummary.addGestureRecognizer(summaryTap)
        adviseView.addGestureRecognizer(summaryTap)
        
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
        
//        summaryTap.view?.tag = 102
         let growthTap = UITapGestureRecognizer(target: self, action: #selector(self.handleGrowthTap(_:)))
        accountGrowthCollectionView.addGestureRecognizer(growthTap)
        
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
//                    self?.totalPhoto.text = "\(caption.data.count)"
                    self?.typeText.text = "Your Total Photo: \(caption.data.count)"
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
        
        //Register Cell
        let nibCell = UINib(nibName: accountGrowthCollectionViewId, bundle: nil)
        accountGrowthCollectionView.register(nibCell, forCellWithReuseIdentifier: accountGrowthCollectionViewId)
        //-------------------------------------------
        
        //Init Data
        for j in 0...2{
            let category = AccountGrowthCategory()
            category.id = j
            category.imageCategory = imageAccountGrowth[j]
            category.categoryName = categoryNameAccountGrowth[j]
            category.categoryValue = categoryValueAccountGrowth[j]
            accountCategory.append(category)
            
        }
        accountGrowthCollectionView.reloadData()
        //---------------------------------
    }
    
    @objc func handleSummaryTap(_ sender: UITapGestureRecognizer? = nil) {
//        switch sender?.view?.tag {
//        case 101:
//            dismissResult = 1
//        case 102:
//            dismissResult = 2
//        default:
//            return
//        }
        dismissResult = 1
        self.openCameraAndLibrary()
    }
    @objc func handleGrowthTap(_ sender: UITapGestureRecognizer? = nil) {
        dismissResult = 2
        self.openCameraAndLibrary()
    }
    @objc func handleCustomTap(recognizer: CustomImageTapGesture) {
        // handling code
        print("custom tap")
        selectImage = recognizer.imageTap?.image
        self.performSegue(withIdentifier: "detailMain", sender: self)
    }
    @IBAction func handleAnalyseButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "detailNew", sender: self)
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
        self.convertImageToAnalysed(image: customArray[imagePosition].imageData)
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
        if segue.identifier != "settingNew" {
            let navPage = segue.destination as! UINavigationController
            let detailPage = navPage.topViewController as! detailPageViewController
    //            detailPage.selectedImage = selectImage
            switch segue.identifier {
            case "detailMain":
                detailPage.selectedImage = customArray[imagePosition].imageData
            case "detailNew":
                detailPage.selectedImage = nil
            default:
                return
            }
    //            detailPage.selectedImage = imageArray[imagePosition]
        }
        print(imagePosition)
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
                    switch self?.dismissResult {
                    case 1:
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
//                            self?.reachRate.text = engage
//                            self?.discoveryCount.text = reach
//                            self?.loveCount.text = like
//                            self?.commentCount.text = comment

                            self?.adviseText.text! = "Your Engage: \(engage)"
                            self?.adviseText.text! += "\n Your Reach: \(reach)"
                            self?.adviseText.text! += "\n Total Like: \(like)"
                            self?.adviseText.text! += "\n Total Comment: \(comment)"
                        }
                    case 2:
//                        var following = "", labelFollowing = "", labelFollower = "", follower = "", labelPost = "", post = ""
                        for q in 0..<splitText.count {
                            let category = AccountGrowthCategory()
                            switch splitText[q] {
                                case "Following":
                                category.id = 1
                                category.imageCategory = self?.imageAccountGrowth[1]
                                category.categoryName = splitText[q]
                                category.categoryValue = splitText[q-1]
                                self?.accountCategory[1] = category
//                                    labelFollowing = splitText[q]
//                                    following = splitText[q-1]
                                case "Followers":
//                                    labelFollower = splitText[q]
//                                    follower = splitText[q-1]
                                category.id = 0
                                category.imageCategory = self?.imageAccountGrowth[0]
                                category.categoryName = splitText[q]
                                category.categoryValue = splitText[q-1]
                                self?.accountCategory[0] = category
                                case "Posts":
//                                    labelPost = splitText[q]
//                                    post = splitText[q-1]
                                category.id = 2
                                category.imageCategory = self?.imageAccountGrowth[2]
                                category.categoryName = splitText[q]
                                category.categoryValue = splitText[q-1]
                                self?.accountCategory[2] = category
                                default:
                                continue
                            }
                        }
                        DispatchQueue.main.async {
                            self?.accountGrowthCollectionView.reloadData()
                        }
//                        let growthGroup = DispatchGroup()
//                            growthGroup.enter()
//                            var growthCount = 0
//                            for cell in (self?.accountGrowthCollectionView.visibleCells as? [AccountGrowthCollectionViewCell])! {
//                                    switch growthCount {
//                                    case 1:
//                                        cell.labelCategoryName.text = labelFollowing
//                                        cell.labelCategoryValue.text = following
//                                    case 0:
//                                        cell.labelCategoryName.text = labelFollower
//                                        cell.labelCategoryValue.text = follower
//                                    case 2:
//                                        cell.labelCategoryName.text = labelPost
//                                        cell.labelCategoryValue.text = post
//                                    default:
//                                        return
//                                    }
//                                growthCount += 1
//                           }
//                            growthGroup.enter()
//                        }
//                        growthGroup.notify(queue: .main) {
//                            self?.accountGrowthCollectionView.reloadData()
//                        }
                    default:
                        return
                    }
                }
            }
        }
    }
}

extension mainPageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return accountCategory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: accountGrowthCollectionViewId, for: indexPath) as! AccountGrowthCollectionViewCell
        let category = accountCategory[indexPath.row]
        cell.imageCategory.image = UIImage(named: category.imageCategory!)
        cell.labelCategoryName.text = category.categoryName
        cell.labelCategoryValue.text = category.categoryValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let inset: CGFloat = 10
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = accountCategory[indexPath.row]
        print("\(indexPath.row) - \(category.id)")
    }
    
    
}

// MARK: Machine learning process goes here
extension mainPageViewController {
    func convertImageToAnalysed(image: UIImage) {
        typeText.text = "Analysing.."
        let imageProperty = CGImagePropertyOrientation(rawValue: UInt32(image.imageOrientation.rawValue)) // Convert from UIImage property to CoreImage Property -> UIImage >< CIImage, CIImage is format used by Vision
        guard let ciImageTemporary = CIImage(image: image) else {
            fatalError("Unable to create \(CIImage.self) from \(image).") // Convert failed
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            // Create under background thread with qos property, due to heavy task for image processing, so we try to avoid do this process under main / UI Thread to avoid leak or crash due to memory leak.
            let handler = VNImageRequestHandler(ciImage: ciImageTemporary, orientation: imageProperty!) // create instance for the request Vision handler to process image processing
            do {
                try handler.perform([self.analyseRequest]) // perform request based on the handler and analyse it and update to UI under main thread
            } catch {
                print("Failed to perform.")
            }
        }
    }
    
    // This part of Image Classification from CoreML to have a decision based on the model we use.
    func processToAnalyse(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.typeText.text = "Can not analyse the object."
                return
            }
            let classifications = results as! [VNClassificationObservation] // create instance for observations returned by VNCoreMLRequest that using a model which is image classifier. A classifier produces set of array of classifications which are labels and confidence score.
            if classifications.isEmpty {
                self.typeText.text = "Nothing to analysed."
            }else {
                let importantInformation = classifications.prefix(2) // only get 2 top information from the results, which are the confidence value and identifier value
//                let readableStringResult = importantInformation.map { (classification) in
//                    return String(format: "(%.2f), %@", classification.confidence, classification.identifier) // Convert key value from classification result given by CoreML decision, to readable string
//                }
                let readableStringResult = importantInformation.map { (classification) in
                    return String(format: "%@", classification.identifier) // Convert key value from classification result given by CoreML decision, to readable string
                }
//                self.typeText.text = readableStringResult.joined(separator: " | ")
                self.typeText.text = readableStringResult[0]
            }
        }
    }
}

//
//  detailPageViewController.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Michael Geoferey on 17/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit

class detailPageViewController: UIViewController {

//    @IBOutlet weak var detailImage: UIImageView!
    var selectedImage: UIImage!
    let webViewController = WebViewController.shared
//    let mainViewController = mainPageViewController.shared
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var uploadText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        detailImage.image = selectedImage
        if selectedImage != nil {
            uploadImage.image = selectedImage
        }else{
            uploadImage.image = #imageLiteral(resourceName: "upload photo")
        }
        let uploadTap = UITapGestureRecognizer(target: self, action: #selector(self.handleUploadTap(_:)))
        uploadImage.addGestureRecognizer(uploadTap)
        // Do any additional setup after loading the view.
    }
    
    @objc func handleUploadTap(_ sender: UITapGestureRecognizer? = nil) {
        self.openCameraAndLibrary()
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

// Extension to make more structured
extension detailPageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                self.uploadImage?.image = imageTaken
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
                        self?.uploadText.text! += "\n Your Engage: \(engage)"
                        self?.uploadText.text! += "\n Your Reach: \(reach)"
                        self?.uploadText.text! += "\n Total Like: \(like)"
                        self?.uploadText.text! += "\n Total Comment: \(comment)"
                    }
                }
            }
        }
    }
}

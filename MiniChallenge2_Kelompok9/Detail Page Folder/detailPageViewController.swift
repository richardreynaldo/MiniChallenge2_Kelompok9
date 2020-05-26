//
//  detailPageViewController.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Michael Geoferey on 17/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit

class detailPageViewController: UIViewController {

    @IBOutlet weak var detailImage: UIImageView!
    var selectedImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        detailImage.image = selectedImage
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

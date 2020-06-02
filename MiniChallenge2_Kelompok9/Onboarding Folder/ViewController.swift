//
//  ViewController.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Laurentius Richard Reynaldo on 06/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {
    
    var slides:[OnboardSlide] = [];
    
    @IBOutlet weak var onboardScrollView: UIScrollView!
    @IBOutlet weak var getstartedBtn: UIButton!
    @IBOutlet weak var onboardPageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        onboardPageControl.numberOfPages = slides.count
        onboardPageControl.currentPage = 0
        view.bringSubviewToFront(onboardPageControl)
        
        onboardScrollView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func createSlides() -> [OnboardSlide] {
        
        let slide1:OnboardSlide = Bundle.main.loadNibNamed("onboardSlide", owner: self, options: nil)?.first as! OnboardSlide
        slide1.onboardImage.image = UIImage(named: "pixel")
        slide1.onboardLabel.text = "Get to know your potential brand awareness"
        
        let slide2:OnboardSlide = Bundle.main.loadNibNamed("onboardSlide", owner: self, options: nil)?.first as! OnboardSlide
        slide2.onboardImage.image = UIImage(named: "business")
        slide2.onboardLabel.text = "Find out who’s your customer"
        
        let slide3:OnboardSlide = Bundle.main.loadNibNamed("onboardSlide", owner: self, options: nil)?.first as! OnboardSlide
        slide3.onboardImage.image = UIImage(named: "graphic")
        slide3.onboardLabel.text = "Track your campaign progress and evaluate with your team"
        
        
        return [slide1, slide2, slide3]
    }
    
    func setupSlideScrollView(slides : [OnboardSlide]) {
        
        onboardScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        onboardScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        onboardScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            onboardScrollView.addSubview(slides[i])
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        onboardPageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.50) {
            
            slides[0].onboardImage.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.50, y: (0.50-percentOffset.x)/0.50)
            slides[1].onboardImage.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 1) {
            slides[1].onboardImage.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.50, y: (1-percentOffset.x)/0.50)
            slides[2].onboardImage.transform = CGAffineTransform(scaleX: percentOffset.x/1, y: percentOffset.x/1)
            
        }
        
        
    }
    
}


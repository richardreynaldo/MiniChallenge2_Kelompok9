//
//  UtilityAnimation.swift
//  MiniChallenge2_Kelompok9
//
//  Created by Michael Geoferey on 08/05/20.
//  Copyright © 2020 Laurentius Richard Reynaldo. All rights reserved.
//

import UIKit

class UtilityAnimation: NSObject {

}

extension UIView{
    
    public enum Animation{
        case left
        case right
        //default case nya
        case none
    }
    
    func slideIn(from edge: Animation = .none, x: CGFloat = 0, y: CGFloat = 0, duration: TimeInterval = 0, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil ) -> UIView
    {
        let offset = offsetFor(edge: edge)
        
        transform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        
        isHidden = false
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
            
            self.transform = .identity
            self.alpha = 1
            
        }, completion: completion)
        
        return self
    }
    
    func slideOut(from edge: Animation = .none, x: CGFloat = 0, y: CGFloat = 0, duration: TimeInterval = 0, delay: TimeInterval = 0, completion: ((Bool) -> Void)? = nil) -> UIView
    {
        let offset = offsetFor(edge: edge)
        
        let endtransform = CGAffineTransform(translationX: offset.x + x, y: offset.y + y)
        
        
        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 2, options: .curveEaseOut, animations: {
            
            self.transform = endtransform
            self.alpha = 1
            
        }, completion: completion)
        
        
        return self
    }
    
    private func offsetFor(edge: Animation) -> CGPoint {
        if let size = self.superview?.frame.size{
            
            switch edge{
            case.none: return CGPoint.zero
            
            case.left : return CGPoint(x: -accessibilityFrame.maxX, y: 0)
                
            case.right : return CGPoint(x: size.width - accessibilityFrame.minX, y:0)
            }
            
        }
        return .zero
    }
}

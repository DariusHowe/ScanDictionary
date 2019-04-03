//
//  ProgressView.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/27/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import UIKit.UIView

class ProgressView: UIView {
    
    var progress: UInt = 0
    
    func setProgress(progress: UInt) {
        self.progress = progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        
        let rect = CGRect(origin: self.bounds.origin, size: self.frame.size.applying(CGAffineTransform(scaleX: CGFloat(progress)/100, y: 1)))
        
        let color = UIColor(displayP3Red: 7/255.0, green: 210/255.0, blue: 255/255.0, alpha: 1)
        let bpath:UIBezierPath = UIBezierPath(rect: rect)
        
        
        color.set()
        bpath.stroke()
        bpath.fill()
    }
    
    
}

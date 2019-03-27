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
        
        let color: UIColor = UIColor.cyan
        let bpath:UIBezierPath = UIBezierPath(rect: rect)
        
        
        color.set()
        bpath.stroke()
        bpath.fill()
    }
    
    
}

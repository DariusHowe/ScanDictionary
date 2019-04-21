//
//  View.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/25/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import UIKit.UIView

class ScopeView: UIView {
    
    
    let lineWidth: CGFloat = 4
    let color = UIColor(displayP3Red: 7/255.0, green: 210/255.0, blue: 255/255.0, alpha: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let path = UIBezierPath()
        path.move(to: rect.origin)
        path.addLine(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        path.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.maxY))
        path.addLine(to: CGPoint(x: self.bounds.maxX, y: self.bounds.minY))
        path.lineWidth = lineWidth
        
        color.set()
        
        path.stroke()
    }

}

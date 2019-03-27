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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let color: UIColor = UIColor.black
        
        let bpath:UIBezierPath = UIBezierPath(rect: rect)
        
        color.set()
        bpath.stroke()
    }
    
    func centerWithinSuperview() {
        
    }
}

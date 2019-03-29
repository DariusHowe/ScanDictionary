//
//  CameraPreview.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/26/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import UIKit.UIView
import AVFoundation

class CameraPreview: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.backgroundColor = UIColor.clear

    }
    
    func setupPreview(for session: AVCaptureSession) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        previewLayer.frame = self.bounds
        self.layer.addSublayer(previewLayer)
    }
}

extension CGRect {
    var center: CGPoint { return CGPoint(x: midX, y: midY) }
}

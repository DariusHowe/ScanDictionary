//
//  Camera.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/25/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import AVFoundation

class Camera: NSObject, AVCapturePhotoCaptureDelegate {
    
    /* Camera & Preview */
    private let captureSession = AVCaptureSession()
    private let capturePhotoOutput = AVCapturePhotoOutput()
    @objc var captureDevice: AVCaptureDevice?
    
    override init() {
        super.init()
        /* Camera */
        self.captureSession.sessionPreset = .photo
        if let device = AVCaptureDevice.default(for: .video) {
            self.captureDevice = device
        } else {
            print("No Camera")
            return
        }
        
        let input = try! AVCaptureDeviceInput(device: self.captureDevice!)
        self.captureSession.addInput(input)
        
        self.captureSession.addOutput(self.capturePhotoOutput)
        capturePhotoOutput.connection(with: AVFoundation.AVMediaType.video)!.videoOrientation = .portrait
        
        
//        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
//        self.previewLayer?.frame = self.preView.bounds
//        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
//        self.preView.layer.addSublayer(self.previewLayer!)
        
        self.captureSession.startRunning()
    }
    
    func run() {
        
    }
}

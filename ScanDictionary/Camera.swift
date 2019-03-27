//
//  Camera.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/25/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class Camera: NSObject, AVCapturePhotoCaptureDelegate {
    
    /* Camera & Preview */
    let captureSession = AVCaptureSession()
    
    private let capturePhotoOutput = AVCapturePhotoOutput()
    @objc var captureDevice: AVCaptureDevice?
    
    override init() {
        super.init()
        /* Camera */
        if let device = AVCaptureDevice.default(for: .video) {
            self.captureDevice = device
        } else {
            print("No Camera")
            return
        }
        self.captureSession.sessionPreset = .photo
        let input = try! AVCaptureDeviceInput(device: self.captureDevice!)
        self.captureSession.addInput(input)
        
        self.captureSession.addOutput(self.capturePhotoOutput)
        capturePhotoOutput.connection(with: AVFoundation.AVMediaType.video)!.videoOrientation = .portrait
    }
    
    func run() {
        /* The startRunning() method is a blocking call which can take some time, therefore you should perform session setup on a serial queue so that the main queue isn't blocked (which keeps the UI responsive). */
        self.captureSession.startRunning()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let data = photo.fileDataRepresentation() else { return }

        let image = CIImage(data: data)!.oriented(CGImagePropertyOrientation.right)
        onCapture?(image)
    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
    }
    
    var onCapture: ((CIImage) -> ())?
    
    func capture(result: @escaping (CIImage) -> Void) {
        let photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .off
        photoSettings.isHighResolutionPhotoEnabled = false
        self.capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        onCapture = { image in
            result(image)
        }
    }
}

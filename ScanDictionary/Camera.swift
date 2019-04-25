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
//    @objc private var captureDevice: AVCaptureDevice?
    private var onCapture: ((CIImage) -> ())?

    override init() {
        super.init()
        /* Camera */
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No Camera")
            return
        }
        
        do  {
            let input = try AVCaptureDeviceInput(device: device)
            self.captureSession.addInput(input)
        } catch {
            print(error)
            return
        }
        
        self.captureSession.sessionPreset = .photo
        capturePhotoOutput.connection(with: AVFoundation.AVMediaType.video)?.videoOrientation = .portrait
        self.captureSession.addOutput(self.capturePhotoOutput)

        
    }
    
    func run() {
        /* The startRunning() method is a blocking call which can take some time, therefore you should perform session setup on a serial queue so that the main queue isn't blocked (which keeps the UI responsive). */
        let serialQueue = DispatchQueue(label: "serialQueue")
        serialQueue.sync {
            self.captureSession.startRunning()
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = CIImage(data: data)?.oriented(CGImagePropertyOrientation.right) else { return }
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
    
    
    func capture(result: @escaping (CIImage) -> Void) {
        print(#function)
        
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

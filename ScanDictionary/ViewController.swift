//
//  ViewController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 2/4/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import UIKit
import TesseractOCR
import AVFoundation
import Photos

class ViewController: UIViewController, G8TesseractDelegate, AVCapturePhotoCaptureDelegate {

    private let captureSession = AVCaptureSession()
    var capturePhotoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @objc var captureDevice: AVCaptureDevice?

    @IBOutlet var preView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            print("Authorized")
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("Print Access Given")
                }
            }
        case .denied: // The user has previously denied access.
            return
        case .restricted: // The user can't grant access due to restrictions.
            return
        }

        self.captureSession.sessionPreset = .photo
        self.capturePhotoOutput = AVCapturePhotoOutput()
        
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        self.captureDevice = device
        let input = try! AVCaptureDeviceInput(device: self.captureDevice!)
        self.captureSession.addInput(input)
        self.captureSession.addOutput(self.capturePhotoOutput!)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.frame = self.preView.bounds
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.preView.layer.addSublayer(self.previewLayer!)
        self.captureSession.startRunning()
        

        
//        guard let tesseract: G8Tesseract = G8Tesseract(language:"eng+ita") else { return }
//        tesseract.delegate = self
//        tesseract.charWhitelist = "-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890"
//        
//        tesseract.image = UIImage(named: "vrkIj.png")!
//        tesseract.recognize()
//
//        print(tesseract.rect)
//        print(tesseract.recognizedText ?? "")

    }

    @IBAction func capture(_ sender: Any) {
        print(#function)

        let photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .off
        photoSettings.isHighResolutionPhotoEnabled = false
        self.capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print(#function)
     
        guard let tesseract: G8Tesseract = G8Tesseract(language:"eng+ita") else { return }
        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: data) else { return }
        
        tesseract.delegate = self
        tesseract.charWhitelist = "-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890"
        tesseract.image = image
        tesseract.recognize()

        print(tesseract.rect)
        print(tesseract.recognizedText ?? "")

    }
    
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        print(#function)
        guard error == nil else {
            print("Error in capture process: \(String(describing: error))")
            return
        }
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract) {
        print("Recognition Process \(tesseract.progress) %")
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }

}


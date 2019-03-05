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
    private let capturePhotoOutput = AVCapturePhotoOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    @objc var captureDevice: AVCaptureDevice?

    @IBOutlet var preView: UIView!

    let tesseract = G8Tesseract(language:"eng")!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
//      Initialize Tesseract
        tesseract.delegate = self
        tesseract.charWhitelist = "-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890"
//        tesseract.engineMode = .tesseractCubeCombined
//        tesseract.pageSegmentationMode = .singleBlock

        
        let image = UIImage(named: "Test2.jpg")
        tesseract.image = image!
        tesseract.recognize()
        
        print(tesseract.rect)
        print(tesseract.recognizedText ?? "")
        return;
//      Request Authorization
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
//        AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No Camera")
//          Disable button
            return
            
        }
        self.captureDevice = device
        
        let input = try! AVCaptureDeviceInput(device: self.captureDevice!)
        self.captureSession.addInput(input)
        self.captureSession.addOutput(self.capturePhotoOutput)
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.frame = self.preView.bounds
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.preView.layer.addSublayer(self.previewLayer!)
        self.captureSession.startRunning()

    }

    @IBAction func capture(_ sender: Any) {
        print(#function)

        let photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = .off
        photoSettings.isHighResolutionPhotoEnabled = false
        self.capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
     
        guard let data = photo.fileDataRepresentation() else { return }
        guard let image = UIImage(data: data) else { return }
//        let my300dpiImage = UIImage(cgImage: image.cgImage!, scale: 300.0 / 72.0, orientation: .up)
        
        print(image.imageRendererFormat)
        print(image.scale)
        
        let newImage = UIImage(data: image.pngData()!)!
        let imageView  = UIImageView(image: newImage)
        imageView.frame = self.preView.bounds
        self.preView.addSubview(imageView)
        self.previewLayer?.removeFromSuperlayer()
        self.preView.addSubview(imageView)
        
        tesseract.image = newImage.noir()
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

extension UIImage {
    var blackAndWhite: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        
        return processedImage
    }
    
    
}

extension UIImage {
    
    func noir() -> UIImage {
        let context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")
        currentFilter!.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter!.outputImage
        let cgimg = context.createCGImage(output!, from: output!.extent)
        let processedImage = UIImage(cgImage: cgimg!, scale: scale, orientation: imageOrientation)
        return processedImage
    }}

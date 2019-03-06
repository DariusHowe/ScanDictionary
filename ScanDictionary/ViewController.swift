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
import GPUImage

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

//        GPUImageAverageLuminanceThresholdFilter
        
//        let image = UIImage(named: "Test2.jpg")!
        var image = UIImage(named: "screencapture.jpg")!
        image = UIImage(cgImage: image.cgImage!, scale: 1, orientation: image.imageOrientation)


        print(image.size)

//        let luminanceThresholdFilter = GPUImageLuminanceThresholdFilter()
//        luminanceThresholdFilter.threshold = 0.3
//        image = luminanceThresholdFilter.image(byFilteringImage: image)!
        
//        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
//        stillImageFilter.blurRadiusInPixels = 4.0
//        image = stillImageFilter.image(byFilteringImage: image)!

        let imageView  = UIImageView(image: image)
        imageView.frame = self.preView.bounds
        self.preView.addSubview(imageView)
        
        tesseract.image = image
        tesseract.recognize()

       
//        let k = Draw(frame: CGRect(
//            origin: CGPoint(x: 50, y: 50),
//            size: CGSize(width: 964, height: 1302)))
        
        // Add the view to the view hierarchy so that it shows up on screen
//        self.view.addSubview(k)
        
        
        print(tesseract.rect)
        
        print(tesseract.recognizedText ?? "No Text Recognized")

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
        
        tesseract.image = newImage
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
    
    func preprocessedImage(for tesseract: G8Tesseract, sourceImage: UIImage) -> UIImage? {
        // sourceImage is the same image you sent to Tesseract above
        print(#function)
        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
        stillImageFilter.blurRadiusInPixels = 4
        let filteredImage = stillImageFilter.image(byFilteringImage: sourceImage)

        return filteredImage
    }

}



class Draw: UIView {
    
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
    
}

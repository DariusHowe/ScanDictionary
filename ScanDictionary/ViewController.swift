//
//  ViewController.swift
//  ScanDictionaryc 
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
    
    private var capturePhoto = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let utterance = AVSpeechUtterance(string: "hello world!")
//        let synth = AVSpeechSynthesizer()
//        synth.speak(utterance)
        

//        if let tesseract = G8Tesseract(language: "eng+fra") {
//
//            tesseract.engineMode = .tesseractCubeCombined
//
//            tesseract.pageSegmentationMode = .auto
//
//        }
        
//      Initialize Tesseract
        tesseract.rect = self.preView.bounds
        tesseract.delegate = self
        tesseract.charWhitelist = "-_(){}[]=%.,?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890/"

        
        print(tesseract.isEngineConfigured)
    //      Request Authorization
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            print("Authorized:")
            
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
        guard let device = AVCaptureDevice.default(for: .video) else {
            print("No Camera")
//          Disable button
            return
        }
        self.captureDevice = device
        let input = try! AVCaptureDeviceInput(device: self.captureDevice!)
        self.captureSession.addInput(input)
       
        
        self.captureSession.addOutput(self.capturePhotoOutput)
        capturePhotoOutput.connection(with: AVFoundation.AVMediaType.video)!.videoOrientation = .portrait
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.frame = self.preView.bounds
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        print("Bounds")
        print(self.preView.bounds)
        print(self.previewLayer!.bounds)
        self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.preView.layer.addSublayer(self.previewLayer!)
        self.captureSession.startRunning()
    }
    
    var scope: Draw!
    var imageView: UIImageView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            let bounds = self.preView.bounds

            let height: CGFloat = 0.15 * bounds.height
            let width = 0.75 * bounds.width
            
            let origin = CGPoint(x: (bounds.maxX / 2) - (width / 2), y: (bounds.maxY / 2) - (height / 2))
            self.scope = Draw(frame: CGRect(
                origin: origin,
                size: CGSize(width: width, height: height)))
            
            //      Add the view to the view hierarchy so that it shows up on screen
            self.preView.addSubview(self.scope)
            print("Bounds for scope: \(self.scope.bounds)")
        }
    }
    
    @IBAction func capture(_ sender: UIButton) {
        print(#function)
     
        if capturePhoto {
            let photoSettings = AVCapturePhotoSettings.init(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            photoSettings.isAutoStillImageStabilizationEnabled = true
            photoSettings.flashMode = .off
            photoSettings.isHighResolutionPhotoEnabled = false
            self.capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
            DispatchQueue.main.async {
//                self.captureSession.stopRunning()
                sender.setTitle("reset", for: UIControl.State.normal)

            }
            capturePhoto = false
            
        } else {
            capturePhoto = true
            sender.setTitle("Take photo", for: UIControl.State.normal)
//            self.captureSession.startRunning()
            self.imageView.removeFromSuperview()

        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let data = photo.fileDataRepresentation() else { return }

        var ci_image = CIImage(data: data)!.oriented(CGImagePropertyOrientation.right)
        
        let height = ci_image.extent.height
        let width = ci_image.extent.width
        let newHeight = 0.15 * ci_image.extent.height
        let newWidth = 0.75 * ci_image.extent.width
        
        let origin = CGPoint(x: (width / 2) - (newWidth / 2), y: (height / 2) - (newHeight / 2)) // centers vertically & horizontally
        let size = CGSize(width: newWidth, height: newHeight)
        
        ci_image = ci_image.cropped(to: CGRect(origin: origin, size: size))
    
        var image = UIImage(cgImage: CIContext().createCGImage(ci_image, from:ci_image.extent)!)
        
        let luminanceThresholdFilter = GPUImageLuminanceThresholdFilter()
        luminanceThresholdFilter.threshold = 0.4
        image = luminanceThresholdFilter.image(byFilteringImage: image)!
        
        print("Width: \(image.size.width)\t Height: \(image.size.height)")

        imageView = UIImageView(image: image)
        imageView.contentMode = UIView.ContentMode.scaleAspectFill
        imageView.frame = scope.bounds
        
        DispatchQueue.main.async {
            self.scope.addSubview(self.imageView)
        }
        
        processImage(image)
    }
    
    func processImage(_ image: UIImage) {
//        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
//        stillImageFilter.blurRadiusInPixels = 4.0
//        let Tesseractimage = stillImageFilter.image(byFilteringImage: image)!
        
        tesseract.image = image
        
        print()
        
        print(tesseract.rect)
 
//      tesseract.rect = self.preView.bounds
        
        tesseract.recognize()

        print(tesseract.recognizedText ?? "Error")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings)
    {
        print("Just about to take a photo.")
        // get device orientation on capture
        let deviceOrientationOnCapture = UIDevice.current.orientation
        print("Device orientation: \(deviceOrientationOnCapture.rawValue)")
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
    
//    func preprocessedImage(for tesseract: G8Tesseract, sourceImage: UIImage) -> UIImage? {
//        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
//        stillImageFilter.blurRadiusInPixels = 4
//        let filteredImage = stillImageFilter.image(byFilteringImage: sourceImage)
//
//        return filteredImage
//    }
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


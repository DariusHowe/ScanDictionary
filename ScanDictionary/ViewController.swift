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
    
    /* Picker */
    var pickerData = ["eastsides", "asdasdasd", "random", "work"]
    var currentPickerIndex = 0
    @IBOutlet weak var pickerView: UIPickerView!
    
    /* Camera & Preview */
    private let captureSession = AVCaptureSession()
    private let capturePhotoOutput = AVCapturePhotoOutput()
    @objc var captureDevice: AVCaptureDevice?

    var previewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet var preView: UIView!
    private var capturePhoto = true // used for testing - will be removed

    
    /* Views */
    var scope: Draw!
    var imageView: UIImageView!

    let tesseract = G8Tesseract(language:"eng")!
    
    let webScrapper = WebScrapperHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        let utterance = AVSpeechUtterance(string: "hello world!")
//        let synth = AVSpeechSynthesizer()
//        synth.speak(utterance)
        
//        if let tesseract = G8Tesseract(language: "eng+fra") {
//            tesseract.engineMode = .tesseractCubeCombined
//            tesseract.pageSegmentationMode = .auto
//        }
        
//      Initialize Tesseract
        tesseract.rect = self.preView.bounds
        tesseract.delegate = self
        tesseract.charWhitelist = "-_(){}[]=%.,?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890/"

        /* Request Authorization */
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
        
        /* Set up preview */
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer?.frame = self.preView.bounds
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.preView.layer.addSublayer(self.previewLayer!)
        
        self.captureSession.startRunning()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        DispatchQueue.main.async {
            let bounds = self.preView.bounds

            let height: CGFloat = 0.15 * bounds.height
            let width = 0.75 * bounds.width
            
            let origin = CGPoint(x: (bounds.maxX / 2) - (width / 2), y: (bounds.maxY / 2) - (height / 2))
            self.scope = Draw(frame: CGRect(
                origin: origin,
                size: CGSize(width: width, height: height)))
            
            /* Add the view to the view hierarchy so that it shows up on screen */
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
    
    
    @IBAction func search(_ sender: Any) {
        let word = pickerData[currentPickerIndex]
        search(for: word)
    }
    
    private func search(for word: String) {
        print(#function, "for", word)
        webScrapper.getDefinition(for: word) { (result) in
            guard let word = result as? Word? else {
                self.searchHelper(result)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let definitionController = storyboard.instantiateViewController(withIdentifier: "DefinitionViewController") as! DefinitionViewController
            
            definitionController.word = word
            DispatchQueue.main.async {
                print("PRESENTING")
                self.present(definitionController, animated: true, completion: nil)
            }
        }
    }
    
    /* Handles misspelled words and no results */
    private func searchHelper(_ result: Any?) {
        print(#function)
        print("**************")
        DispatchQueue.main.async {
            var title: String?
            var message: String?
            var alertController: UIAlertController!
            if let suggestion = result as! String? {
                title = "Misspelled Word"
                message = "Did you mean \(suggestion)"
                alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(self.yesAction(for: suggestion))
                alertController.addAction(self.noAction())
            } else if result == nil {
                title = "No Result"
                alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alertController.addAction(self.retryAction())
            }
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func yesAction(for suggestion: String) -> UIAlertAction {
        return UIAlertAction(title: "Yes", style: .default, handler: { (result) in
            print("SEARCHING")
            self.search(for: suggestion)
        })
    }
    
    private func noAction() -> UIAlertAction {
        return UIAlertAction(title: "No", style: .cancel, handler: { (result) in
            self.pickerData.remove(at: self.currentPickerIndex)
            self.pickerView.reloadAllComponents()
        })
    }
    
    private func retryAction() -> UIAlertAction {
        return UIAlertAction(title: "Retry", style: .default, handler: { (result) in
            self.pickerData.remove(at: self.currentPickerIndex)
            self.pickerView.reloadAllComponents()
        })
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


extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    // Capture the picker view selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentPickerIndex = row
        print("currentPickerIndex")
        print(currentPickerIndex)
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
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


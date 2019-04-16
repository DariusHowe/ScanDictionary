//
//  TakePhotoViewController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/26/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import UIKit
import TesseractOCR
import GPUImage
import CoreMotion

class TakePhotoViewController: UIViewController {
    @IBOutlet weak var progessView: ProgressView!
    @IBOutlet weak var steadyLabel: UILabel!
    @IBOutlet weak var helpText: UILabel!
    
    var pickerData: [String] = []
    
    var currentPickerIndex = 0
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet var cameraPreview: CameraPreview!
    
    let tesseract = G8Tesseract(language:"eng")!
    let motionDetector = CMMotionManager()
    var deviceIsSteady = false;

    let camera = Camera()
    var scope: ScopeView!
    
    var imageView: UIImageView!
    let webScrapper = WebScrapper.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (_) in
            print("VISI")
        }
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        tesseract.rect = self.cameraPreview.bounds
        tesseract.delegate = self
        tesseract.charWhitelist = "-_(){}[]=%.,?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890/"
    }
    
    var deviceSteadyCount = 0
    var deviceUnsteadyCount = 0
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        motionDetector.stopAccelerometerUpdates()
        super.viewWillDisappear(animated)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        print(#function)
            if camera.captureSession.isRunning == false {
                cameraPreview.setupPreview(for: camera.captureSession)
                camera.run()
            }
            
            
            
            scope = ScopeView(frame: CGRect(x: 0, y: 0, width: 250, height: 75))
            scope.center = cameraPreview.bounds.center
            
            imageView = UIImageView(frame: self.scope.bounds)
            
            self.imageView.contentMode = .scaleAspectFit
            self.scope.contentMode = .scaleAspectFit
            
            scope.addSubview(imageView)
            cameraPreview.addSubview(scope)
            
            motionDetector.accelerometerUpdateInterval = 0.5
            startAccelerometer()
    }
    
    func startAccelerometer() {
        motionDetector.startAccelerometerUpdates(to: OperationQueue.current!) { (data,error)in
            guard let motion = data else { print(error!); return }
            let acceleration = sqrt((motion.acceleration.x * motion.acceleration.x) + (motion.acceleration.y * motion.acceleration.y) + (motion.acceleration.z * motion.acceleration.z))
            
            if acceleration < 1.02 && acceleration > 0.98 {
                self.deviceIsSteady = true
                self.deviceSteadyCount += 1
                self.deviceUnsteadyCount = 0
                self.steadyLabel.text = "Steady"
                self.helpText.isHidden = true
                self.steadyLabel.textColor = UIColor.green
            } else {
                self.deviceIsSteady = false
                self.deviceSteadyCount = 0
                self.deviceUnsteadyCount += 1
                self.steadyLabel.text = "Not Steady"
                self.steadyLabel.textColor = UIColor.red
            }
            if self.deviceSteadyCount >= 6 {
                print("device is steady:", self.deviceIsSteady)
                self.deviceSteadyCount = 0
                self.takePhoto(false)
                self.motionDetector.stopAccelerometerUpdates()
            }
            if self.deviceUnsteadyCount >= 15 {
                self.helpText.isHidden = false
            }
        }
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        camera.capture { (ci_image) in
            print(#function)

            guard var image = self.crop(ci_image, within: self.scope, previewSize: self.cameraPreview.frame.size) else {
                return
            }
            let luminanceThresholdFilter = GPUImageLuminanceThresholdFilter()
            luminanceThresholdFilter.threshold = 0.4
            image = luminanceThresholdFilter.image(byFilteringImage: image)!
            
            DispatchQueue.main.async {
                print(self.tesseract.progress)
//                self.imageView.image = image
                self.processImage(image)
            }
        }
    }
    
    private func crop(_ image: CIImage, within view: ScopeView, previewSize: CGSize) -> UIImage? {
        let imageViewScale = max(image.extent.width / previewSize.width,
                                 image.extent.height / previewSize.height)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x: view.frame.origin.x * imageViewScale,
                              y: view.frame.origin.y * imageViewScale,
                              width: view.frame.size.width * imageViewScale,
                              height: view.frame.size.height * imageViewScale)
        
        let image = image.cropped(to: cropZone)
    
        guard let cgImage = CIContext().createCGImage(image, from:image.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
    
    
}

/* Tesseract Functions */
extension TakePhotoViewController: G8TesseractDelegate {
    func processImage(_ image: UIImage) {
//        let stillImageFilter = GPUImageAdaptiveThresholdFilter()
//        stillImageFilter.blurRadiusInPixels = 4.0
//        let Tesseractimage = stillImageFilter.image(byFilteringImage: image)!
//        let luminanceThresholdFilter = GPUImageLuminanceThresholdFilter()
//        luminanceThresholdFilter.threshold = 0.4
//        let image = luminanceThresholdFilter.image(byFilteringImage: image)!
        tesseract.image = image


        DispatchQueue.global(qos: .userInteractive).async {
            self.tesseract.recognize()
            var iteratorLevel = G8PageIteratorLevel.textline
            var blocks = self.tesseract.recognizedBlocks(by: iteratorLevel)
            
            iteratorLevel = G8PageIteratorLevel.word
            blocks = self.tesseract.recognizedBlocks(by: iteratorLevel)

            var closestWord: (String, CGFloat)?
            
            if let blocks = blocks as? [G8RecognizedBlock] {
                let center = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size).center
                for block in blocks {
                    let distance = center.distance(from: block.boundingBox(atImageOf: image.size).center)
                    if closestWord == nil {
                        closestWord = (block.text, distance)
                    } else if closestWord!.1 > distance {
                        closestWord = (block.text, distance)
                    }
                }
            }
            
            DispatchQueue.main.async {
//                self.imageView.image = image
                if let closestWord = closestWord?.0 {
                    let word = self.removeSpecialCharsFromString(text: closestWord)
                    guard !self.pickerData.contains(word) else { return }

                    self.pickerData.insert(word, at: 0)
                }
                
//                if !self.pickerData.contains(closestWord!.0) {
////                    add
//                }
                self.pickerView.reloadAllComponents()
                self.progessView.setProgress(progress: self.tesseract.progress)
            }
        
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5), execute: {
        
                guard self.tabBarController?.selectedViewController == self else {
                    return
                }
                
                self.progessView.setProgress(progress: 0)
                self.imageView.image = nil
                self.startAccelerometer()
            })
        }
    }
    
    func removeSpecialCharsFromString(text: String) -> String {
        let okayChars : Set<Character> =
            Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(text.filter {okayChars.contains($0) })
    }
    
    func progressImageRecognition(for tesseract: G8Tesseract) {
        DispatchQueue.main.async {
            self.progessView.setProgress(progress: tesseract.progress)
        }
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }
}

/* Functions specific to searching for words */
extension TakePhotoViewController {
    @IBAction func search(_ sender: Any) {
        guard !pickerData.isEmpty else { return }
        let word = pickerData[currentPickerIndex]
        search(for: word)
    }
    
    private func search(for word: String) {
        print(#function, "for", word)
        webScrapper.getDefinition(for: word) { (result) in
            guard let word = result as? Word else {
                self.searchHelper(result)
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            
            let tabBar = storyboard.instantiateViewController(withIdentifier: "tabbar") as! TabBarViewController
            
            tabBar.word = word
            DefinitionStorage.store(word)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(tabBar, animated: true)
//                self.navigationController?.present(tabBar, animated: true, completion: nil)
            }
        }
    }
    
    /* Handles misspelled words and no results */
    private func searchHelper(_ result: Any?) {
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
}
extension TakePhotoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
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
        // This method is triggered whenever the user makes a change to the picker selection.
    }
}


extension CGPoint {
    func distance(from point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
    }
}

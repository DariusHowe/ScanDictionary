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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /**************/
    @IBOutlet weak var textContainerView: UIView!
    let defaultText = "Tap on the word you want to scan"
    @IBOutlet weak var helpText: UILabel!
    /**************/

    var pickerData: [String] = []
    var currentPickerIndex = 0
    @IBOutlet weak var pickerView: UIPickerView!
    
    let camera = Camera()
    @IBOutlet var cameraPreview: CameraPreview!
    
    let tesseract = G8Tesseract(language:"eng")!

    /**************/
    var scope: UIView!
    let defaultWidth: CGFloat = 250
    let defaultHeight: CGFloat = 75
    /**************/

    let webScrapper = WebScrapper.shared

    var state: ControllerState = .Idle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textContainerView.layer.cornerRadius = 10.0
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        /* Tesseract */
        tesseract.rect = self.cameraPreview.bounds
        tesseract.delegate = self
        let allowedCharacters = """
        ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890
        `~!@#$%^&*()-_=+{}[]'";:/?.>,<|\\
        """
        tesseract.charWhitelist = allowedCharacters
        scope = UIView(frame: CGRect(x: 0, y: 0, width: defaultWidth, height: defaultHeight))
        self.scope.contentMode = .scaleAspectFit

        scope.center = cameraPreview.bounds.center
        tesseract.maximumRecognitionTime = 3
    }

    func shouldCancelImageRecognition(for tesseract: G8Tesseract) -> Bool {
        print(#function)
        print(tesseract.progress)
        return false
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print(#function)
        if camera.captureSession.isRunning == false {
            cameraPreview.setupPreview(for: camera.captureSession)
            camera.run()
            cameraPreview.addSubview(scope)
        }
    
        self.activityIndicator.stopAnimating()
            
    }
    
//    @IBAction func onLongPress(_ sender: UILongPressGestureRecognizer) {
//        print(#function, sender.state.rawValue)
//        let location = sender.location(in: self.cameraPreview)
//
//        let maxSize = CGSize(width: defaultWidth, height: defaultHeight)
//        if sender.state == UIGestureRecognizer.State.began {
//            let transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
//
//            DispatchQueue.main.async {
//                self.scope.frame.size = maxSize.applying(transform)
//                self.scope.center = location
//            }
//
//        }
//        if sender.state == UIGestureRecognizer.State.ended {
//            DispatchQueue.main.async {
//                self.scope.frame.size = maxSize
//                self.scope.center = location
//
//            }
//        } else {
//            if timer?.isValid ?? false {
//                return
//            } else {
//                expandScope(location)
//            }
//        }
//    }
    
    @IBAction func onLongPress(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: self.cameraPreview)
        
        let maxSize = CGSize(width: defaultWidth, height: defaultHeight)
        
        switch sender.state {
        case .began:
            let transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            
            DispatchQueue.main.async {
                self.scope.frame.size = maxSize.applying(transform)
                self.scope.center = location
            }
            if timer?.isValid ?? false {
                return
            } else {
                expandScope()
            }
            break;
        case .changed:
            DispatchQueue.main.async {
                self.scope.center = location
            }
        case .ended:
            timer?.invalidate()
            timer = nil
            DispatchQueue.main.async {
                self.scope.center = location
                var origin = self.scope.frame.origin
                let x = self.scope.frame.origin.x
                let y = self.scope.frame.origin.y
                var currentSize = self.scope.frame.size

                if x < 0 {
                    origin.x -= x
                    currentSize.width += x
                    self.scope.frame = CGRect(origin: origin, size: currentSize)
                }
                if y < 0 {
                    origin.y -= y
                    currentSize.height += y
                    self.scope.frame = CGRect(origin: origin, size: currentSize)
                }
            }
            onTap(sender)
            break;
        default:
            break;
        }
    }
    
    
    var timer: Timer?
    func expandScope() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            DispatchQueue.main.async {
                let currentSize = self.scope.frame.size
                if currentSize.width > self.defaultWidth {
                    timer.invalidate()
                }
                let center = self.scope.center
                let transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
                self.scope.frame.size = currentSize.applying(transform)
                self.scope.center = center
                print("size:", self.scope.frame.size)
                
                
                self.scope.backgroundColor = UIColor(white: 0, alpha: 0.7)
                
            }
        })
    }
    
   
    var recognitionInProgress = false
    @IBAction func onTap(_ sender: UIGestureRecognizer) {
        print("Screen tapped")
        guard state == .Idle else { return }
        state = .CapturingImage
        
        var alpha: CGFloat = 0.7
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            if alpha <= 0 {
                timer.invalidate()
            } else {
                DispatchQueue.main.async {
                    self.scope.backgroundColor = UIColor(white: 0, alpha: alpha)
                }
                alpha -= 0.01
            }
            
        })
        
        helpText.text = "Loading"
        if sender == sender as? UITapGestureRecognizer {
            scope.frame.size = CGSize(width: defaultWidth, height: defaultHeight)

        }
        let location = sender.location(in: self.cameraPreview)
        var size = scope.frame.size
        
        DispatchQueue.main.async {
            self.scope.center = location
            var origin = self.scope.frame.origin
            let x = self.scope.frame.origin.x
            if x < 0 {
                origin.x -= x
                size.width += x
                self.scope.frame = CGRect(origin: origin, size: size)
            }
        }

        camera.capture { (ci_image) in
            print("Image captured")
            
            /* Crop image */
            guard var image = self.crop(ci_image, within: self.scope, previewSize: self.cameraPreview.frame.size) else {
                return
            }

            /* Apply filter */
            let luminanceThresholdFilter = GPUImageLuminanceThresholdFilter()
            luminanceThresholdFilter.threshold = 0.4
            image = luminanceThresholdFilter.image(byFilteringImage: image)!
            
            DispatchQueue.main.async {
                self.state = .ProcessingImage

                self.processImage(image)
            }
        }
    }
    
    private func crop(_ image: CIImage, within view: UIView, previewSize: CGSize) -> UIImage? {
        let imageViewScale = max(image.extent.width / previewSize.width,
                                 image.extent.height / previewSize.height)
        

        let x = view.frame.origin.x * imageViewScale
        let y = (previewSize.height * imageViewScale) - (view.frame.origin.y * imageViewScale) - (view.frame.size.height * imageViewScale)
        let width = view.frame.size.width * imageViewScale
        let height = view.frame.size.height * imageViewScale
        

        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x: x,
                              y: y,
                              width: width,
                              height: height)

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
        guard self.recognitionInProgress == false else { return }
        self.recognitionInProgress = true
        
        tesseract.image = image

        print("Tesseract is processing")

        /* 'self.tesseract.recognize()' will block the thread so we must
            use a background thread                                     */
        DispatchQueue.global(qos: .userInteractive).async {
            self.tesseract.recognize()
            print("Tesseract processing is complete")
            self.recognitionInProgress = false

            var iteratorLevel = G8PageIteratorLevel.textline
            var blocks = self.tesseract.recognizedBlocks(by: iteratorLevel)
            
            iteratorLevel = G8PageIteratorLevel.word
            blocks = self.tesseract.recognizedBlocks(by: iteratorLevel)

            var closestWord: (String, CGFloat)?
            if let blocks = blocks as? [G8RecognizedBlock] {
                print("Tesseract found the following words")
                let center = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size).center
                for block in blocks {
                    print("""
                        \t"\(block.text ?? "NA")" with confidence: \(block.confidence)
                        """)
                    let distance = center.distance(from: block.boundingBox(atImageOf: image.size).center)
                    if closestWord == nil {
                        closestWord = (block.text, distance)
                    } else if closestWord!.1 > distance {
                        closestWord = (block.text, distance)
                    }
                }
            }
            
            /* Update UI on main thread */
            DispatchQueue.main.async {
                self.helpText.text = self.defaultText
                self.progessView.setProgress(progress: 0)
                self.state = .Idle

                if let closestWord = closestWord?.0 {
                    print("word in center:", "\"" + closestWord + "\"")
                    let word = self.removeSpecialCharsFromString(text: closestWord)
                    guard word != "" && word != " " else {
                        print("Word is space")
                        return }
                    guard !self.pickerData.contains(word) else {
                        print("Word already found")
                        return }
                    
                    self.pickerData.insert(word, at: 0)
                    self.pickerView.reloadAllComponents()
                }

            }
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
        
        toggleActivityIndicator()
        let word = pickerData[currentPickerIndex]
        search(for: word)
    }
    
    func toggleActivityIndicator() {
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating {
                self.activityIndicator.stopAnimating()
            } else {
                self.activityIndicator.startAnimating()
            }
        }
    }
    private func search(for word: String) {
        print(#function, "for", word)

        webScrapper.getDefinition(for: word) { (result) in
            guard let word = result as? Word else {
                self.searchHelper(result)
                self.toggleActivityIndicator()
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            
            let tabBar = storyboard.instantiateViewController(withIdentifier: "tabbar") as! TabBarViewController
            
            tabBar.word = word
            DefinitionStorage.store(word)
            DispatchQueue.main.async {
                self.toggleActivityIndicator()
                self.navigationController?.pushViewController(tabBar, animated: true)
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

enum ControllerState {
    case Idle
    case CapturingImage
    case ProcessingImage
}

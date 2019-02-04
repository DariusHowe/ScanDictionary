//
//  ViewController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 2/4/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import UIKit
import TesseractOCR

class ViewController: UIViewController, G8TesseractDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let tesseract: G8Tesseract = G8Tesseract(language:"eng+ita") else { return }
        tesseract.delegate = self
        tesseract.charWhitelist = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz01234567890"
        tesseract.image = UIImage(named: "vrkIj.png")!
        tesseract.recognize()
        
        print(tesseract.recognizedText ?? "")
        // Do any additional setup after loading the view, typically from a nib.
    }

    func progressImageRecognition(for tesseract: G8Tesseract) {
        print("Recognition Process \(tesseract.progress) %")
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }

}


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

        let ws = WebScrapper.shared
//        ws.analyze("testPhrase") { (score) in
//            print(score)
//        }
//        
        
//        let url = URL(string: "http://www.dictionary.com/browse/gender")!
//
//        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
//            guard let data = data else { return }
//            let finalData = String(data: data, encoding: .utf8)!
//            ws.analyze(finalData) { (score) in
//                print(score)
//            }
//        }

//        task.resume()  
        
        
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

    func progressImageRecognition(for tesseract: G8Tesseract) {
        print("Recognition Process \(tesseract.progress) %")
    }
    
    func shouldCancelImageRecognitionForTesseract(tesseract: G8Tesseract!) -> Bool {
        return false // return true if you need to interrupt tesseract before it finishes
    }

}


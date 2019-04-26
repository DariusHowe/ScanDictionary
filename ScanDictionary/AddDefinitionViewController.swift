//
//  AddDefinitionViewController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 4/26/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import UIKit
import WebKit

class AddDefintionViewController: UIViewController {
    @IBOutlet weak var segmentedContol: UISegmentedControl!
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        if sender.selectedSegmentIndex == 0 {
            let myURL = URL(string: addViewUrl)
            let myRequest = URLRequest(url: myURL!)
            
            wkWebView.load(myRequest)
        } else {
            let myURL = URL(string: editViewUrl)
            let myRequest = URLRequest(url: myURL!)
            wkWebView.load(myRequest)
        }
    }
//    var webView: WKWebView!
    let addViewUrl = "https://nam04.safelinks.protection.outlook.com/?url=http%3A%2F%2Fwww.vocab.mychatbot.xyz%2Fhtml%2Ftest.html&data=02%7C01%7Cs1047084%40monmouth.edu%7C76a8c3cf7066423875c808d6c9f30572%7Cd398fb561bf04c4a92214d138fa72653%7C0%7C0%7C636918442937586913&sdata=j1SYet1nPZxyxzG3NLql83FhnShCoogLWe7sq1TI34U%3D&reserved=0"
    
    var editViewUrl = "http://www.vocab.mychatbot.xyz/html/getall.php"

    @IBOutlet weak var wkWebView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let myURL = URL(string: addViewUrl)
        let myRequest = URLRequest(url: myURL!)
        wkWebView.load(myRequest)
    }
}

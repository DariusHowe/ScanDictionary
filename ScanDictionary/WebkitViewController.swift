//
//  WebkitViewController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 4/3/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import UIKit
import WebKit
class WebkitViewController: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var word: String!
    var url: String?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        url = "http://www.vocab.mychatbot.xyz/html/getall.php"
        if url != nil {
            let myURL = URL(string: url!)
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        } else {
            guard word != nil else { return }
            let search = "search?q=define+" + word
            let myURL = URL(string:"https://www.google.com/" + search)
            let myRequest = URLRequest(url: myURL!)
            webView.load(myRequest)
        }
        
    }
}

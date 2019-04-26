//
//  TabBarController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 4/3/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class TabBarViewController: UITabBarController {
    
    var word: Word!
    let synth = AVSpeechSynthesizer()
    
    func speak(word: String) {
        let utterance = AVSpeechUtterance(string: word)
        synth.speak(utterance)
    }
    
    override func viewDidLoad() {
        guard word != nil else { return }
        
        let firstViewController = storyboard!.instantiateViewController(withIdentifier: "DefinitionViewController") as! DefinitionViewController
 
        
        firstViewController.word = word

        firstViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)

        let secondViewController = WebkitViewController()
        secondViewController.word = word.name
        
        secondViewController.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 1)

        let tabBarList = [firstViewController, secondViewController]

        viewControllers = tabBarList
        navigationController?.title = word.name
        title = word.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillDisappear(animated)
    }
    @IBAction func textToSpeech(_ sender: Any) {
        speak(word: word.name)
    }
    
    deinit {
        print(#function, String(describing: self))
    }
}

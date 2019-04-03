//
//  TabBarController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 4/3/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import UIKit

class TabBarViewController: UITabBarController {
    
    var word: Word!
    
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
    }
}

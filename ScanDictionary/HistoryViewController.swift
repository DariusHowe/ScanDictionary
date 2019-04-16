//
//  HistoryViewController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/27/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import Foundation
import UIKit

class HistoryViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    var isSearch = false
    
    var items: [String] = []
    var filteredItems: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTableView.dataSource = self
        self.searchTableView.delegate = self
        self.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let wordNames = DefinitionStorage.getAllWords()
        for name in wordNames {
            items.append(name)
        }
    }

}


extension HistoryViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearch = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        isSearch = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if Substring(searchText).count == 0 {
            isSearch = false;
            self.searchTableView.reloadData()
        } else {
            let pattern = "\\b" + NSRegularExpression.escapedPattern(for: searchText)
            filteredItems = items.filter {
                $0.range(of: pattern, options: [.regularExpression, .caseInsensitive]) != nil
            }
            print(filteredItems)
            if(filteredItems.count == 0 && searchText == ""){
                isSearch = false;
            } else {
                isSearch = true;
            }
            self.searchTableView.reloadData()
        }
    }
}


extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isSearch) {
            return filteredItems.count
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        configureCell(cell: cell, forRowAtIndexPath: indexPath)
        return cell

    }
    
    func configureCell(cell: UITableViewCell, forRowAtIndexPath: IndexPath) {
        if(isSearch){
            cell.textLabel?.text = filteredItems[forRowAtIndexPath.row]
        } else {
            cell.textLabel?.text = items[forRowAtIndexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let word = items[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let definitionController = storyboard.instantiateViewController(withIdentifier: "DefinitionViewController") as! DefinitionViewController
//
//        definitionController.word = DefinitionStorage.retrieve(word)
        
        
        let tabBar = storyboard.instantiateViewController(withIdentifier: "tabbar") as! TabBarViewController
        
        tabBar.word = DefinitionStorage.retrieve(word)
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(tabBar, animated: true)
            //                self.navigationController?.present(tabBar, animated: true, completion: nil)
        }
        
//
//        DispatchQueue.main.async {
//            self.present(definitionController, animated: true, completion: nil)
//        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DefinitionStorage.remove(items[indexPath.row])
            self.items.remove(at: indexPath.row)
            self.searchTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

//class Table

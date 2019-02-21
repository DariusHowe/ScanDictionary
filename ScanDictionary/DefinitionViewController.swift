//
//  DefinitionViewController.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 2/20/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//
import UIKit

class DefinitionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    
    // This is the size of our header sections that we will use later on.
    let SectionHeaderHeight: CGFloat = 25
    
    var webData: Word?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let word = "work"
        let url = URL(string: "http://www.dictionary.com/browse/" + word)!
        
        let webScrapper = WebScrapper.shared
        self.title = word
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            let finalData = String(data: data, encoding: .utf8)!
            webScrapper.analyze(finalData) { (score) in
                self.webData = score
                self.tableView.reloadData()

            }
        }
        
        task.resume()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    

}

extension DefinitionViewController: UITableViewDataSource, UITableViewDelegate {
    
    // As long as `total` is the last case in our TableSection enum,
    // this method will always be dynamically correct no mater how many table sections we add or remove.
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let webData = webData else { return 0 }
        let dl = webData.definitionLists

        return dl.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Using Swift's optional lookup we first check if there is a valid section of table.
        // Then we check that for the section there is data that goes with.
        if let definitions = webData?.definitionLists[section].definitions {
            return definitions.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // If we wanted to always show a section header regardless of whether or not there were rows in it,
        // then uncomment this line below:
        return SectionHeaderHeight
        // First check if there is a valid section of table.
        // Then we check that for the section there is more than 1 row.
//        if let tableSection = TableSection(rawValue: section), let movieData = data[tableSection], movieData.count > 0 {
//            return SectionHeaderHeight
//        }
//        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
        view.backgroundColor = UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1)
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black

        guard let webData = webData else { return nil }
        let category = webData.definitionLists[section].category

        label.text = category
        
        view.addSubview(label)
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Similar to above, first check if there is a valid section of table.
        // Then we check that for the section there is a row.
        
        print("Setting section \(indexPath.section), row \(indexPath.row)")
        if let definition = webData?.definitionLists[indexPath.section].definitions[indexPath.row] {
            
            
            
            if let titleLabel = cell.viewWithTag(10) as? UILabel {
                let italicFont = [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 15)]
                
                let itemNumber = NSMutableAttributedString(string: "\(indexPath.row + 1).  ")
                if let label = definition.label {
                    let labelString = NSAttributedString(string: label + " - ", attributes: italicFont)
                    itemNumber.append(labelString)
                }
                
                let description = NSAttributedString(string: definition.description)
                itemNumber.append(description)

                titleLabel.attributedText = itemNumber
            }
            if let subtitleLabel = cell.viewWithTag(20) as? UILabel {
                subtitleLabel.text = definition.example
            }
        }
        return cell
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let height: CGFloat = 100
//        return height
//    }
}

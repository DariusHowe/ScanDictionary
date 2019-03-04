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
        let word = "track"
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
        return SectionHeaderHeight

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! DefinitionViewCell
        
        
        print("Setting section \(indexPath.section), row \(indexPath.row)")
        if let definition = webData?.definitionLists[indexPath.section].definitions[indexPath.row] {
            
            let description = NSAttributedString(string: definition.description)
            
            if let label = definition.label {
                let italicFont = [NSAttributedString.Key.font : UIFont.italicSystemFont(ofSize: 17)]
                let labelString = NSMutableAttributedString(string: label + " - ", attributes: italicFont)
                labelString.append(description)
                cell.descriptionLabel.attributedText = labelString
            } else {
                cell.descriptionLabel.attributedText = description
            }

            

            cell.item.text = String(indexPath.row + 1) + "."
            cell.example.text = definition.example


        }
        return cell
    }
}


class DefinitionViewCell: UITableViewCell {
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var example: UILabel!
    @IBOutlet weak var item: UILabel!
}


//
//  WebScrapper.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 2/11/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//

import UIKit
import JavaScriptCore

class WebScrapper: NSObject {
    /// Singleton instance. Much more resource-friendly than creating multiple new instances.
    static let shared = WebScrapper()
    private let vm = JSVirtualMachine()
    private let context: JSContext
    
    private override init() {
        let jsCode = try? String.init(contentsOf: Bundle.main.url(forResource: "ScanDictionary.bundle", withExtension: "js")!)
        
        // The Swift closure needs @convention(block) because JSContext's setObject:forKeyedSubscript: method
        // expects an Objective-C compatible block in this instance.
        // For more information check out https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Attributes.html#//apple_ref/doc/uid/TP40014097-CH35-ID350
        let nativeLog: @convention(block) (String) -> Void = { message in
            NSLog("JS Log: \(message)")
        }
        
        // Create a new JavaScript context that will contain the state of our evaluated JS code.
        self.context = JSContext(virtualMachine: self.vm)
        
        // Register our native logging function in the JS context
        self.context.setObject(nativeLog, forKeyedSubscript: "nativeLog" as NSString)
        
        // Evaluate the JS code that defines the functions to be used later on.
        self.context.evaluateScript(jsCode)

    }
    /**
     Analyze the sentiment of a given English sentence.
     
     - Parameters:
     - sentence: The sentence to analyze
     - completion: The block to be called on the main thread upon completion
     - score: The sentiment score
     */
    
    func analyze(_ html: String, for word: String, completion: @escaping (_ res: Word) -> Void) {
        // Run this asynchronously in the background
        DispatchQueue.global(qos: .userInitiated).async {
            var res: Word!
            
            let jsModule = self.context.objectForKeyedSubscript("ScanDictionary")
            let jsAnalyzer = jsModule?.objectForKeyedSubscript("Analyzer")
            
            // In the JSContext global values can be accessed through `objectForKeyedSubscript`.
            // In Objective-C you can actually write `context[@"analyze"]` but unfortunately that's
            // not possible in Swift yet.
            if let result = jsAnalyzer?.objectForKeyedSubscript("analyze").call(withArguments: [html, word]) {
                do {
                    let serialData = try JSONSerialization.data(withJSONObject: result.toObject() as Any, options: .prettyPrinted)
                    let decoder = JSONDecoder()
                    let word = try! decoder.decode(Word.self, from: serialData)
                    
                    res = word
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            
            // Call the completion block on the main thread
            DispatchQueue.main.async {
                completion(res)
            }
        }
    }
    
    func getDatabaseDefintions(for word: String, completion: @escaping (_ res: [String]) -> Void) {
        // Run this asynchronously in the background
        DispatchQueue.global(qos: .userInitiated).async {
            var res: [String] = []
            
            let jsModule = self.context.objectForKeyedSubscript("ScanDictionary")
            let jsAnalyzer = jsModule?.objectForKeyedSubscript("Analyzer")
            
            let url = URL(string: "http://www.vocab.mychatbot.xyz/html/getresult.php?word=" + word)!

            print(url)

            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data else {
                    return }
                let html = String(data: data, encoding: .utf8)!
                print("Getting result")
                if let result = jsAnalyzer?.objectForKeyedSubscript("getDatabaseDefintions").call(withArguments: [html, word]) {
                    let data = result.toArray() as! [String]
                    res = data
                    // Call the completion block on the main thread
                    DispatchQueue.main.async {
                        completion(res)
                    }
                }
            }.resume()
            
            

        }
    }
    
    
    func getSuggestion(_ html: String, completion: @escaping (_ res: String) -> Void) {
        // Run this asynchronously in the background
        DispatchQueue.global(qos: .userInitiated).async {
            
            let jsModule = self.context.objectForKeyedSubscript("ScanDictionary")
            let jsAnalyzer = jsModule?.objectForKeyedSubscript("Analyzer")
            print(#function)
            if let suggestion = jsAnalyzer?.objectForKeyedSubscript("getSuggestion").call(withArguments: [html])?.toString() {
                DispatchQueue.main.async {
                    completion(suggestion)
                }
            }
        }
    }
    
    func getDefinition(for word: String, result: @escaping (Any?) -> ()) {
        print(#function)
        let word = word
        let url = URL(string: "http://www.dictionary.com/browse/" + word)!
        
        let webScrapper = WebScrapper.shared
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            print("retreived html")
            guard let data = data else { return }
            let finalData = String(data: data, encoding: .utf8)!
            guard let path = response?.url?.lastPathComponent else { return }
            if path == "misspelling" {
                webScrapper.getSuggestion(finalData) { (suggestion) in
                    guard suggestion != "" else {
                        result(nil)
                        return
                    }
                    result(suggestion)
                }
            } else if path == "noresult" {
                result(nil)
            } else {
                // Searching for the word "eastsites" gives a url with a path of "east-side" - Using "else if path == word" will miss certain words
                webScrapper.analyze(finalData, for: path) { (word) in
                    result(word)
                }
            }
        }.resume()
    }
    
}

class Word: Codable {
    let name: String
    let definitionLists: [DefinitionList]

}

struct DefinitionList: Codable {
    let category: String
    let definitions: [Definition]
}

struct Definition: Codable {
    let description: String
    let example: String?
    let label: String?
}

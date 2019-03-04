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
    
    
    
    
    
    
    func analyze(_ sentence: String, completion: @escaping (_ res: Word) -> Void) {
        // Run this asynchronously in the background
        DispatchQueue.global(qos: .userInitiated).async {
//            var score: NSDictionary = [:]
            var res: Word!
            
            let jsModule = self.context.objectForKeyedSubscript("ScanDictionary")
            let jsAnalyzer = jsModule?.objectForKeyedSubscript("Analyzer")
            
            // In the JSContext global values can be accessed through `objectForKeyedSubscript`.
            // In Objective-C you can actually write `context[@"analyze"]` but unfortunately that's
            // not possible in Swift yet.
            if let result = jsAnalyzer?.objectForKeyedSubscript("analyze").call(withArguments: [sentence]) {
//                score = result.toDictionary()! as NSDictionary
               
                let serialData = try! JSONSerialization.data(withJSONObject: result.toObject(), options: .prettyPrinted)
                let decoder = JSONDecoder()
                let word = try! decoder.decode(Word.self, from: serialData)
                res = word
            }
            
            // Call the completion block on the main thread
            DispatchQueue.main.async {
                completion(res)
            }
        }
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


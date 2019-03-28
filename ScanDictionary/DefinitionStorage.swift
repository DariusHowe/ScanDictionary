//
//  Storage.swift
//  ScanDictionary
//
//  Created by Matthew Shober on 3/28/19.
//  Copyright © 2019 Matthew Shober. All rights reserved.
//
// https://medium.com/@piyush.dez/codable-swift-4-1-4a0408c68be9

import Foundation

public class DefinitionStorage {
    
    fileprivate init() { }
    
    static fileprivate let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    
    static func store(_ word: Word) {
        let key = word.name
        let url = directory.appendingPathComponent(key, isDirectory: false)

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(word)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func retrieve(_ word: String) -> Word? {
        let key = word
        let url = directory.appendingPathComponent(key, isDirectory: false)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File at path \(url.path) does not exist!")
        }
        
        if let data = FileManager.default.contents(atPath: url.path) {
            let decoder = JSONDecoder()
            
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let word = try! decoder.decode(Word.self, from: data)
            return word
            
        } else {
            fatalError("No data found  at\(url.path)!")
        }
    }
    
    static func clearDefinitions() {
        let url = directory
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for fileUrl in contents {
                try FileManager.default.removeItem(at: fileUrl)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func getAllWords() -> [String] {
        let url = directory
        do {
            var names: [String] = []
            
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for url in contents {
                let name = url.lastPathComponent
                names.append(name)
            }
            return names
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    static func remove(_ word: String) {
        let url = directory.appendingPathComponent(word, isDirectory: false)
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    static func wordExists(with name: String) -> Bool {
        let url = directory.appendingPathComponent(name, isDirectory: false)
        return FileManager.default.fileExists(atPath: url.path)
    }
}


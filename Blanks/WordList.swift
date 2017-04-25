//
//  WordList.swift
//  Blanks
//
//  Created by Peter Thomas on 4/6/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

enum WordListError:Error {
    case bundlePathError
    case wordListNotFound
    case insufficientCharacters
    case tooManyAttempts
}

class WordList: NSObject {
    
    static func load(wordCount:Int, withLowercaseCharacters requiredCharacters:[Character], minLength:Int, maxLength:Int, minCharacters:Int) throws -> Set<String> {
        
        guard let wordListPath = Bundle.main.path(forResource: "all", ofType: "list") else {
            logger.error("Unable to load word list from bundle")
            throw WordListError.bundlePathError
        }

        guard minCharacters <= requiredCharacters.count else {
            logger.error("Too many min characters for string")
            throw WordListError.insufficientCharacters
        }
        
        guard let fileHandle = FileHandle(forReadingAtPath: wordListPath) else {
            logger.error("Cound not find word.list")
            throw WordListError.wordListNotFound
        }

        guard requiredCharacters.count > 0 else {
            logger.error("No characters in string")
            throw WordListError.insufficientCharacters
        }
        
        var requiredCharactersFound = Set<Character>()
        
        var wordsSinceAddition:Int = 0
        let numAttemptsBeforeAbort = 1000
        
        let fileLength = fileHandle.seekToEndOfFile()
        
        var validWords = Set<String>()
        while validWords.count < wordCount {
            
            let offset = UInt64(drand48() * Double(fileLength))
            fileHandle.seek(toFileOffset: offset)
            
            let readData = fileHandle.readData(ofLength: 1024)
            if let readText = String(data:readData, encoding:.utf8) {
                var words:[String] = readText.components(separatedBy: .newlines)
                guard words.count > 2 else { continue }
                
                // first/last are a partial word
                words.removeFirst()
                words.removeLast()
                
                for untrimmedWord in words {
                    
                    let word = untrimmedWord.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard minLength <= word.characters.count && word.characters.count <= maxLength else { continue }
                    
                    var wordRequiredCharacters = Set<Character>()
                    for character in requiredCharacters {
                        
                        if let _ = word.range(of: String(character)) {
                            wordRequiredCharacters.insert(character)
                        }
                    }
                    
                    // we only allow one word per chunk so we don't end up with similar
                    // runs of words from call to call
                    if wordRequiredCharacters.count >= minCharacters {
                        
                        // if this is the last word we have to make sure that we hit all the letters
                        // before adding it
                        if validWords.count < wordCount - 1 || requiredCharactersFound.union(wordRequiredCharacters).count == requiredCharacters.count {
                            requiredCharactersFound = requiredCharactersFound.union(wordRequiredCharacters)
                            validWords.insert(word)
                            break
                        }
                    } else {
                        wordsSinceAddition += 1
                        if wordsSinceAddition >= numAttemptsBeforeAbort {
                            throw WordListError.tooManyAttempts
                        }
                    }
                }
            }
        }
        return validWords
    }
}

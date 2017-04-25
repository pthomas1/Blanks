//
//  Level.swift
//  Blanks
//
//  Created by Peter Thomas on 4/14/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

extension Set {
    
    func randomUniqueSampleSet<T>(count:Int) -> Set<T> {
        
        let all = Array(self)
        var samples = Set<T>()
        
        while samples.count < count {
            let sample = all[Int(drand48() * Double(all.count))] as! T
            samples.insert(sample)
        }

        return samples
    }
}

// The user is presented with a single word and a timer. The word is missing letters and the user has to
// select letters to add them back in. The player is presented with a new word and time is added to the clock
// whenever they complete a word. The new word is searched for using the missing letters from the previous
// word and must be unique within the level. Words become increasingly difficult over time.
//
// If your timer runs out on a word you drop down a word and get the time for that word added back on.
// The word you drop to is replaced by a new word with a similar difficulty level (but obviously different
// letters).
//
// The player loses when the timer reaches 0 and there is only one word on the screen.
//
// The player can ask for help during the level. When he does he can do one of a few things - select
// an unknown letter, populate a wildcard letter, remove letter(s) from the keyboard, add more time/pause time.
// At various points in a level the player can earn these back.
//
// The player can skip a word but pays a large time penalty - larger than a "normal" amount of time
// to figure it out. Maybe 2x the awarded time for that word for example.
//
// Game tracks the high water mark to offer bounses for exceeding it, runs, etc
//

class Level: NSObject {

    var words:[String]

    let wordCount = 3
    let numCharacters = 3
    let missingCharacters:[Character]
    let minWordLength = 0
    // current UI means max of 13
    let maxWordLength = 12
    let minCharacters = 3
    let wildcardCount = 0

    init(randomSeed:Int, wildcardCharacter:Character) {
        
        srand48(randomSeed)
        
        //abcdefghijklmnopqrstuvwxyz
        let allCharacters = Set("abcdefghijklmnopqrstuvwxyz".characters)
        
        var generatedWords:[String]! = nil
        var selectedCharacters:[Character]! = nil

        while generatedWords == nil {
            
            selectedCharacters = Array(allCharacters.randomUniqueSampleSet(count: numCharacters))
            
            do {
                logger.debug("Trying with characters: \(selectedCharacters)")
                generatedWords = Array(try WordList.load(wordCount:wordCount, withLowercaseCharacters:selectedCharacters, minLength:minWordLength, maxLength:maxWordLength, minCharacters:minCharacters)).randomizedOrder()
                
//                var allWords = [String]()
//                for index in 0..<selectedCharacters.count - 1 {
//                    let pair = [selectedCharacters[index]] + [selectedCharacters[index + 1]]
//                    let words = try WordList.load(wordCount: 1, withLowercaseCharacters: pair, minLength: 0, maxLength: 8, minCharacters: 2)
//                    logger.debug("\(pair): \(words)")
//                    allWords.append(words.first!)
//                }
//                let words = try WordList.load(wordCount:1, withLowercaseCharacters:selectedCharacters, minLength:0, maxLength:8, minCharacters:selectedCharacters.count)
//                allWords.append(words.first!)
//                generatedWords = allWords
//                
            } catch WordListError.tooManyAttempts {
                continue
            } catch {
                logger.error("Unrecoverable error occurred \(error)")
                fatalError("Could not generate words \(error)")
            }
        }
        
        self.words = generatedWords.map { $0.uppercased() }
        self.missingCharacters = selectedCharacters.map { String($0).uppercased().characters.first! }
        
        super.init()
        
        logger.debug("Words: \(self.words)")
        
        for _ in 0..<wildcardCount {
            let index = Int(drand48() * Double(words.count))
            let wildcardWord = wordWithWildcard(words[index], wildcardCharacter:wildcardCharacter)
            words[index] = wildcardWord
        }
    }
    
    func swappedLetter(forIndex index:Int) -> Character {
        return missingCharacters[index]
    }
    
    private func wordWithWildcard(_ word:String, wildcardCharacter:Character) -> String {
        
        let except = missingCharacters + [wildcardCharacter]
        var validPositions = [Int]()
        for (position, character) in word.characters.enumerated() {
            if except.contains(character) == false {
                validPositions.append(position)
            }
        }
        
        guard validPositions.count > 0 else { return word }
        
        var wildcardWord = word
        let randomPositionIndex = Int(drand48() * Double(validPositions.count))
        let randomPosition = validPositions[randomPositionIndex]
        
        let range = word.index(word.startIndex, offsetBy: randomPosition)
        wildcardWord.replaceSubrange(range...range, with: String(wildcardCharacter))
        
        return wildcardWord
    }
}

extension Array {
    func randomizedOrder() -> Array {
        // todo or words will always end with the one that finished the character inclusion requirement
        return self
    }
}

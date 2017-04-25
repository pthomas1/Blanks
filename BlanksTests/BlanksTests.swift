//
//  BlanksTests.swift
//  BlanksTests
//
//  Created by Peter Thomas on 4/6/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import XCTest
@testable import Blanks

class BlanksTests: XCTestCase {

//    let characters = "qae"
//    let wordCount = 5
//    let minLength = 1
//    let maxLength = 25
//    let randomSeed = Int(Date.timeIntervalSinceReferenceDate)
//    
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    func testGetWordsCount() {
//        logger.debug("Using random seed: \(self.randomSeed)")
//        let minCharacters = characters.characters.count
//        
//        do {
//            let words = try WordList.load(words:wordCount, withCharactersInString:characters, minLength:minLength, maxLength:maxLength, minCharacters:minCharacters, randomSeed:randomSeed)
//            XCTAssertEqual(words.count, wordCount)
//        } catch {
//            XCTFail("Exception loading word list \(error)")
//        }
//    }
//    
//    func testGetWordsWordLength() {
//        logger.debug("Using random seed: \(self.randomSeed)")
//        let minCharacters = characters.characters.count
//        
//        do {
//            let words = try WordList.load(words:wordCount, withCharactersInString:characters, minLength:minLength, maxLength:maxLength, minCharacters:minCharacters, randomSeed:randomSeed)
//
//            let characterSet = CharacterSet(charactersIn:characters)
//            for word in words {
//                let replaced = word.components(separatedBy: characterSet).joined(separator: "*")
//                logger.debug("word: \(word): \(replaced)")
//                XCTAssert(minLength <= word.characters.count && word.characters.count <= maxLength, "Invalid word length")
//            }
//        } catch {
//            XCTFail("Exception loading word list \(error)")
//        }
//    }
//
//    func testGetWordsCharacterCountFound() {
//        logger.debug("Using random seed: \(self.randomSeed)")
//        let minCharacters = characters.characters.count
//        
//        do {
//            let words = try WordList.load(words:wordCount, withCharactersInString:characters, minLength:minLength, maxLength:maxLength, minCharacters:minCharacters, randomSeed:randomSeed)
//            
//            let characterSet = CharacterSet(charactersIn:characters)
//            for word in words {
//                let replaced = word.components(separatedBy: characterSet).joined(separator: "*")
//                logger.debug("word: \(word): \(replaced)")
//                var characterCountFound = 0
//                for character in characters.characters {
//                    if word.contains(String(character)) {
//                        characterCountFound += 1
//                    }
//                }
//                XCTAssert(characterCountFound >= minCharacters, "Insufficient required characters found")
//            }
//        } catch {
//            XCTFail("Exception loading word list \(error)")
//        }
//    }

}

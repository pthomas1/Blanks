//
//  DecoratedWord.swift
//  Blanks
//
//  Created by Peter Thomas on 4/14/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

class DecoratedWord: NSObject {

    static let textFontName = "SourceCodePro-Light"
    static let swappedFontName = "SourceCodePro-Light"
    static let textFontSize:CGFloat = 28
    
    let word:String
    let missingCharacters:[Character]
    let dot:Character
    let wildcard:Character
    let colors:[UIColor]
    var attributedString:NSMutableAttributedString!
    var characterPositions = [Character:[Int]]()

    init(_ word:String, missingCharacters:[Character], dot:Character, wildcard:Character, colors:[UIColor]) {
        self.word = word
        self.missingCharacters = missingCharacters
        self.dot = dot
        self.wildcard = wildcard
        self.colors = colors
    
        super.init()
        
        generateAttributedString()
    }
    
    
    private func generateAttributedString() {
        
        // Determine where each of the to-swap characters and the wildcards are
        for character in missingCharacters + [wildcard] {
            
            var currentCharacterPositions = [Int]()
            for (index, wordCharacter) in word.characters.enumerated() {
                if wordCharacter == character {
                    currentCharacterPositions.append(index)
                }
                characterPositions[character] = currentCharacterPositions
            }
        }
        
        let attributedString = NSMutableAttributedString(string: word)
        
        let entireStringRange = NSMakeRange(0, attributedString.length)
        attributedString.addAttribute(NSKernAttributeName, value: 10, range: entireStringRange)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.white, range: entireStringRange)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name:DecoratedWord.textFontName, size:DecoratedWord.textFontSize)!, range: entireStringRange)
        
        for (index, character) in missingCharacters.enumerated() {
            for position in characterPositions[character]! {
                let characterRange = NSMakeRange(position, 1)
                DecoratedWord.replaceAndHighlight(attributedString: attributedString, replaceWith: dot, range: characterRange, color:colors[index])
            }
        }
        
        for position in characterPositions[wildcard]! {
            let characterRange = NSMakeRange(position, 1)
            DecoratedWord.replaceAndHighlight(attributedString: attributedString, replaceWith: wildcard, range: characterRange, color:UIColor.white)
        }
        
        self.attributedString = attributedString
    }
    
    func setLetters(withOriginalLetter originalLetter:Character, toLetter newLetter:Character) {
        guard let positions = characterPositions[originalLetter] else { return }
        for position in positions {
            let range = NSMakeRange(position, 1)
            let newString = String(newLetter)
            attributedString.replaceCharacters(in: range, with: newString)
        }
    }

    private class func replaceAndHighlight(attributedString:NSMutableAttributedString, replaceWith:Character, range:NSRange, color:UIColor) {
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0, green:0, blue:0, alpha:0.4)
        shadow.shadowBlurRadius = 2.0
        shadow.shadowOffset = CGSize(width:0.0, height:2.0)
        
        attributedString.replaceCharacters(in: range, with: String(replaceWith))
        attributedString.addAttribute(NSForegroundColorAttributeName, value:color, range:range)
//        attributedString.addAttribute(NSShadowAttributeName, value: shadow, range: range)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont(name:DecoratedWord.swappedFontName, size:DecoratedWord.textFontSize)!, range: range)
    }
}

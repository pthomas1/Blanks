//
//  ViewController.swift
//  Blanks
//
//  Created by Peter Thomas on 4/6/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

// todo: animate words in letter by letter (all e's, all f's, etc)

class ViewController: UIViewController, KeyboardViewDelegate {

    @IBOutlet weak var requiredWordsStackView: UIStackView!
    @IBOutlet weak var bonusWordsStackView: UIStackView!
    @IBOutlet weak var containerView: UIView!
    
    var keyboardView:KeyboardView!
    
    let level:Level
    let dotCharacter:Character = "◆"
    let wildcardCharacter:Character = "*" //"✦" //⌽

    var decoratedWords:[DecoratedWord]!
    var attributedWords:[NSAttributedString]!
    
    var colors:[UIColor]!
    
    required init?(coder aDecoder: NSCoder) {
        
        let randomSeed = Int(Date.timeIntervalSinceReferenceDate)
        level = Level(randomSeed:randomSeed, wildcardCharacter:wildcardCharacter)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colors = [UIColor(red:255/255.0, green: 128/255.0, blue: 0/255.0, alpha:1.0),
                  UIColor(red: 0/255.0, green:255/255.0, blue:64/255.0, alpha:1.0),
                  UIColor(red: 128/255.0, green:128/255.0, blue:255/255.0, alpha:1.0),
                  UIColor(red: 128/255.0, green:128/255.0, blue:128/255.0, alpha:1.0)]
        
        decoratedWords = [DecoratedWord]()
        
        var validLetters = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters)
        for word in level.words {
            
            let decoratedWord = DecoratedWord(word, missingCharacters:level.missingCharacters, dot:dotCharacter, wildcard:wildcardCharacter, colors:colors)
            decoratedWords.append(decoratedWord)
            
            let label = UILabel()
            label.attributedText = decoratedWord.attributedString
            requiredWordsStackView.addArrangedSubview(label)
            
            let decoratedString = decoratedWord.attributedString.string
            let lettersInWord = Set(decoratedString.characters)
            validLetters = validLetters.subtracting(lettersInWord)
        }
        
        // Add "keyboard" programatically from nib because including it in the storyboard causes crashes/hangs in xcode
        addKeyboardView(validLetters: validLetters)
    }
    
    func addKeyboardView(validLetters:Set<Character>) {
        keyboardView = UINib(nibName: "KeyboardView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! KeyboardView
        keyboardView.translatesAutoresizingMaskIntoConstraints = false
        keyboardView.delegate = self
        
        self.view.addSubview(keyboardView)
        keyboardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:20).isActive = true
        keyboardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:-20).isActive = true
        keyboardView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant:-20).isActive = true
        keyboardView.topAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        keyboardView.layer.cornerRadius = 10
        keyboardView.layer.shadowColor = UIColor.black.cgColor
        keyboardView.layer.shadowRadius = 1
        keyboardView.layer.shadowOffset = CGSize(width:0, height:1)
        keyboardView.layer.shadowOpacity = 0.5
        
        keyboardView.initialize(selectedCount:level.missingCharacters.count, validLetters:validLetters)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func swapOriginalLetter(atIndex index:Int, withNewLetter letter:Character) {
        
        let swappedLetter = level.swappedLetter(forIndex:index)

        for (wordIndex, decoratedWord) in decoratedWords.enumerated() {
            decoratedWord.setLetters(withOriginalLetter:swappedLetter, toLetter:letter)
            let label = requiredWordsStackView.arrangedSubviews[wordIndex] as! UILabel
            label.attributedText = decoratedWord.attributedString
        }
    }
    
    // MARK: - KeyboardViewDelegate
    
    func keyboard(_ keyboardView:KeyboardView, selectedLetter:Character, colorIndex:Int) {

        swapOriginalLetter(atIndex: colorIndex, withNewLetter: selectedLetter)
    }

    func keyboard(_ keyboardView:KeyboardView, clearedSelectedLetter letter:Character, colorIndex:Int) {
        
        swapOriginalLetter(atIndex: colorIndex, withNewLetter: dotCharacter)
    }

    func keyboard(_ keyboardView:KeyboardView, colorForIndex index:Int) -> UIColor {
        return colors[index]
    }

}

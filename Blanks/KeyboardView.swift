//
//  KeyboardView.swift
//  Blanks
//
//  Created by Peter Thomas on 4/13/17.
//  Copyright © 2017 Peter Thomas. All rights reserved.
//

import UIKit

protocol KeyboardViewDelegate: class {
    func keyboard(_ keyboardView:KeyboardView, selectedLetter:Character, colorIndex:Int)
    func keyboard(_ keyboardView:KeyboardView, clearedSelectedLetter:Character, colorIndex:Int)
    func keyboard(_ keyboardView:KeyboardView, colorForIndex:Int) -> UIColor
}

class KeyboardView: UIView {

    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var keyPopupView: UIView!
    @IBOutlet weak var keyPopupLabel:UILabel!
    
    // .last is current
    var selectedLetterToColorIndexes = [Character:[Int]]()
    var colorIndexToSelectedLetter = [Int:Character]()
    var enabledColorIndexes = Set<Int>()
    
    var letterButtons: [UIButton]!
    
    var selectionColorIndex:Int?
    var selectionDidChange = false {
        didSet {
            if selectionDidChange == true {
                guard let selectionColorIndex = selectionColorIndex else { return }
                enabledColorIndexes.insert(selectionColorIndex)
            }
        }
    }

    var movementTimer:Timer?
    var lastEmptyLetterSelected:Character?
    
    weak var delegate:KeyboardViewDelegate?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false

        letterButtons = (topStackView.arrangedSubviews as! [UIButton]) + (bottomStackView.arrangedSubviews as! [UIButton])
        keyPopupView.layer.cornerRadius = 4
        keyPopupView.layer.shadowColor = UIColor.black.cgColor
        keyPopupView.layer.shadowRadius = 1
        keyPopupView.layer.shadowOffset = CGSize(width:0, height:-keyPopupView.layer.shadowRadius)
        keyPopupView.layer.shadowOpacity = 0.5
        
        letterButtons.forEach {
            $0.layer.cornerRadius = keyPopupView.layer.cornerRadius
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.clear.cgColor
            $0.isUserInteractionEnabled = false
            $0.titleLabel?.font = UIFont(name:"SourceCodePro-Semibold", size:20)
        }
    }
    
    func initialize(selectedCount:Int, validLetters:Set<Character>) {

        let initialSelectedLetters:Set<Character> = validLetters.randomUniqueSampleSet(count:selectedCount)
        
        validLetters.forEach { selectedLetterToColorIndexes[$0] = [] }
        
        for (index, character) in initialSelectedLetters.enumerated() {
            selectLetter(character, colorIndex:index, showHint:false)
        }
        
        letterButtons.forEach {
            guard let letter = $0.titleLabel?.text?.characters.first else { return }
            if validLetters.contains(letter) == false {
                $0.isHidden = true
            }
        }
    }
    
    func selectLetter(_ letter:Character, colorIndex:Int, showHint:Bool=true) {

        deselectLetter(colorIndexToSelectedLetter[colorIndex])

        guard let button = letterButtons.first(where: { $0.titleLabel!.text == String(letter) } ) else {
            logger.error("Request for non-exitent button \(letter)")
            return
        }

        colorButton(button, colorIndex: colorIndex)

        selectedLetterToColorIndexes[letter]?.append(colorIndex)
        colorIndexToSelectedLetter[colorIndex] = letter
        
        if showHint {
            keyPopupView.backgroundColor = delegate?.keyboard(self, colorForIndex: colorIndex)
            keyPopupLabel.textColor = self.backgroundColor
            keyPopupLabel.text = String(letter)
            let buttonFrame = button.convert(button.bounds, to: self)
            
            var duration = 0.0
            if keyPopupView.isHidden {
                duration = 0.05
                keyPopupView.frame = buttonFrame
                keyPopupView.isHidden = false
            }
            
            let positionPopupBlock = {
                var frame = buttonFrame
                let offset:CGFloat = 50
                frame.size.height += offset
                frame.origin.y -= offset
                self.keyPopupView.frame = frame
            }
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.beginFromCurrentState], animations: positionPopupBlock, completion: nil)

        } else {
            keyPopupView.isHidden = true
        }
    }
    
    func deselectLetter(_ letter:Character?) {

        guard let letter = letter else { return }
        guard var colorIndexes = selectedLetterToColorIndexes[letter] else { return }

        guard let button = letterButtons.first(where: { $0.titleLabel!.text == String(letter) } ) else {
            logger.error("Request for non-exitent button \(letter)")
            return
        }

        // remove whatever is current and replace with new current or clear
        if colorIndexes.count > 0 {
            colorIndexes.removeLast()
        }
        
        if let colorIndex = colorIndexes.last {
            colorButton(button, colorIndex:colorIndex)
        } else {
            clearButton(button)
        }
        selectedLetterToColorIndexes[letter] = colorIndexes
    }

    func colorButton(_ button:UIButton, colorIndex:Int) {

        guard let color = delegate?.keyboard(self, colorForIndex: colorIndex) else { return clearButton(button) }

        button.layer.borderColor = color.cgColor
        if enabledColorIndexes.contains(colorIndex) {
            button.backgroundColor = color
            button.setTitleColor(self.backgroundColor, for: .normal)
        } else {
            button.backgroundColor = UIColor.clear
            button.setTitleColor(color, for: .normal)
        }
    }

    func clearButton(_ button:UIButton) {
        button.layer.borderColor = UIColor.clear.cgColor
        button.backgroundColor = nil
        button.setTitleColor(UIColor(red:175/255.0, green:175/255.0, blue:175/255.0, alpha:1.0), for: .normal)
    }
    
    func nearestAdjacentKeyButton(toTouch touch:UITouch, potentialButtons:[UIButton]) -> UIButton? {
        
        var nearest:UIButton? = nil
        var nearestDistance:CGFloat = CGFloat.infinity
        
        for button in potentialButtons {
            let position = touch.location(in: button)
            let center = CGPoint(x:button.bounds.midX, y:button.bounds.midY)
            let delta = CGPoint(x:abs(position.x - center.x), y:abs(position.y - center.y))
            
            // can't be worse than adjacent
            if delta.x < 1.5 * button.frame.size.width && delta.y < 1.5 * button.frame.size.height {
                let distance = sqrt(delta.x*delta.x + delta.y*delta.y)
                
                if distance < nearestDistance {
                    nearest = button
                    nearestDistance = distance
                }
            }
        }
        
        return nearest
    }
    
    func nearestAdjacentSelectedKeyButton(toTouch touch:UITouch) -> UIButton? {
        let validButtons = letterButtons.filter {
            guard let currentLetter = $0.titleLabel?.text?.characters.first else { return false }
            return self.selectedLetterToColorIndexes[currentLetter]?.count != 0
        }
        
        return nearestAdjacentKeyButton(toTouch: touch, potentialButtons: validButtons)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        guard let currentLetterButton = nearestAdjacentSelectedKeyButton(toTouch: touch) else { return }
        guard let currentLetter = currentLetterButton.titleLabel?.text?.characters.first else {
            selectionColorIndex = nil
            logger.debug("Clear color index selection")
            return
        }
        
        lastEmptyLetterSelected = currentLetter
        selectionDidChange = false
        selectionColorIndex = selectedLetterToColorIndexes[currentLetter]?.last
        
        if let _ = selectionColorIndex {

            // If the user presses the key to make it appear we treat it the same as if they moved to select
            // a new key.
            movementTimer?.invalidate()
            movementTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
                self.touchesMoved(touches, with: event)
            })
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let selectionColorIndex = selectionColorIndex else { return }
        guard let touch = touches.first else { return }
        guard let currentLetterButton = nearestAdjacentKeyButton(toTouch: touch, potentialButtons:letterButtons) else { return }
        guard let currentLetter = currentLetterButton.titleLabel?.text?.characters.first else { return }
        
        // on selection we do a swap to most recent empty if 2 end up on same spot
        if selectedLetterToColorIndexes[currentLetter]?.count ?? 0 == 0 {
            lastEmptyLetterSelected = currentLetter
        }

        // if we moved the selection for the current color index fill in any bordered cells
        if currentLetter != colorIndexToSelectedLetter[selectionColorIndex] {
            selectionDidChange = true
        }
        
        selectLetter(currentLetter, colorIndex: selectionColorIndex)
        
        // if the user sticks on this key long enough we pretend he selected it
        movementTimer?.invalidate()
        movementTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (timer) in
            self.delegate?.keyboard(self, selectedLetter: currentLetter, colorIndex: selectionColorIndex)
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let selectionColorIndex = selectionColorIndex else { return }
        guard let currentLetter = colorIndexToSelectedLetter[selectionColorIndex] else { return }

//        logger.debug("lastEmptyLetterSelected: \(self.lastEmptyLetterSelected ?? " ".characters.first!)")
//        logger.debug("Selections: \(self.selectedLetterToColorIndexes)")
//        logger.debug("did change: \(self.selectionDidChange) enabled color indexes: \(self.enabledColorIndexes)")
        movementTimer?.invalidate()
        
        if let lastEmptyLetterSelected = lastEmptyLetterSelected {

            // if we are about to stack up colors move the old color over to the new empty spot
            if selectedLetterToColorIndexes[currentLetter]?.count ?? 0 > 1 {
                
                if let existingLetterColorIndex = selectedLetterToColorIndexes[currentLetter]?.first {
                    enabledColorIndexes.remove(existingLetterColorIndex)
                    delegate?.keyboard(self, clearedSelectedLetter:lastEmptyLetterSelected, colorIndex:existingLetterColorIndex)
                    selectLetter(lastEmptyLetterSelected, colorIndex:existingLetterColorIndex)
                }
            }
        }
        self.lastEmptyLetterSelected = nil
        
        // handle click vs drag
        if selectionDidChange {
            delegate?.keyboard(self, selectedLetter: currentLetter, colorIndex: selectionColorIndex)
        } else {
            if enabledColorIndexes.contains(selectionColorIndex) {
                enabledColorIndexes.remove(selectionColorIndex)
                delegate?.keyboard(self, clearedSelectedLetter:currentLetter, colorIndex:selectionColorIndex)
            } else {
                enabledColorIndexes.insert(selectionColorIndex)
                delegate?.keyboard(self, selectedLetter: currentLetter, colorIndex: selectionColorIndex)
            }
        }
        
        selectLetter(currentLetter, colorIndex: selectionColorIndex, showHint: false)
        self.selectionColorIndex = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }
}

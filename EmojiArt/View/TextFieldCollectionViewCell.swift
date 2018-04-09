//
//  TextFieldCollectionViewCell.swift
//  EmojiArt
//
//  Created by Tomasz Bogusz on 09.04.2018.
//  Copyright © 2018 Tomasz Bogusz. All rights reserved.
//

import UIKit

class TextFieldCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    // Instance properties
    var resignationHandler: (() -> Void)?
    
}

// MARK: - UITextFieldDelegate implementation
extension TextFieldCollectionViewCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
}

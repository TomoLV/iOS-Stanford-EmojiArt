//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Tomasz Bogusz on 06.04.2018.
//  Copyright © 2018 Tomasz Bogusz. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    
    // MARK: - Instance properties
    var backgroundImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Drawing functions
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: bounds)
    }

}

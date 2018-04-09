//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Tomasz Bogusz on 09.04.2018.
//  Copyright © 2018 Tomasz Bogusz. All rights reserved.
//

import Foundation

struct EmojiArt {
    
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}

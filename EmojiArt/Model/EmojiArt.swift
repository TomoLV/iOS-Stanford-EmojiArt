//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Tomasz Bogusz on 09.04.2018.
//  Copyright © 2018 Tomasz Bogusz. All rights reserved.
//

import Foundation

struct EmojiArt: Codable {
    
    var url: URL
    var emojis = [EmojiInfo]()
    
    struct EmojiInfo: Codable {
        let x: Int
        let y: Int
        let text: String
        let size: Int
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init(url: URL, emojis: [EmojiInfo]) {
        self.url = url
        self.emojis = emojis
    }
}

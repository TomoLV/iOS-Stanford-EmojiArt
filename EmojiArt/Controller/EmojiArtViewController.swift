//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Tomasz Bogusz on 06.04.2018.
//  Copyright © 2018 Tomasz Bogusz. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emojiArtView: EmojiArtView!
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    // MARK: - Instance properties
    var imageFetcher: ImageFetcher!
    
    // MARK: - View Controller's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

// MARK: - UIDropInteractionDelegate implementation
extension EmojiArtViewController: UIDropInteractionDelegate {
    
    // Only accept something that is an URL and UIImage
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    // We are going to copy image from outside of the app
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .copy)
    }
    
    // Perform drop
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        // Initialize ImageFetcher
        imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                self.emojiArtView.backgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self) { nsurls in
            if let url = nsurls.first as? URL {
                self.imageFetcher.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { images in
            if let image = images.first as? UIImage {
                self.imageFetcher.backup = image
            }
        }
    }
}

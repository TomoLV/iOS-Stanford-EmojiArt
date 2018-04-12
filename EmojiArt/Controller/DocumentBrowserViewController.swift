//
//  DocumentBrowserViewController.swift
//  EmojiArt
//
//  Created by Tomasz Bogusz on 12.04.2018.
//  Copyright © 2018 Tomasz Bogusz. All rights reserved.
//

import UIKit


class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
    // Instance properties
        var template: URL?
    
    // MARK: - View Controller's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        allowsDocumentCreation = false
        allowsPickingMultipleItems = false
        
        template = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("Untitled.json")
        if template != nil {
            allowsDocumentCreation = FileManager.default.createFile(atPath: template!.path, contents: Data())
        }
    }
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        importHandler(template, .copy)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let documentVC = storyBoard.instantiateViewController(withIdentifier: "DocumentMVC")
        if let emojiArtViewController = documentVC.contents as? EmojiArtViewController {
            emojiArtViewController.document = EmojiArtDocument(fileURL: documentURL)
        }
        present(documentVC, animated: true)
    }
}

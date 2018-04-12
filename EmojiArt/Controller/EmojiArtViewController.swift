//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Tomasz Bogusz on 06.04.2018.
//  Copyright © 2018 Tomasz Bogusz. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {
    
    // MARK: - Model
    var document: EmojiArtDocument?
    var emojiArt: EmojiArt? {
        get {
            if let url = emojiArtBackgroundImage.url {
                // use compactMap (EDIT: flatMap used in course is deprecated) to ignore nil values
                let emojis = emojiArtView.subviews.compactMap { $0 as? UILabel }.compactMap { EmojiArt.EmojiInfo(label: $0) }
                return EmojiArt(url: url, emojis: emojis)
            }
            return nil
        } set {
            // clear ui before setting UI from new model
            emojiArtBackgroundImage = (nil, nil)
            emojiArtView.subviews.compactMap { $0 as? UILabel }.forEach { $0.removeFromSuperview() }
            // fetch new elements for UI
            if let url = newValue?.url {
                imageFetcher = ImageFetcher(fetch: url) { (url, image) in
                    DispatchQueue.main.async {
                        self.emojiArtBackgroundImage = (url, image)
                        newValue?.emojis.forEach {
                            let attributedText = $0.text.attributedString(withTextStyle: .body, ofSize: CGFloat($0.size))
                            self.emojiArtView.addLabel(with: attributedText, centeredAt: CGPoint(x: $0.x, y: $0.y))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var dropZone: UIView! {
        didSet {
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    @IBOutlet weak var emojiCollectionView: UICollectionView! {
        didSet {
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    
    // MARK: - Actions
    @IBAction func addEmoji() {
        addingEmoji = true
        emojiCollectionView.reloadSections(IndexSet(integer: 0))
    }
    @IBAction func save(_ sender: UIBarButtonItem? = nil) {
        document?.emojiArt = emojiArt
        if document?.emojiArt != nil {
            document?.updateChangeCount(.done)
        }
    }
    @IBAction func close(_ sender: UIBarButtonItem) {
        save()
        dismiss(animated: true) {
            self.document?.close()
        }
    }
    
    // MARK: - Instance properties
    var imageFetcher: ImageFetcher!
    var emojiArtView = EmojiArtView()
    // Next 2 lines: Use tuple (url, image) to keep url and image together, use _ to indicate that this var is set somewhere else
    private var _emojiArtBackgroundImageURL: URL?
    var emojiArtBackgroundImage: (url: URL?, image: UIImage?) {
        get {
            return (_emojiArtBackgroundImageURL, emojiArtView.backgroundImage)
        }
        set {
            _emojiArtBackgroundImageURL = newValue.url
            scrollView?.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue.image
            let size = newValue.image?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            if let dropZone = self.dropZone, size.width > 0, size.height > 0 {
                scrollView.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    var emojis = "😀🎁✈️🎱🍎🐶🐝☕️🎼🚲♣️👨‍🎓✏️🌈🤡🎓👻☎️".map { String($0) }
    private var addingEmoji: Bool = false
    
    // MARK: - View Controller's Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        document?.open { success in
            if success {
                self.title = self.document?.localizedName
                self.emojiArt = self.document?.emojiArt
            }
        }
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
                self.emojiArtBackgroundImage = (url, image)
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

// MARK: - UIScrollViewDelegate implementation
extension EmojiArtViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Adjust scrollView's width and height constraints when zoom finishes
        scrollViewHeight.constant = scrollView.contentSize.height
        scrollViewWidth.constant = scrollView.contentSize.width
    }
}

// MARK: - UICollectionViewDataSource implementation
extension EmojiArtViewController: UICollectionViewDataSource {
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return emojis.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
            if let emojiCell = cell as? EmojiCollectionViewCell {
                let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font:font])
                emojiCell.label.attributedText = text
            }
            return cell
        } else if addingEmoji {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiInputCell", for: indexPath)
            if let inputCell = cell as? TextFieldCollectionViewCell {
                inputCell.resignationHandler = { [weak self, unowned inputCell] in
                    if let text = inputCell.textField.text {
                        self?.emojis = (text.map { String($0) } + self!.emojis).uniquified
                    }
                    self?.addingEmoji = false
                    self?.emojiCollectionView.reloadData()
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddEmojiButtonCell", for: indexPath)
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate implementation
extension EmojiArtViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let inputCell = cell as? TextFieldCollectionViewCell {
            inputCell.textField.becomeFirstResponder()
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout implementation
extension EmojiArtViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if addingEmoji && indexPath.section == 0 {
            return CGSize(width: 300, height: 80)
        } else {
            return CGSize(width: 80, height: 80)
        }
    }
    
}

// MARK: - UICollectionViewDragDelegate implementation
extension EmojiArtViewController: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // set localContext to collectionView, for usage with drop later
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        // Disable dragging when addingEmoji
        if !addingEmoji, let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText {
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            // Since we are only dragging emojis, we can use this "shortcut" method with localObject, drop requires more
            dragItem.localObject = attributedString
            return [dragItem]
        } else {
            return []
        }
    }
}

// MARK: - UICollectionViewDropDelegate implementation
extension EmojiArtViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        // Only allow repositioning and drop in section 1
        if let indexPath = destinationIndexPath, indexPath.section == 1 {
            let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
            return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .cancel)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            // 1. Local case - drop comes from collectionView (other item already present in collectionView)
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributedString = item.dragItem.localObject as? NSAttributedString {
                    // Use performBatchUpdates to stay in sync with the model
                    collectionView.performBatchUpdates({
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributedString.string, at: destinationIndexPath.item)
                        // We DO NOT want to do reloadData on collecionView here, so instead we only want to delete and insert selected rows
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                    })
                    coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
                }
            // 2. Outside case - drop comes from the outside
            } else {
                // Need to consider that when you drop something from outside your app, there is a time needed for that dropItem to be fetched, for example from the network request - collectionView places the placeholder, we should create placeholder in the storyboard with proper Reuse Identifier
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let attributedString = provider as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.emojis.insert(attributedString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
}

// MARK: - EmojiArt.EmojiInfo extension - failable init? to convert UILabel to EmojiInfo
// This extension should be placed right here in the controller and not in the model to properly adhere to MVC design pattern
extension EmojiArt.EmojiInfo {
    
    init?(label: UILabel) {
        // TODO: - Changed 'font = attributedText' to 'font = label.font'. Seemed like a bug in iOS 11.3, previous solution used in the course returned nil
        if let attributedText = label.attributedText, let font = label.font {
            x = Int(label.center.x)
            y = Int(label.center.y)
            text = attributedText.string
            size = Int(font.pointSize)
        } else {
            return nil
        }
    }
}

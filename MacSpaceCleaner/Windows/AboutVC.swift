//
//  AboutVC.swift
//  MacSpaceCleaner
//
//  Created by SanketK on 3/16/25.
//

import Foundation
import Cocoa

class AboutVC: NSViewController {
    
    @IBOutlet private var imgAppIcon   : NSImageView!
    @IBOutlet private var lblTitle     : NSTextField!
    @IBOutlet private var lblSubTitle  : NSTextField!
    @IBOutlet private var lblMadeBy    : NSTextField!
    @IBOutlet private var lblMadeByName: NSTextField!
    @IBOutlet private var lblShareRate : NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(windowResized), name: NSWindow.didResizeNotification, object: view.window)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.title = "About Mac Space Cleaner"
        
        self.setLabel()
        
        // Calculate appropriate size based on content
        self.view.layoutSubtreeIfNeeded()
        let fittingSize = self.view.fittingSize
        
        self.view.window?.setContentSize(
            NSSize(width: max(600, fittingSize.width), height: fittingSize.height)
        )
        
        self.view.layoutSubtreeIfNeeded()

        /// Open app on any current window and move along with any window you go on
        self.view.window?.level = .floating
        self.view.window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.addTrackingArea()
    }
    
    func setLabel() {
        self.lblSubTitle.maximumNumberOfLines = 0
        self.lblSubTitle.isEditable = false
        self.lblSubTitle.isSelectable = false
        self.lblSubTitle.lineBreakMode = .byWordWrapping
        self.lblSubTitle.cell?.wraps = true
        self.lblSubTitle.cell?.isScrollable = false
        self.lblSubTitle.alignment = .justified
        self.lblSubTitle.stringValue = "A tool designed to efficiently free up unwanted occupied space by identifying and removing unnecessary files, cache, and other redundant data. It helps developers and general users optimize their system storage, particularly by cleaning Xcode cache, derived data, and simulator files, ensuring better performance and freeing up valuable disk space."

        self.lblTitle.stringValue = "Mac Space Cleaner"

        self.lblMadeBy.stringValue = "To learn more about this project & author of it"

        self.lblMadeByName.attributedStringValue = NSAttributedString(
            string: "click here",
            attributes: [
                .foregroundColor: NSColor.systemBlue,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: NSColor.systemBlue,
                .cursor: NSCursor.pointingHand
            ]
        )

        self.lblShareRate.stringValue = "If you find it useful, feel free to star the repository and share your feedback!"
    }
    
    @IBAction func clickGestureOnMadeByName(_ sender: NSClickGestureRecognizer) {
        let url = URL(string: "https://github.com/sanketk2020/MacSpaceCleaner")!
        if NSWorkspace.shared.open(url) {
            self.view.window?.close()
            print("Browser was successfully opened")
        }
    }
    
    @objc func windowResized() {
        let maxWidth = view.frame.width - 40
        self.lblSubTitle.preferredMaxLayoutWidth = maxWidth
    }
    
    func addTrackingArea() {
        let trackingArea = NSTrackingArea(
            rect: self.lblMadeByName.bounds,
            options: [.activeInKeyWindow, .mouseEnteredAndExited, .cursorUpdate],
            owner: self,
            userInfo: nil
        )
        self.lblMadeByName.addTrackingArea(trackingArea)
    }
    
    override func mouseEntered(with event: NSEvent) {
        NSCursor.pointingHand.set()
    }
    
    override func mouseExited(with event: NSEvent) {
        NSCursor.arrow.set()
    }
    
}

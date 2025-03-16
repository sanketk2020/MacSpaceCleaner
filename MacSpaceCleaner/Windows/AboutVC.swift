//
//  AboutVC.swift
//  MacSpaceCleaner
//
//  Created by SanketK on 3/16/25.
//

import Foundation
import Cocoa

class AboutVC: NSViewController {
    
    @IBOutlet weak var imgAppIcon   : NSImageView!
    @IBOutlet weak var lblTitle     : NSTextField!
    @IBOutlet weak var lblSubTitle  : NSTextField!
    @IBOutlet weak var lblMadeBy    : NSTextField!
    @IBOutlet weak var lblMadeByName: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(windowResized), name: NSWindow.didResizeNotification, object: view.window)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.ApplyStyle()
        self.setLabel()
        
        // Calculate appropriate size based on content
        self.view.layoutSubtreeIfNeeded()
        let fittingSize = self.view.fittingSize
        
        if let window = self.view.window {
            let newSize = NSSize(width: max(500, fittingSize.width), height: fittingSize.height)
            window.setContentSize(newSize)
        }
        
        self.view.layoutSubtreeIfNeeded()

        /// Open app on any current window and move along with any window you go on
        self.view.window?.level = .floating
        self.view.window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.addTrackingArea()
    }
    
    func ApplyStyle(){
        self.title = "About Mac Space Cleaner"
    }
    
    func setLabel(){
        self.lblSubTitle.maximumNumberOfLines = 0
        self.lblSubTitle.isEditable = false
        self.lblSubTitle.isSelectable = false
        self.lblSubTitle.lineBreakMode = .byWordWrapping
        self.lblSubTitle.cell?.wraps = true
        self.lblSubTitle.cell?.isScrollable = false
        self.lblSubTitle.alignment = .justified
        
        self.lblTitle.stringValue = "Mac Space Cleaner"
                
        self.lblSubTitle.stringValue = "A tool designed to efficiently free up unwanted occupied space by identifying and removing unnecessary files, cache, and other redundant data. It helps developers and general users optimize their system storage, particularly by cleaning Xcode cache, derived data, and simulator files, ensuring better performance and freeing up valuable disk space."
        
        self.lblMadeBy.stringValue = "Made By"
        
        let madeByText = "Sanket Khatri"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: NSColor.systemBlue,
            .cursor: NSCursor.pointingHand
        ]
        let attributedString = NSAttributedString(string: madeByText, attributes: attributes)
        self.lblMadeByName.attributedStringValue = attributedString
    }
    
    @IBAction func clickGestureOnMadeByName(_ sender: NSClickGestureRecognizer) {
        let url = URL(string: "https://github.com/sanketk2020")!
        if NSWorkspace.shared.open(url) {
            self.view.window?.close()
            print("Browser was successfully opened")
        }
    }
    
    @objc func windowResized() {
        updateLabelFrame()
    }
    
    func updateLabelFrame() {
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

/*
 
 //
 //  AppDelegate.swift
 //  Free Space
 //
 //  Created by SanketK on 2/28/25.
 //

 import Cocoa
 import UserNotifications
 import ServiceManagement

 @main
 class AppDelegate: NSObject, NSApplicationDelegate {
     
     var statusItem              : NSStatusItem!
     var aboutWindowController   : NSWindowController?
     
     var progressWindow          : NSWindow!
     var progressBar             : NSProgressIndicator!
     
     func applicationDidFinishLaunching(_ aNotification: Notification) {
         
         self.createProgressWindow()
         NSApp.setActivationPolicy(.accessory)
         self.openAppOnStartUp()
         UNUserNotificationCenter.current().delegate = self
         
         UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
             if let error = error {
                 print("Notification permission error: \(error)")
             } else if granted {
                 print("Notification permission granted")
             } else {
                 print("Notification permission denied")
             }
         }

         // Create a status bar item with variable length
         self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
         
         if let button = self.statusItem.button {
             // Set an icon for the status item (using SF Symbols or a custom image)
             button.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Clean DerivedData")
         }
         
         // Create the menu for the status item
         let menu = NSMenu()
         menu.addItem(NSMenuItem(title: "Clean DerivedData", action: #selector(cleanDerivedData), keyEquivalent: "C"))
         menu.addItem(NSMenuItem(title: "Clear Xcode Caches", action: #selector(clearXcodeCaches), keyEquivalent: "X"))
         menu.addItem(NSMenuItem(title: "Clear Archives", action: #selector(clearArchives), keyEquivalent: "A"))
         menu.addItem(NSMenuItem(title: "Clear iOS Device Support", action: #selector(clearIOSDeviceSupport), keyEquivalent: "I"))
         menu.addItem(NSMenuItem(title: "Clear watchOS Device Support", action: #selector(clearWatchOSDeviceSupport), keyEquivalent: "W"))
         menu.addItem(NSMenuItem(title: "Clear tvOS Device Support", action: #selector(clearTVOSDeviceSupport), keyEquivalent: "T"))
         menu.addItem(NSMenuItem(title: "Remove Old Simulators", action: #selector(removeOldSimulators), keyEquivalent: "R"))
         menu.addItem(NSMenuItem(title: "Clear Caches", action: #selector(clearCaches), keyEquivalent: "S"))
         menu.addItem(NSMenuItem(title: "Clear CocoaPods Cache", action: #selector(clearCocoaPodsCache), keyEquivalent: "P"))
         menu.addItem(NSMenuItem(title: "Empty Trash", action: #selector(emptyTrash), keyEquivalent: "D"))
         menu.addItem(NSMenuItem.separator())
         menu.addItem(NSMenuItem(title: "Clear All", action: #selector(clearAll), keyEquivalent: "E"))
         menu.addItem(NSMenuItem.separator())
         menu.addItem(NSMenuItem(title: "About", action: #selector(about), keyEquivalent: ""))
         menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "Q"))
         
         statusItem.menu = menu
     }
     
     func createProgressWindow() {
         self.progressWindow = NSWindow(contentRect: NSMakeRect(0, 0, 300, 100),
                                   styleMask: [.titled, .closable],
                                   backing: .buffered, defer: false)
         self.progressWindow.title = "Cleaning..."
         self.progressWindow.center()
         
         self.progressBar = NSProgressIndicator(frame: NSMakeRect(20, 40, 260, 20))
         self.progressBar.isIndeterminate = false
         self.progressBar.minValue = 0
         self.progressBar.maxValue = 100
         self.progressWindow.contentView?.addSubview(self.progressBar)
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     func openAppOnStartUp(){
         if #available(macOS 13.0, *) {
             try? SMAppService.mainApp.register()
         } else {
             // Fallback on earlier versions
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func cleanDerivedData() {
         // Construct the absolute path to the global DerivedData folder.
         // NSUserName() returns the current user's short name.
         let derivedDataPath = "/Users/\(NSUserName())/Library/Developer/Xcode/DerivedData"
         let fileManager = FileManager.default
         
         // Check if the folder exists
         if fileManager.fileExists(atPath: derivedDataPath) {
             do {
                 // Get all items (files/folders) inside DerivedData
                 let items = try fileManager.contentsOfDirectory(atPath: derivedDataPath)
                 for item in items {
                     let fullPath = (derivedDataPath as NSString).appendingPathComponent(item)
                     try fileManager.removeItem(atPath: fullPath)
                 }
                 self.showNotification(title: "Clean DerivedData", message: "DerivedData contents deleted successfully!", success: true)
             } catch {
                 self.showNotification(title: "Error", message: "Failed to clean DerivedData: \(error.localizedDescription)", success: false)
             }
         } else {
             self.showNotification(title: "Info", message: "DerivedData folder not found!", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     /// Deletes the contents of the Xcode Caches folder.
     @objc func clearXcodeCaches() {
         // Xcode caches are typically stored in this folder:
         let xcodeCachesPath = "/Users/\(NSUserName())/Library/Developer/CoreSimulator/Caches"
         let fileManager = FileManager.default
         
         guard fileManager.fileExists(atPath: xcodeCachesPath) else {
             self.showNotification(title: "Info", message: "Xcode Caches folder not found!", success: false)
             return
         }
         
         do {
             let items = try fileManager.contentsOfDirectory(atPath: xcodeCachesPath)
             var failedItems = [String]()
             
             for item in items {
                 let fullPath = (xcodeCachesPath as NSString).appendingPathComponent(item)
                 do {
                     try fileManager.removeItem(atPath: fullPath)
                 } catch {
                     print("Failed to remove \(fullPath): \(error.localizedDescription)")
                     failedItems.append(item)
                 }
             }
             
             if failedItems.isEmpty {
                 self.showNotification(title: "Clear Xcode Caches", message: "Xcode Caches cleared successfully!", success: true)
             } else {
                 self.showNotification(title: "Clear Xcode Caches", message: "Some items could not be removed: \(failedItems.joined(separator: ", "))", success: true)
             }
         } catch {
             self.showNotification(title: "Error", message: "Failed to clear Xcode Caches: \(error.localizedDescription)", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     /// Deletes the contents of the global Xcode Archives folder.
     @objc func clearArchives() {
         let archivesPath = "/Users/\(NSUserName())/Library/Developer/Xcode/Archives"
         let fileManager = FileManager.default
         
         guard fileManager.fileExists(atPath: archivesPath) else {
             self.showNotification(title: "Info", message: "Archives folder not found!", success: false)
             return
         }
         
         do {
             let items = try fileManager.contentsOfDirectory(atPath: archivesPath)
             var failedItems = [String]()
             
             for item in items {
                 let fullPath = (archivesPath as NSString).appendingPathComponent(item)
                 do {
                     try fileManager.removeItem(atPath: fullPath)
                 } catch {
                     print("Failed to remove \(fullPath): \(error.localizedDescription)")
                     failedItems.append(item)
                 }
             }
             
             if failedItems.isEmpty {
                 self.showNotification(title: "Clear Archives", message: "Xcode Archives cleared successfully!", success: true)
             } else {
                 self.showNotification(title: "Clear Archives", message: "Some items could not be removed: \(failedItems.joined(separator: ", "))", success: true)
             }
         } catch {
             self.showNotification(title: "Error", message: "Failed to clear Archives: \(error.localizedDescription)", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func clearIOSDeviceSupport() {
         let iosDeviceSupportPath = "/Users/\(NSUserName())/Library/Developer/Xcode/iOS DeviceSupport"
         let fileManager = FileManager.default
         guard fileManager.fileExists(atPath: iosDeviceSupportPath) else {
             self.showNotification(title: "Info", message: "iOS Device Support folder not found!", success: false)
             return
         }
         do {
             let items = try fileManager.contentsOfDirectory(atPath: iosDeviceSupportPath)
             for item in items {
                 let fullPath = (iosDeviceSupportPath as NSString).appendingPathComponent(item)
                 try fileManager.removeItem(atPath: fullPath)
             }
             self.showNotification(title: "Clear iOS Device Support", message: "iOS Device Support cleared successfully!", success: true)
         } catch {
             self.showNotification(title: "Error", message: "Failed to clear iOS Device Support: \(error.localizedDescription)", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func clearWatchOSDeviceSupport() {
         let watchOSDeviceSupportPath = "/Users/\(NSUserName())/Library/Developer/Xcode/watchOS DeviceSupport"
         let fileManager = FileManager.default
         guard fileManager.fileExists(atPath: watchOSDeviceSupportPath) else {
             self.showNotification(title: "Info", message: "watchOS Device Support folder not found!", success: false)
             return
         }
         do {
             let items = try fileManager.contentsOfDirectory(atPath: watchOSDeviceSupportPath)
             for item in items {
                 let fullPath = (watchOSDeviceSupportPath as NSString).appendingPathComponent(item)
                 try fileManager.removeItem(atPath: fullPath)
             }
             self.showNotification(title: "Clear watchOS Device Support", message: "watchOS Device Support cleared successfully!", success: true)
         } catch {
             self.showNotification(title: "Error", message: "Failed to clear watchOS Device Support: \(error.localizedDescription)", success: false)
         }
     }

     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func clearTVOSDeviceSupport() {
         let tvOSDeviceSupportPath = "/Users/\(NSUserName())/Library/Developer/Xcode/tvOS DeviceSupport"
         let fileManager = FileManager.default
         guard fileManager.fileExists(atPath: tvOSDeviceSupportPath) else {
             self.showNotification(title: "Info", message: "tvOS Device Support folder not found!", success: false)
             return
         }
         do {
             let items = try fileManager.contentsOfDirectory(atPath: tvOSDeviceSupportPath)
             for item in items {
                 let fullPath = (tvOSDeviceSupportPath as NSString).appendingPathComponent(item)
                 try fileManager.removeItem(atPath: fullPath)
             }
             self.showNotification(title: "Clear tvOS Device Support", message: "tvOS Device Support cleared successfully!", success: true)
         } catch {
             self.showNotification(title: "Error", message: "Failed to clear tvOS Device Support: \(error.localizedDescription)", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func removeOldSimulators() {
         let task = Process()
         task.launchPath = "/usr/bin/xcrun"
         task.arguments = ["simctl", "delete", "unavailable"]
         
         let pipe = Pipe()
         task.standardOutput = pipe
         task.standardError = pipe
         
         task.launch()
         task.waitUntilExit()
         
         let data = pipe.fileHandleForReading.readDataToEndOfFile()
         let output = String(data: data, encoding: .utf8) ?? ""
         if task.terminationStatus == 0 {
             self.showNotification(title: "Remove Old Simulators", message: "Old simulators removed successfully!", success: true)
         } else {
             self.showNotification(title: "Error", message: "Failed to remove old simulators: \(output)", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func clearCaches() {
         let cachesPath = "/Users/\(NSUserName())/Library/Caches"
         let fileManager = FileManager.default
         
         guard fileManager.fileExists(atPath: cachesPath) else {
             self.showNotification(title: "Info", message: "Caches folder not found!", success: false)
             return
         }
         
         do {
             let items = try fileManager.contentsOfDirectory(atPath: cachesPath)
             var failedItems = [String]()
             
             for item in items {
                 let fullPath = (cachesPath as NSString).appendingPathComponent(item)
                 do {
                     try fileManager.removeItem(atPath: fullPath)
                 } catch {
                     // Log the error and add the item to the failed list
                     print("Failed to remove \(fullPath): \(error.localizedDescription)")
                     failedItems.append(item)
                 }
             }
             
             if failedItems.isEmpty {
                 self.showNotification(title: "Clear Caches", message: "Caches cleared successfully!", success: true)
             } else {
                 self.showNotification(title: "Clear Caches", message: "Some items could not be removed: \(failedItems.joined(separator: ", "))", success: true)
             }
         } catch {
             self.showNotification(title: "Error", message: "Failed to clear Caches: \(error.localizedDescription)", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func clearCocoaPodsCache() {
         let task = Process()
         task.launchPath = "/bin/bash"
         task.arguments = ["-c", "if command -v pod &> /dev/null; then pod cache clean --all; else echo 'CocoaPods not installed'; fi"]
         
         let pipe = Pipe()
         task.standardOutput = pipe
         task.standardError = pipe
         
         task.launch()
         task.waitUntilExit()
         
         let data = pipe.fileHandleForReading.readDataToEndOfFile()
         let output = String(data: data, encoding: .utf8) ?? ""
         
         if task.terminationStatus == 0 {
             self.showNotification(title: "Clear CocoaPods Cache", message: "CocoaPods cache cleared successfully!", success: true)
         } else {
             self.showNotification(title: "Error", message: "Failed to clear CocoaPods cache: \(output)", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
     
     @objc func emptyTrash() {
         let script = "tell application \"Finder\" to empty the trash"
         let task = Process()
         task.launchPath = "/usr/bin/osascript"
         task.arguments = ["-e", script]

         task.launch()
         task.waitUntilExit()

         if task.terminationStatus == 0 {
             self.showNotification(title: "Empty Trash", message: "Trash emptied successfully!", success: true)
         } else {
             self.showNotification(title: "Error", message: "Failed to empty trash", success: false)
         }
     }
     
     // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

     
     @objc func clearAll() {
         self.cleanDerivedData()
         self.clearXcodeCaches()
         self.clearArchives()
         self.clearIOSDeviceSupport()
         self.clearWatchOSDeviceSupport()
         self.clearTVOSDeviceSupport()
         self.removeOldSimulators()
         self.clearCaches()
         self.clearCocoaPodsCache()
         self.emptyTrash()

         self.showNotification(title: "Clear All", message: "All Xcode caches, archives, and simulators cleared successfully!", success: true)
     }
     
     @objc func about() {
         
         if self.aboutWindowController == nil {
             let storyboard = NSStoryboard(name: "About", bundle: nil)
             guard let aboutVC = storyboard.instantiateController(withIdentifier: "AboutVC") as? AboutVC else { return }
             let window = NSWindow(contentViewController: aboutVC)
             window.styleMask = [.titled, .closable, .miniaturizable]
             window.setContentSize(aboutVC.view.fittingSize)
             window.makeKeyAndOrderFront(nil)
             self.aboutWindowController = NSWindowController(window: window)
         }
         self.aboutWindowController?.showWindow(self)
         
     }
     
     // Quit the app
     @objc func quitApp() {
         NSApplication.shared.terminate(self)
     }
     
     // Display a notification using the UserNotifications framework
     func showNotification(title: String, message: String, success: Bool) {
         let content = UNMutableNotificationContent()
         content.title = title
         content.body = message
         content.sound = UNNotificationSound.default
         
         // Create a notification request and deliver it immediately
         let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
         
         UNUserNotificationCenter.current().add(request) { error in
             if let error = error {
                 print("Error delivering notification: \(error.localizedDescription)")
                 self.playSound(success: success)
             } else {
                 print("Notification delivered successfully: \(title)")
                 self.playSound(success: success)
             }
         }
     }
     
     func playSound(success: Bool){
         if success {
             DispatchQueue.main.async {
                 NSSound(named: "success.mp3")?.play()
             }
         } else {
             DispatchQueue.main.async {
                 NSSound(named: "fail.mp3")?.play()
             }
         }
     }
     
 }

 extension AppDelegate: UNUserNotificationCenterDelegate {
     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         completionHandler([.banner, .sound]) // Forces notification to show even when app is active
     }
 }
 
 */

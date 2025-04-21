//
//  AppDelegate.swift
//  MacSpaceCleaner
//
//  Created by SanketK on 3/16/25.
//

import Cocoa
import UserNotifications
import ServiceManagement

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusItem              : NSStatusItem!
    var aboutWindowController   : NSWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
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
//            button.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Clean DerivedData")
            button.image = NSImage(named: "menuIcon")
        }
        
        // Create the menu for the status item
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Clean Derived Data", action: #selector(cleanDerivedData), keyEquivalent: "C"))
        menu.addItem(NSMenuItem(title: "Clear Xcode Caches", action: #selector(clearXcodeCaches), keyEquivalent: "X"))
        menu.addItem(NSMenuItem(title: "Clear Archives", action: #selector(clearArchives), keyEquivalent: "A"))
        menu.addItem(NSMenuItem(title: "Clear iOS Device Support", action: #selector(clearIOSDeviceSupport), keyEquivalent: "I"))
        menu.addItem(NSMenuItem(title: "Clear watchOS Device Support", action: #selector(clearWatchOSDeviceSupport), keyEquivalent: "W"))
        menu.addItem(NSMenuItem(title: "Clear tvOS Device Support", action: #selector(clearTVOSDeviceSupport), keyEquivalent: "T"))
        menu.addItem(NSMenuItem(title: "Remove Old Simulators", action: #selector(removeOldSimulators), keyEquivalent: "R"))
        menu.addItem(NSMenuItem(title: "Clear Caches", action: #selector(clearCaches), keyEquivalent: "S"))
        menu.addItem(NSMenuItem(title: "Clear Cocoa Pods Cache", action: #selector(clearCocoaPodsCache), keyEquivalent: "P"))
        menu.addItem(NSMenuItem(title: "Empty Trash", action: #selector(emptyTrash), keyEquivalent: "D"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Clear All", action: #selector(clearAll), keyEquivalent: "E"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About MSC", action: #selector(about), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "Q"))
        
        self.statusItem.menu = menu
        
    }
    
    func openAppOnStartUp() {
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func cleanDerivedData() {
        // Construct the absolute path to the global DerivedData folder.
        // NSUserName() returns the current user's short name.
        let path = "/Users/\(NSUserName())/Library/Developer/Xcode/DerivedData"
        let folderName = "DerivedData"
        self.cleanFolder(at: path, folderName: folderName)
    }
    
    @objc func clearXcodeCaches() {
        // Xcode caches are typically stored in this folder:
        let path = "/Users/\(NSUserName())/Library/Developer/CoreSimulator/Caches"
        let folderName = "Xcode Caches"
        self.cleanFolder(at: path, folderName: folderName)
    }
    
    @objc func clearArchives() {
        let path = "/Users/\(NSUserName())/Library/Developer/Xcode/Archives"
        let folderName = "Xcode Archives"
        self.cleanFolder(at: path, folderName: folderName)
    }
    
    @objc func clearIOSDeviceSupport() {
        let path = "/Users/\(NSUserName())/Library/Developer/Xcode/iOS DeviceSupport"
        let folderName = "iOS Device Support"
        self.cleanFolder(at: path, folderName: folderName)
    }
    
    @objc func clearWatchOSDeviceSupport() {
        let path = "/Users/\(NSUserName())/Library/Developer/Xcode/watchOS DeviceSupport"
        let folderName = "watchOS Device Support"
        self.cleanFolder(at: path, folderName: folderName)
    }
    
    @objc func clearTVOSDeviceSupport() {
        let path = "/Users/\(NSUserName())/Library/Developer/Xcode/tvOS DeviceSupport"
        let folderName = "tvOS Device Support"
        self.cleanFolder(at: path, folderName: folderName)
    }
    
    @objc func clearCaches() {
        let path = "/Users/\(NSUserName())/Library/Caches"
        let folderName = "Caches"
        self.cleanFolder(at: path, folderName: folderName)
    }
    
    @objc func removeOldSimulators() {
        let launchPath = "/usr/bin/xcrun"
        let arguments = ["simctl", "delete", "unavailable"]
        let successTitle = "Remove Old Simulators"
        let successMessage = "Old simulators removed successfully!"
        let failureMessage = "Failed to remove old simulators"
        self.runShellCommand(launchPath: launchPath, arguments: arguments, successTitle: successTitle, successMessage: successMessage, failureMessage: failureMessage)
    }

    @objc func clearCocoaPodsCache() {
        let launchPath = "/bin/bash"
        let arguments = ["-c", "if command -v pod &> /dev/null; then pod cache clean --all; else echo 'CocoaPods not installed'; fi"]
        let successTitle = "Clear CocoaPods Cache"
        let successMessage = "CocoaPods cache cleared successfully!"
        let failureMessage = "Failed to clear CocoaPods cache"
        self.runShellCommand(launchPath: launchPath, arguments: arguments, successTitle: successTitle, successMessage: successMessage, failureMessage: failureMessage)
    }
    
    @objc func emptyTrash() {
        let launchPath = "/usr/bin/osascript"
        let arguments = ["-e", "tell application \"Finder\" to empty the trash"]
        let successTitle = "Empty Trash"
        let successMessage = "Trash emptied successfully!"
        let failureMessage = "Failed to empty trash"
        self.runShellCommand(launchPath: launchPath, arguments: arguments, successTitle: successTitle, successMessage: successMessage, failureMessage: failureMessage)
    }
    
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
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    func showNotification(title: String, message: String, success: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
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
    
    func playSound(success: Bool) {
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
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

private extension AppDelegate {

    func cleanFolder(at path: String, folderName: String) {
        let fileManager = FileManager.default
        
        guard let items = try? fileManager.contentsOfDirectory(atPath: path) else {
            self.showNotification(title: "Info", message: "\(folderName) folder not found!", success: false)
            return
        }
        
        var failedItems = [String]()
        
        let progressWindow = ProgressWindow(maxValue: Double(items.count))
        progressWindow.makeKeyAndOrderFront(nil)
        
        DispatchQueue.global(qos: .userInitiated).async { [progressWindow] in
            for (index, item) in items.enumerated() {
                let fullPath = (path as NSString).appendingPathComponent(item)
                do {
                    try fileManager.removeItem(atPath: fullPath)
                    DispatchQueue.main.async {
                        progressWindow.progress = Double(index + 1)
                    }
                } catch {
                    print("Failed to remove \(fullPath): \(error.localizedDescription)")
                    failedItems.append(item)
                }
            }
            DispatchQueue.main.async { [progressWindow] in
                progressWindow.orderOut(nil)
                if failedItems.isEmpty {
                    self.showNotification(title: "Clear \(folderName)", message: "\(folderName) cleaned successfully!", success: true)
                } else {
                    self.showNotification(title: "Clear \(folderName)", message: "Some items could not be removed: \(failedItems.joined(separator: ", "))", success: false)
                }
            }
        }
    }

    func runShellCommand(launchPath: String, arguments: [String], successTitle: String, successMessage: String, failureMessage: String) {
        let task = Process()
        task.launchPath = launchPath
        task.arguments = arguments
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        if task.terminationStatus == 0 {
            self.showNotification(title: successTitle, message: successMessage, success: true)
        } else {
            self.showNotification(title: "Error", message: "\(failureMessage): \(output)", success: false)
        }
    }
}

//
//  AppDelegate.swift
//  MacSpaceCleaner
//
//  Created by SanketK on 3/16/25.
//

import Cocoa
import Combine
import UserNotifications
import ServiceManagement

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var viewModel = AppViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var statusItem: NSStatusItem!
    
    private var storageInfoItem: NSMenuItem!
    
    private var progressWindow: ProgressWindow?
    
    private lazy var aboutWindowController: NSWindowController? = {
        let storyboard = NSStoryboard(name: "About", bundle: nil)
        guard let aboutVC = storyboard.instantiateController(withIdentifier: "AboutVC") as? AboutVC else { return nil }
        let window = NSWindow(contentViewController: aboutVC)
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.setContentSize(aboutVC.view.fittingSize)
        window.makeKeyAndOrderFront(nil)
        return NSWindowController(window: window)
    }()
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        }
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
        
        self.setupCombine()
        self.setupMenu()
    }
    
    // -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    
    func openAppOnStartUp(){
        if #available(macOS 13.0, *) {
            try? SMAppService.mainApp.register()
        } else {
            // Fallback on earlier versions
        }
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

private extension AppDelegate {
    
    func setupMenu() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.statusItem.button?.image = NSImage(named: "menuIcon")
        let menu = NSMenu()
        
        // Add storage info menu item at the top
        self.storageInfoItem = NSMenuItem(title: "Calculating available storage...", action: nil, keyEquivalent: "")
        self.storageInfoItem.isEnabled = false
        menu.addItem(self.storageInfoItem)
        menu.addItem(NSMenuItem.separator())
        
        [
            NSMenuItem(title: "Clean Derived Data",           action: #selector(cleanDerivedData),          keyEquivalent: "C"),
            NSMenuItem(title: "Clear Xcode Caches",           action: #selector(clearXcodeCaches),          keyEquivalent: "X"),
            NSMenuItem(title: "Clear Archives",               action: #selector(clearArchives),             keyEquivalent: "A"),
            NSMenuItem(title: "Clear iOS Device Support",     action: #selector(clearIOSDeviceSupport),     keyEquivalent: "I"),
            NSMenuItem(title: "Clear watchOS Device Support", action: #selector(clearWatchOSDeviceSupport), keyEquivalent: "W"),
            NSMenuItem(title: "Clear tvOS Device Support",    action: #selector(clearTVOSDeviceSupport),    keyEquivalent: "T"),
            NSMenuItem(title: "Remove Old Simulators",        action: #selector(removeOldSimulators),       keyEquivalent: "R"),
            NSMenuItem(title: "Clear Caches",                 action: #selector(clearCaches),               keyEquivalent: "S"),
            NSMenuItem(title: "Clear Cocoa Pods Cache",       action: #selector(clearCocoaPodsCache),       keyEquivalent: "P"),
            NSMenuItem(title: "Empty Trash",                  action: #selector(emptyTrash),                keyEquivalent: "D"),
            NSMenuItem.separator(),
            NSMenuItem(title: "Clear All",                    action: #selector(clearAll),                  keyEquivalent: "E"),
            NSMenuItem.separator(),
            NSMenuItem(title: "About MSC",                    action: #selector(about),                     keyEquivalent: ""),
            NSMenuItem(title: "Quit",                         action: #selector(quitApp),                   keyEquivalent: "Q")
        ].forEach({ menu.addItem($0) })
        self.statusItem.menu = menu
        
        // Update storage info immediately and then periodically
        self.updateStorageInfo()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(updateStorageInfo), userInfo: nil, repeats: true)
    }
    
    func setupCombine() {
        self.viewModel
            .notificationPublisher
            .sink(receiveValue: { [weak self] notificationData in
                let content = UNMutableNotificationContent()
                content.title = notificationData.title
                content.body = notificationData.message
                content.sound = UNNotificationSound.default
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
                UNUserNotificationCenter.current().add(request) { [weak self] error in
                    if let error {
                        print("Error delivering notification: \(error.localizedDescription)")
                        self?.playSound(success: notificationData.success)
                    } else {
                        print("Notification delivered successfully: \(notificationData.title)")
                        self?.playSound(success: notificationData.success)
                    }
                }
            })
            .store(in: &self.cancellables)
        
        self.viewModel
            .progressPublisher
            .sink(receiveValue: { progression in
                switch progression {
                case .starting(let maxValue):
                    self.progressWindow = ProgressWindow(maxValue: maxValue)
                    self.progressWindow?.makeKeyAndOrderFront(nil)
                case .progress(let value):
                    self.progressWindow?.progress = value
                case .finished:
                    self.progressWindow?.orderOut(nil)
                    self.progressWindow = nil
                }
            })
            .store(in: &self.cancellables)
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
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}

@objc private extension AppDelegate {
    
    func cleanDerivedData()          { self.viewModel.perform(action: .cleanDerivedData)          }
    func clearXcodeCaches()          { self.viewModel.perform(action: .clearXcodeCaches)          }
    func clearArchives()             { self.viewModel.perform(action: .clearArchives)             }
    func clearIOSDeviceSupport()     { self.viewModel.perform(action: .clearIOSDeviceSupport)     }
    func clearWatchOSDeviceSupport() { self.viewModel.perform(action: .clearWatchOSDeviceSupport) }
    func clearTVOSDeviceSupport()    { self.viewModel.perform(action: .clearTVOSDeviceSupport)    }
    func clearCaches()               { self.viewModel.perform(action: .clearCaches)               }
    func removeOldSimulators()       { self.viewModel.perform(action: .removeOldSimulators)       }
    func clearCocoaPodsCache()       { self.viewModel.perform(action: .clearCocoaPodsCache)       }
    func emptyTrash()                { self.viewModel.perform(action: .emptyTrash)                }
    func clearAll()                  { self.viewModel.clearAll()                                  }
    
    @objc func about() {
        self.aboutWindowController?.showWindow(self)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(self)
    }
    
    @objc func updateStorageInfo() {
        DispatchQueue.global(qos: .background).async {
            let fileURL = URL(fileURLWithPath: "/")
            do {
                let values = try fileURL.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
                if let capacity = values.volumeAvailableCapacityForImportantUsage {
                    let formatter = ByteCountFormatter()
                    formatter.allowedUnits = [.useGB]
                    formatter.countStyle = .file
                    let availableString = formatter.string(fromByteCount: Int64(capacity))
                    
                    DispatchQueue.main.async {
                        self.storageInfoItem.title = "Available Storage: \(availableString)"
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.storageInfoItem.title = "Available Storage: Unknown"
                }
            }
        }
    }
}

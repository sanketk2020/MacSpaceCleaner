//
//  AppViewModel.swift
//  MacSpaceCleaner
//
//  Created by Asaf Baibekov on 21/04/2025.
//

import Cocoa
import Combine

class AppViewModel {
    
    struct NotificationData {
        let title: String
        let message: String
        let success: Bool
    }
    
    enum Progress {
        case starting(maxValue: Double)
        case progress(value: Double)
        case finished
    }
    
    enum Action: CaseIterable {
        case cleanDerivedData
        case clearXcodeCaches
        case clearArchives
        case clearIOSDeviceSupport
        case clearWatchOSDeviceSupport
        case clearTVOSDeviceSupport
        case clearCaches
        case removeOldSimulators
        case clearCocoaPodsCache
        case emptyTrash
    }
    
    private let notificationPassthroughSubject: PassthroughSubject<NotificationData, Never>
    private let progressPassthroughSubject: PassthroughSubject<Progress, Never>
    
    let notificationPublisher: AnyPublisher<NotificationData, Never>
    let progressPublisher: AnyPublisher<Progress, Never>
    
    init() {
        self.notificationPassthroughSubject = PassthroughSubject()
        self.progressPassthroughSubject = PassthroughSubject()
        
        self.notificationPublisher = self.notificationPassthroughSubject.eraseToAnyPublisher()
        self.progressPublisher = self.progressPassthroughSubject.eraseToAnyPublisher()
    }
    
    func perform(action: Action) {
        switch action {
        case .cleanDerivedData:
            let path = "/Users/\(NSUserName())/Library/Developer/Xcode/DerivedData"
            let folderName = "DerivedData"
            self.cleanFolder(at: path, folderName: folderName)
        case .clearXcodeCaches:
            let path = "/Users/\(NSUserName())/Library/Developer/CoreSimulator/Caches"
            let folderName = "Xcode Caches"
            self.cleanFolder(at: path, folderName: folderName)
        case .clearArchives:
            let path = "/Users/\(NSUserName())/Library/Developer/Xcode/Archives"
            let folderName = "Xcode Archives"
            self.cleanFolder(at: path, folderName: folderName)
        case .clearIOSDeviceSupport:
            let path = "/Users/\(NSUserName())/Library/Developer/Xcode/iOS DeviceSupport"
            let folderName = "iOS Device Support"
            self.cleanFolder(at: path, folderName: folderName)
        case .clearWatchOSDeviceSupport:
            let path = "/Users/\(NSUserName())/Library/Developer/Xcode/watchOS DeviceSupport"
            let folderName = "watchOS Device Support"
            self.cleanFolder(at: path, folderName: folderName)
        case .clearTVOSDeviceSupport:
            let path = "/Users/\(NSUserName())/Library/Developer/Xcode/tvOS DeviceSupport"
            let folderName = "tvOS Device Support"
            self.cleanFolder(at: path, folderName: folderName)
        case .clearCaches:
            let path = "/Users/\(NSUserName())/Library/Caches"
            let folderName = "Caches"
            self.cleanFolder(at: path, folderName: folderName)
        case .removeOldSimulators:
            let launchPath = "/usr/bin/xcrun"
            let arguments = ["simctl", "delete", "unavailable"]
            let successTitle = "Remove Old Simulators"
            let successMessage = "Old simulators removed successfully!"
            let failureMessage = "Failed to remove old simulators"
            self.runShellCommand(launchPath: launchPath, arguments: arguments, successTitle: successTitle, successMessage: successMessage, failureMessage: failureMessage)
        case .clearCocoaPodsCache:
            let launchPath = "/bin/bash"
            let arguments = ["-c", "if command -v pod &> /dev/null; then pod cache clean --all; else echo 'CocoaPods not installed'; fi"]
            let successTitle = "Clear CocoaPods Cache"
            let successMessage = "CocoaPods cache cleared successfully!"
            let failureMessage = "Failed to clear CocoaPods cache"
            self.runShellCommand(launchPath: launchPath, arguments: arguments, successTitle: successTitle, successMessage: successMessage, failureMessage: failureMessage)
        case .emptyTrash:
            let launchPath = "/usr/bin/osascript"
            let arguments = ["-e", "tell application \"Finder\" to empty the trash"]
            let successTitle = "Empty Trash"
            let successMessage = "Trash emptied successfully!"
            let failureMessage = "Failed to empty trash"
            self.runShellCommand(launchPath: launchPath, arguments: arguments, successTitle: successTitle, successMessage: successMessage, failureMessage: failureMessage)
        }
    }
    
    func clearAll() {
        Action.allCases.forEach({ self.perform(action: $0) })
        self.notificationPassthroughSubject.send(.init(title: "Clear All", message: "All Xcode caches, archives, and simulators cleared successfully!", success: true))
    }
}

private extension AppViewModel {

    func cleanFolder(at path: String, folderName: String) {
        let fileManager = FileManager.default
        
        guard let items = try? fileManager.contentsOfDirectory(atPath: path) else {
            self.notificationPassthroughSubject.send(.init(title: "Info", message: "\(folderName) folder not found!", success: false))
            return
        }
        
        var failedItems = [String]()
        
        self.progressPassthroughSubject.send(.starting(maxValue: Double(items.count)))
        
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, item) in items.enumerated() {
                let fullPath = (path as NSString).appendingPathComponent(item)
                do {
                    try fileManager.removeItem(atPath: fullPath)
                    DispatchQueue.main.async {
                        self.progressPassthroughSubject.send(.progress(value: Double(index + 1)))
                    }
                } catch {
                    print("Failed to remove \(fullPath): \(error.localizedDescription)")
                    failedItems.append(item)
                }
            }
            DispatchQueue.main.async {
                self.progressPassthroughSubject.send(.finished)
                if failedItems.isEmpty {
                    self.notificationPassthroughSubject.send(.init(title: "Clear \(folderName)", message: "\(folderName) cleaned successfully!", success: true))
                } else {
                    self.notificationPassthroughSubject.send(.init(title: "Clear \(folderName)", message: "Some items could not be removed: \(failedItems.joined(separator: ", "))", success: false))
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
            self.notificationPassthroughSubject.send(.init(title: successTitle, message: successMessage, success: true))
        } else {
            self.notificationPassthroughSubject.send(.init(title: "Error", message: "\(failureMessage): \(output)", success: false))
        }
    }
}

//
//  ProgressWindow.swift
//  MacSpaceCleaner
//
//  Created by Asaf Baibekov on 21/04/2025.
//

import AppKit
import Combine

class ProgressWindow: NSWindow {

    @Published var progress: Double = 0

    private let progressIndicator: NSProgressIndicator!
    
    private var cancellables: Set<AnyCancellable>
    
    init(maxValue: Double) {
        self.cancellables = Set<AnyCancellable>()
        
        self.progressIndicator = NSProgressIndicator(frame: NSMakeRect(20, 40, 260, 20))
        self.progressIndicator.isIndeterminate = false
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = maxValue
        
        super.init(contentRect: NSMakeRect(0, 0, 300, 100), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        self.title = "Cleaning..."
        self.center()
        self.contentView?.addSubview(self.progressIndicator)
        
        self.$progress
            .assign(to: \.doubleValue, on: self.progressIndicator)
            .store(in: &self.cancellables)
    }
}

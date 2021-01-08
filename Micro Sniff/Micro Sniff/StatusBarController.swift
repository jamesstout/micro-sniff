//
//  StatusBarController.swift
//  MicMonitor
//
//  Created by phucld on 2/17/20.
//  Copyright © 2020 Dwarvesf. All rights reserved.
//

import Foundation
import Preferences
import Cocoa

class StatusBarController {
    private let menuStatusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    var window: MicroWindow? = nil

    private let mutePrefChanged = Notification.Name("mutePrefChanged")
    
    lazy var preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            GeneralPreferenceViewController(),
            AboutPreferenceViewController()
        ],
        style: .segmentedControl
    )

    
    init() {
        MicroManager.sharedInstance.regisAudioNotification()
        setupView()
        DistributedNotificationCenter.default().addObserver(self,
                                                            selector: #selector(self.setupView),
                                                            name: mutePrefChanged,
                                                            object: nil)
    }
    
    @objc public func setupView() {
        if let button = menuStatusItem.button {
            button.image = #imageLiteral(resourceName: "ico_statusbar")
        }
        menuStatusItem.menu = self.getContextMenu()

        var isMuted : Bool = false

        if let mic = AudioDevice.allInputDevices().first(where: {$0.isRunningSomewhere()}) {

            if Preference.dontShowWhenMuted {
                isMuted = isMicMuted(mic: mic)
            }

            if isMuted == false {
                createAndShowWindow(micTitle: mic.name)
            }
            else {
                self.removeWindow()
            }
        }
        
        MicroManager.sharedInstance.microDidRunningSomeWhere = {[weak self] (isRunning, title, device) in
            if isRunning {
                if Preference.dontShowWhenMuted {
                    isMuted = self!.isMicMuted(mic: device)
                }
                if isMuted == false {
                    self?.createAndShowWindow(micTitle: title)
                }
                else {
                    self?.removeWindow()
                }
            } else {
                self?.removeWindow()
            }
        }
    }

    private func isMicMuted(mic: AudioDevice) -> Bool {

        for i in 0..<mic.channels(direction: .recording) {
            log("i: (\(i)).")
            if let tmpIsMuted = mic.isMuted(channel: i, direction: .recording){
                log("isMuted: (\(tmpIsMuted)).")
                return tmpIsMuted
            }
        }

        return false
    }

    private func createAndShowWindow(micTitle: String) {
        if window == nil {
            window = MicroWindow.initForMainScreen()
        }
        
        window?.micTitle?(micTitle)
        window?.openWithAnimation()
    }
    
    private func getContextMenu() -> NSMenu {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openPreferences), keyEquivalent: "P"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        menu.item(withTitle: "Preferences...")?.target = self
        
        return menu
    }
    
    @objc private func openPreferences() {
        self.preferencesWindowController.show()
    }
    
    private func removeWindow() {
        window?.close()
    }
}

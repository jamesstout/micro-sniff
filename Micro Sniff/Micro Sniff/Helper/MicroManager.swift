//
//  MicroManager.swift
//  MicMonitor
//
//  Created by phucld on 2/17/20.
//  Copyright © 2020 Dwarvesf. All rights reserved.
//

import Foundation

class MicroManager {
    
    static let sharedInstance = MicroManager()
    private init(){}
    
    var microDidRunningSomeWhere: ((_ isRunning: Bool,_ title: String, _ device: AudioDevice) -> ())?
    

    func regisAudioNotification() {
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioHardwareEvent.self, dispatchQueue: DispatchQueue.main)
        NotificationCenter.defaultCenter.subscribe(self, eventType: AudioDeviceEvent.self, dispatchQueue: DispatchQueue.main)
    }
    
    func removeAllAudioNotification() {
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioHardwareEvent.self)
        NotificationCenter.defaultCenter.unsubscribe(self, eventType: AudioDeviceEvent.self)
    }
    
}
extension MicroManager: EventSubscriber {
    func eventReceiver(_ event: Event) {
        guard let event = event as?  AudioDeviceEvent else { return }
        
        switch event {
        
        case .isRunningSomewhereDidChange(audioDevice: let audioDevice):
            guard
                audioDevice.isInputOnlyDevice(),
                let microDidRunningSomeWhere = self.microDidRunningSomeWhere
                else {return}
            
            microDidRunningSomeWhere(audioDevice.isRunningSomewhere(), audioDevice.name, audioDevice)

            case .muteDidChange(audioDevice: let audioDevice, channel: _, direction: _):
            guard
                audioDevice.isInputOnlyDevice(),
                let microDidRunningSomeWhere = self.microDidRunningSomeWhere
                else {return}
            log("muteDidChange")

            microDidRunningSomeWhere(audioDevice.isRunningSomewhere(), audioDevice.name, audioDevice)
        default: break
        }
    }
    
    var hashValue: Int {
        return 0
    }
    
}



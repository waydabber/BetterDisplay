//
//  Dummy.swift
//  BetterDummy
//
//  Created by @waydabber
//

import Foundation
import Cocoa
import os.log

class Dummy {
    
    let number: Int
    var display: Any?
    let dummyDefinitionItem: Int
    let serialNum: UInt32
    
    init?(number: Int, dummyDefinitionItem: Int, serialNum: UInt32 = 0) {
        let displayDefinition = DummyDefinition.dummyDefinitions[dummyDefinitionItem]
        let name: String = "Dummy \(displayDefinition.description.components(separatedBy: " ").first ?? displayDefinition.description)"
        var storedSerialNum: UInt32 = serialNum
        if storedSerialNum == 0 {
            storedSerialNum = UInt32.random(in: 0...UInt32.max)
        }
        if let display = Dummy.createVirtualDisplay(displayDefinition, name: name, serialNum: storedSerialNum) {
            self.number = number
            self.display = display
            self.dummyDefinitionItem = dummyDefinitionItem
            self.serialNum = storedSerialNum
            os_log("Display %{public}@ successfully created", type: .info, "\(name)")
        } else {
            os_log("Failed to create display %{public}@", type: .info, "\(name)")
            return nil
        }
    }
    
    func getMenuItemTitle() -> String {
        return "\(DummyDefinition.dummyDefinitions[self.dummyDefinitionItem].description) - S/N: \(String(format:"%02X", self.serialNum))"
    }
    
    static func createVirtualDisplay(_ definition: DummyDefinition, name: String, serialNum: UInt32) -> CGVirtualDisplay? {
        os_log("Creating virtual display: %{public}@", type: .info, "\(name)")
        if let descriptor = CGVirtualDisplayDescriptor() {
            os_log("- Preparing descriptor...", type: .info)
            descriptor.queue = DispatchQueue.global(qos: .userInteractive)
            descriptor.name = name
            descriptor.maxPixelsWide = UInt32(definition.aspectWidth * definition.multiplierStep * definition.maxMultiplier)
            descriptor.maxPixelsHigh = UInt32(definition.aspectHeight * definition.multiplierStep * definition.maxMultiplier)
            descriptor.sizeInMillimeters = CGSize(width: 25.4 * Double(descriptor.maxPixelsWide) / 200, height: 25.4 * Double(descriptor.maxPixelsHigh) / 200)
            descriptor.serialNum = serialNum
            descriptor.productID = UInt32(min(definition.aspectWidth-1,255)*256+min(definition.aspectHeight-1,255))
            descriptor.vendorID = UInt32(0xF0F0)
            if let display = CGVirtualDisplay(descriptor: descriptor) {
                os_log("- Creating display, preparing modes...", type: .info)
                var modes = [CGVirtualDisplayMode?](repeating: nil, count: definition.maxMultiplier-definition.minMultiplier+1)
                for multiplier in definition.minMultiplier...definition.maxMultiplier  {
                    for refreshRate in definition.refreshRates {
                        modes[multiplier-definition.minMultiplier] = CGVirtualDisplayMode(width: UInt32(definition.aspectWidth * multiplier * definition.multiplierStep), height: UInt32(definition.aspectHeight * multiplier * definition.multiplierStep), refreshRate: refreshRate)!
                    }
                }
                if let settings = CGVirtualDisplaySettings() {
                    os_log("- Preparing settings for display...", type: .info)
                    settings.hiDPI = 1
                    settings.modes = modes as [Any]
                    if display.applySettings(settings) {
                        os_log("- Settings are successfully applied.", type: .info)
                        return display
                    }
                }
            }
        }
        return nil
    }
    
}

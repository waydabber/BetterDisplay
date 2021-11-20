//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import Foundation
import os.log

class Dummy: Equatable {
  var virtualDisplay: CGVirtualDisplay?
  var dummyDefinition: DummyDefinition
  let serialNum: UInt32
  var isConnected: Bool = false
  var isPortrait: Bool = false
  var isSleepDisconnected: Bool = false
  var associatedDisplayPrefsId: String = ""
  var associatedDisplayName: String = ""
  var displayIdentifier: CGDirectDisplayID = 0 // This contains valid info only if the display is connected

  static func == (lhs: Dummy, rhs: Dummy) -> Bool {
    lhs.serialNum == rhs.serialNum
  }

  init(dummyDefinition: DummyDefinition, isPortrait: Bool = false, serialNum: UInt32 = 0, doConnect: Bool = true) {
    var storedSerialNum: UInt32 = serialNum
    if storedSerialNum == 0 {
      storedSerialNum = UInt32.random(in: 0 ... UInt32.max)
    }
    self.dummyDefinition = dummyDefinition
    self.serialNum = storedSerialNum
    self.isPortrait = isPortrait
    if doConnect {
      _ = self.connect()
    }
  }

  func getName() -> String {
    "Dummy \(self.dummyDefinition.description.components(separatedBy: " ").first ?? self.dummyDefinition.description)"
  }

  func getMenuItemTitle() -> String {
    "\(self.dummyDefinition.description.components(separatedBy: " ").first ?? "") - #\(String(format: "%02X", self.serialNum))"
  }

  func getSerialNumber() -> String {
    "\(String(format: "%02X", self.serialNum))"
  }

  func connect(sleepConnect: Bool = false) -> Bool {
    guard sleepConnect && self.isSleepDisconnected || !sleepConnect else {
      return false
    }
    self.isSleepDisconnected = false
    if self.virtualDisplay != nil || self.isConnected {
      os_log("Attempted to connect the already connected display %{public}@. Interpreting as connect cycle.", type: .info, "\(self.getName())")
      self.disconnect()
    }
    let name: String = self.getName()
    if let virtualDisplay = Dummy.createVirtualDisplay(self.dummyDefinition, name: name, serialNum: self.serialNum) {
      self.virtualDisplay = virtualDisplay
      self.displayIdentifier = virtualDisplay.displayID
      self.isConnected = true
      os_log("Display %{public}@ successfully connected", type: .info, "\(name)")
      return true
    } else {
      os_log("Failed to connect display %{public}@", type: .info, "\(name)")
      return false
    }
  }

  func associateDisplay(display: Display) {
    self.associatedDisplayPrefsId = display.prefsId
    self.associatedDisplayName = display.name
  }

  func disassociateDisplay() {
    self.associatedDisplayPrefsId = ""
    self.associatedDisplayName = ""
  }

  func hasAssociatedDisplay() -> Bool {
    self.associatedDisplayPrefsId == "" ? false : true
  }

  func disconnect(sleepDisconnect: Bool = false) {
    self.virtualDisplay = nil
    self.isConnected = false
    self.isSleepDisconnected = sleepDisconnect
    os_log("Disconnected virtual display: %{public}@", type: .info, "\(self.getName())")
  }

  static func createVirtualDisplay(_ definition: DummyDefinition, name: String, serialNum: UInt32, hiDPI: Bool = true) -> CGVirtualDisplay? {
    os_log("Creating virtual display: %{public}@", type: .info, "\(name)")
    if let descriptor = CGVirtualDisplayDescriptor() {
      os_log("- Preparing descriptor...", type: .info)
      descriptor.queue = DispatchQueue.global(qos: .userInteractive)
      descriptor.name = name
      descriptor.whitePoint = CGPoint(x: 0.950, y: 1.000) // "Taken from Generic RGB Profile.icc"
      descriptor.redPrimary = CGPoint(x: 0.454, y: 0.242) // "Taken from Generic RGB Profile.icc"
      descriptor.greenPrimary = CGPoint(x: 0.353, y: 0.674) // "Taken from Generic RGB Profile.icc"
      descriptor.bluePrimary = CGPoint(x: 0.157, y: 0.084) // "Taken from Generic RGB Profile.icc"
      descriptor.maxPixelsWide = UInt32(definition.aspectWidth * definition.multiplierStep * definition.maxMultiplier)
      descriptor.maxPixelsHigh = UInt32(definition.aspectHeight * definition.multiplierStep * definition.maxMultiplier)
      // Dummy will be fixed at 24" for now
      let diagonalSizeRatio: Double = (24 * 25.4) / sqrt(Double(definition.aspectWidth * definition.aspectWidth + definition.aspectHeight * definition.aspectHeight))
      descriptor.sizeInMillimeters = CGSize(width: Double(definition.aspectWidth) * diagonalSizeRatio, height: Double(definition.aspectHeight) * diagonalSizeRatio)
      descriptor.serialNum = serialNum
      descriptor.productID = UInt32(min(definition.aspectWidth - 1, 255) * 256 + min(definition.aspectHeight - 1, 255))
      descriptor.vendorID = UInt32(0xF0F0)
      if let display = CGVirtualDisplay(descriptor: descriptor) {
        os_log("- Creating display, preparing modes...", type: .info)
        var modes = [CGVirtualDisplayMode?](repeating: nil, count: definition.maxMultiplier - definition.minMultiplier + 1)
        for multiplier in definition.minMultiplier ... definition.maxMultiplier {
          for refreshRate in definition.refreshRates {
            modes[multiplier - definition.minMultiplier] = CGVirtualDisplayMode(width: UInt32(definition.aspectWidth * multiplier * definition.multiplierStep), height: UInt32(definition.aspectHeight * multiplier * definition.multiplierStep), refreshRate: refreshRate)!
          }
        }
        if let settings = CGVirtualDisplaySettings() {
          os_log("- Preparing settings for display...", type: .info)
          settings.hiDPI = hiDPI ? 1 : 0
          settings.modes = modes as [Any]
          if display.applySettings(settings) {
            os_log("- Settings are successfully applied. Dummy Display ID is %{public}@", type: .info, String(display.displayID))
            return display
          }
        }
      }
    }
    return nil
  }
}

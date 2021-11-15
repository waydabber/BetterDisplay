//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import CoreGraphics
import os.log

class DisplayManager {
  static var displays: [Int: Display] = [:]
  static var displayCounter: Int = 0 // This is an ever increasing temporary number, does not reflect the actual number of displays.

  static func getDisplays() -> [Display] {
    var displays: [Display] = []
    for display in self.displays.values {
      displays.append(display)
    }
    return displays
  }

  static func getDisplayById(_ displayID: CGDirectDisplayID) -> Display? {
    self.displays.values.first { $0.identifier == displayID }
  }

  static func getDisplayByPrefsId(_ DisplayPrefsId: String) -> Display? {
    self.displays.values.first { $0.prefsId == DisplayPrefsId }
  }

  static func getDisplayByNumber(_ number: Int) -> Display? {
    self.displays[number]
  }

  static func getBuiltInDisplay() -> Display? {
    self.displays.values.first { CGDisplayIsBuiltin($0.identifier) != 0 }
  }

  static func addDisplay(display: Display) {
    self.displayCounter += 1
    self.displays[self.displayCounter] = display
  }

  static func clearDisplays() {
    self.displays = [:]
    self.displayCounter = 0
  }

  static func configureDisplays() {
    self.clearDisplays()
    var onlineDisplayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
    var displayCount: UInt32 = 0
    guard CGGetOnlineDisplayList(16, &onlineDisplayIDs, &displayCount) == .success else {
      os_log("Unable to get display list.", type: .info)
      return
    }
    for onlineDisplayID in onlineDisplayIDs where onlineDisplayID != 0 {
      let name = DisplayManager.getDisplayNameByID(displayID: onlineDisplayID)
      let id = onlineDisplayID
      let vendorNumber = CGDisplayVendorNumber(onlineDisplayID)
      let modelNumber = CGDisplayModelNumber(onlineDisplayID)
      let serialNumber = CGDisplaySerialNumber(onlineDisplayID)
      let isDummy: Bool = DisplayManager.isDummy(displayID: onlineDisplayID)
      let isVirtual: Bool = DisplayManager.isVirtual(displayID: onlineDisplayID)
      let display = Display(id, name: name, vendorNumber: vendorNumber, modelNumber: modelNumber, serialNumber: serialNumber, isVirtual: isVirtual, isDummy: isDummy)
      os_log("Display found -%{public}@", type: .info, "\(display.isVirtual ? " VIRTUAL" : "")\(display.isDummy ? " DUMMY" : "") id: \(display.identifier), name: \(display.name), vendor: \(display.vendorNumber ?? 0), model: \(display.modelNumber ?? 0), s/n: \(display.serialNumber ?? 0)")
      self.addDisplay(display: display)
    }
    self.addDisplayCounterSuffixes()
  }

  static func addDisplayCounterSuffixes() {
    var nameDisplays: [String: [Display]] = [:]
    for display in self.displays.values {
      if nameDisplays[display.name] != nil {
        nameDisplays[display.name]?.append(display)
      } else {
        nameDisplays[display.name] = [display]
      }
    }
    for nameDisplayKey in nameDisplays.keys where nameDisplays[nameDisplayKey]?.count ?? 0 > 1 {
      for i in 0 ... (nameDisplays[nameDisplayKey]?.count ?? 1) - 1 {
        if let display = nameDisplays[nameDisplayKey]?[i] {
          display.name = "" + display.name + " (" + String(i + 1) + ")"
        }
      }
    }
  }

  static func isDummy(displayID: CGDirectDisplayID) -> Bool {
    let rawName = DisplayManager.getDisplayNameByID(displayID: displayID)
    var isDummy: Bool = false
    if rawName.lowercased().contains("dummy"), self.isVirtual(displayID: displayID) {
      os_log("Display seems to be a BetterDummy created dummy.", type: .info)
      isDummy = true
    }
    return isDummy
  }

  static func isVirtual(displayID: CGDirectDisplayID) -> Bool {
    var isVirtual: Bool = false
    if let dictionary = ((CoreDisplay_DisplayCreateInfoDictionary(displayID))?.takeRetainedValue() as NSDictionary?) {
      let isVirtualDevice = dictionary["kCGDisplayIsVirtualDevice"] as? Bool
      let displayIsAirplay = dictionary["kCGDisplayIsAirPlay"] as? Bool
      if isVirtualDevice ?? displayIsAirplay ?? false {
        isVirtual = true
      }
    }
    return isVirtual
  }

  static func resolveEffectiveDisplayID(_ displayID: CGDirectDisplayID) -> CGDirectDisplayID {
    var realDisplayID = displayID
    if CGDisplayIsInHWMirrorSet(displayID) != 0 || CGDisplayIsInMirrorSet(displayID) != 0 {
      let mirroredDisplayID = CGDisplayMirrorsDisplay(displayID)
      if mirroredDisplayID != 0 {
        realDisplayID = mirroredDisplayID
      }
    }
    return realDisplayID
  }

  static func normalizedName(_ name: String) -> String {
    var normalizedName = name.replacingOccurrences(of: "(", with: "")
    normalizedName = normalizedName.replacingOccurrences(of: ")", with: "")
    normalizedName = normalizedName.replacingOccurrences(of: " ", with: "")
    for i in 0 ... 9 {
      normalizedName = normalizedName.replacingOccurrences(of: String(i), with: "")
    }
    return normalizedName
  }

  static func getDisplayNameByID(displayID: CGDirectDisplayID) -> String {
    let defaultName: String = "Unknown"
    if let dictionary = ((CoreDisplay_DisplayCreateInfoDictionary(displayID))?.takeRetainedValue() as NSDictionary?), let nameList = dictionary["DisplayProductName"] as? [String: String], let name = nameList["en_US"] ?? nameList.first?.value {
      return name
    }
    return defaultName
  }
}

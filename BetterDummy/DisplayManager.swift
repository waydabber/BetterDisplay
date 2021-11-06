//
//  DisplayHandler.swift
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import CoreGraphics
import os.log

class DisplayManager {
  public static let shared = DisplayManager()
  var displays: [Display] = []

  func configureDisplays() {
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
      let isDummy: Bool = DisplayManager.isDummy(displayID: onlineDisplayID)
      let isVirtual: Bool = DisplayManager.isVirtual(displayID: onlineDisplayID)
      let display = Display(id, name: name, vendorNumber: vendorNumber, modelNumber: modelNumber, isVirtual: isVirtual, isDummy: isDummy)
      os_log("Display found - %{public}@", type: .info, "ID: \(display.identifier), Name: \(display.name) (Vendor: \(display.vendorNumber ?? 0), Model: \(display.modelNumber ?? 0))")
      self.addDisplay(display: display)
    }
  }

  func normalizedName(_ name: String) -> String {
    var normalizedName = name.replacingOccurrences(of: "(", with: "")
    normalizedName = normalizedName.replacingOccurrences(of: ")", with: "")
    normalizedName = normalizedName.replacingOccurrences(of: " ", with: "")
    for i in 0 ... 9 {
      normalizedName = normalizedName.replacingOccurrences(of: String(i), with: "")
    }
    return normalizedName
  }

  func getAllDisplays() -> [Display] {
    self.displays
  }

  func getBuiltInDisplay() -> Display? {
    self.displays.first { CGDisplayIsBuiltin($0.identifier) != 0 }
  }

  func getCurrentDisplay(byFocus: Bool = false) -> Display? {
    if byFocus {
      guard let mainDisplayID = NSScreen.main?.displayID else {
        return nil
      }
      return self.displays.first { $0.identifier == mainDisplayID }
    } else {
      let mouseLocation = NSEvent.mouseLocation
      let screens = NSScreen.screens
      if let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }) {
        return self.displays.first { $0.identifier == screenWithMouse.displayID }
      }
      return nil
    }
  }

  func addDisplay(display: Display) {
    self.displays.append(display)
  }

  func clearDisplays() {
    self.displays = []
  }

  func addDisplayCounterSuffixes() {
    var nameDisplays: [String: [Display]] = [:]
    for display in self.displays {
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
    let rawName = DisplayManager.getDisplayRawNameByID(displayID: displayID)
    var isDummy: Bool = false
    if rawName.lowercased().contains("dummy") {
      os_log("NOTE: Display is a dummy!", type: .info)
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

  static func engageMirror() -> Bool {
    var onlineDisplayIDs = [CGDirectDisplayID](repeating: 0, count: 16)
    var displayCount: UInt32 = 0
    guard CGGetOnlineDisplayList(16, &onlineDisplayIDs, &displayCount) == .success, displayCount > 1 else {
      return false
    }
    // Break display mirror if there is any
    var mirrorBreak = false
    var displayConfigRef: CGDisplayConfigRef?
    for onlineDisplayID in onlineDisplayIDs where onlineDisplayID != 0 {
      if CGDisplayIsInHWMirrorSet(onlineDisplayID) != 0 || CGDisplayIsInMirrorSet(onlineDisplayID) != 0 {
        if mirrorBreak == false {
          CGBeginDisplayConfiguration(&displayConfigRef)
        }
        CGConfigureDisplayMirrorOfDisplay(displayConfigRef, onlineDisplayID, kCGNullDirectDisplay)
        mirrorBreak = true
      }
    }
    if mirrorBreak {
      CGCompleteDisplayConfiguration(displayConfigRef, CGConfigureOption.permanently)
      return true
    }
    // Build display mirror
    var mainDisplayId = kCGNullDirectDisplay
    for onlineDisplayID in onlineDisplayIDs where onlineDisplayID != 0 {
      if CGDisplayIsBuiltin(onlineDisplayID) == 0, mainDisplayId == kCGNullDirectDisplay {
        mainDisplayId = onlineDisplayID
      }
    }
    guard mainDisplayId != kCGNullDirectDisplay else {
      return false
    }
    CGBeginDisplayConfiguration(&displayConfigRef)
    for onlineDisplayID in onlineDisplayIDs where onlineDisplayID != 0 && onlineDisplayID != mainDisplayId {
      CGConfigureDisplayMirrorOfDisplay(displayConfigRef, onlineDisplayID, mainDisplayId)
    }
    CGCompleteDisplayConfiguration(displayConfigRef, CGConfigureOption.permanently)
    return true
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

  static func getByDisplayID(displayID: CGDirectDisplayID) -> NSScreen? {
    NSScreen.screens.first { $0.displayID == displayID }
  }

  static func getDisplayRawNameByID(displayID: CGDirectDisplayID) -> String {
    let defaultName: String = ""
    if let dictionary = ((CoreDisplay_DisplayCreateInfoDictionary(displayID))?.takeRetainedValue() as NSDictionary?), let nameList = dictionary["DisplayProductName"] as? [String: String], let name = nameList["en_US"] ?? nameList.first?.value {
      return name
    }
    return defaultName
  }

  static func getDisplayNameByID(displayID: CGDirectDisplayID) -> String {
    let defaultName: String = NSLocalizedString("Unknown", comment: "Unknown display name")
    if let dictionary = ((CoreDisplay_DisplayCreateInfoDictionary(displayID))?.takeRetainedValue() as NSDictionary?), let nameList = dictionary["DisplayProductName"] as? [String: String], var name = nameList[Locale.current.identifier] ?? nameList["en_US"] ?? nameList.first?.value {
      if CGDisplayIsInHWMirrorSet(displayID) != 0 || CGDisplayIsInMirrorSet(displayID) != 0 {
        let mirroredDisplayID = CGDisplayMirrorsDisplay(displayID)
        if mirroredDisplayID != 0, let dictionary = ((CoreDisplay_DisplayCreateInfoDictionary(mirroredDisplayID))?.takeRetainedValue() as NSDictionary?), let nameList = dictionary["DisplayProductName"] as? [String: String], let mirroredName = nameList[Locale.current.identifier] ?? nameList["en_US"] ?? nameList.first?.value {
          name.append(" | " + mirroredName)
        }
      }
      return name
    }
    return defaultName
  }
}

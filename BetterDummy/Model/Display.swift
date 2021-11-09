//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import Foundation
import os.log

class Display: Equatable {
  let identifier: CGDirectDisplayID
  let prefsId: String
  var name: String
  var vendorNumber: UInt32?
  var modelNumber: UInt32?
  var serialNumber: UInt32?

  struct Resolution {
    var itemNumber: Int32
    var modeNumber: UInt32
    var width: UInt32
    var height: UInt32
    var bitDepth: UInt32
    var refreshRate: UInt16
    var hiDPI: Bool
    var isActive: Bool
  }

  static func == (lhs: Display, rhs: Display) -> Bool {
    lhs.identifier == rhs.identifier
  }

  var isVirtual: Bool = false
  var isDummy: Bool = false

  init(_ identifier: CGDirectDisplayID, name: String, vendorNumber: UInt32?, modelNumber: UInt32?, serialNumber: UInt32?, isVirtual: Bool = false, isDummy: Bool = false) {
    self.identifier = identifier
    self.name = name
    self.vendorNumber = vendorNumber
    self.modelNumber = modelNumber
    self.serialNumber = serialNumber
    self.prefsId = "(" + String(name.filter { !$0.isWhitespace }) + String(vendorNumber ?? 0) + String(modelNumber ?? 0) + "@" + String(identifier) + ")"
    os_log("Display init with prefsIdentifier %{public}@", type: .info, self.prefsId)
    self.isVirtual = isVirtual
    self.isDummy = isDummy
  }

  func isBuiltIn() -> Bool {
    if CGDisplayIsBuiltin(self.identifier) != 0 {
      return true
    } else {
      return false
    }
  }

  func getResolutionList() -> [Resolution] {
    var resolutionList: [Resolution] = []
    let numberOfDisplayModes = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    let currentDisplayMode = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
    let displayModeDescription = UnsafeMutablePointer<CGSDisplayMode>.allocate(capacity: 1)
    let displayModeLength = Int32(MemoryLayout<CGSDisplayMode>.size)
    defer {
      numberOfDisplayModes.deallocate()
      currentDisplayMode.deallocate()
      displayModeDescription.deallocate()
    }
    CGSGetNumberOfDisplayModes(self.identifier, numberOfDisplayModes)
    CGSGetCurrentDisplayMode(self.identifier, currentDisplayMode)
    for i in 0 ... numberOfDisplayModes.pointee - 1 {
      CGSGetDisplayModeDescriptionOfLength(self.identifier, i, displayModeDescription, displayModeLength)
      let resolution = Resolution(
        itemNumber: i,
        modeNumber: displayModeDescription.pointee.modeNumber,
        width: displayModeDescription.pointee.width,
        height: displayModeDescription.pointee.height,
        bitDepth: displayModeDescription.pointee.depth,
        refreshRate: displayModeDescription.pointee.freq,
        hiDPI: false, // TODO: Figure this one out
        isActive: currentDisplayMode.pointee == i ? true : false
      )
      resolutionList.append(resolution)
    }
    return resolutionList
  }

  func changeResolution(resolution _: Any) {
    // MARK: Placeholder
  }

  func getCurrentResolution(resolution _: Any) {
    // MARK: Placeholder
  }
}

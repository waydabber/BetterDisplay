//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import Foundation
import os.log

class Display: Equatable {
  internal let identifier: CGDirectDisplayID
  internal let prefsId: String
  internal var name: String
  internal var vendorNumber: UInt32?
  internal var modelNumber: UInt32?

  static func == (lhs: Display, rhs: Display) -> Bool {
    lhs.identifier == rhs.identifier
  }

  var isVirtual: Bool = false
  var isDummy: Bool = false

  internal init(_ identifier: CGDirectDisplayID, name: String, vendorNumber: UInt32?, modelNumber: UInt32?, isVirtual: Bool = false, isDummy: Bool = false) {
    self.identifier = identifier
    self.name = name
    self.vendorNumber = vendorNumber
    self.modelNumber = modelNumber
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

  func getResolutionList() -> [Any] {
    // MARK: Placeholder

    []
  }

  func changeResolution(resolution _: Any) {
    // MARK: Placeholder
  }

  func getCurrentResolution(resolution _: Any) {
    // MARK: Placeholder
  }
}

//
//  BetterDummy
//
//  Created by @waydabber
//

import Foundation

class DummyManager {
  static var dummyCounter: Int = 0
  static var dummies = [Int: Dummy]()
  static var sleepTempDummy: CGVirtualDisplay?

  static let refreshRates: [Double] = [60] // [24, 25, 30, 48, 50, 60, 90, 120] -- only 60Hz seems to work in practice
  static var dummyDefinitions: [Int: DummyDefinition] = [:]

  static func processCreatedDummy(_ dummy: Dummy) {
    self.dummies[dummy.number] = dummy
    self.dummyCounter += 1
  }
  
  static func createDummy(dummyDefinition: DummyDefinition) -> Dummy? {
    // TODO: Implement create dummy and use this everywhere in the app
    return nil
  }
  
  static func destroyDummy(dummy: Dummy) {
    // TODO: Implement destroy dummy and use this everywhere in the app
  }

  static func updateDummyDefinitions() {
    self.dummyDefinitions = [
      10: DummyDefinition(16, 9, 2, self.refreshRates, "16:9 (HD/4K/5K/6K)", false),
      20: DummyDefinition(16, 10, 2, self.refreshRates, "16:10 (W*XGA)", false),
      30: DummyDefinition(16, 12, 2, self.refreshRates, "4:3 (VGA, iPad)", false),
      40: DummyDefinition(256, 135, 2, self.refreshRates, "17:9 (4K-DCI)", true),
      50: DummyDefinition(64, 27, 2, self.refreshRates, "21.3:9 (UW-HD/4K/5K)", false),
      60: DummyDefinition(43, 18, 2, self.refreshRates, "21.5:9 (UW-QHD)", false),
      70: DummyDefinition(24, 10, 1, self.refreshRates, "24:10 (UW-QHD+)", false),
      80: DummyDefinition(32, 10, 1, self.refreshRates, "32:10 (D-W*XGA)", false),
      90: DummyDefinition(32, 9, 2, self.refreshRates, "32:9 (D-HD/QHD)", true),
      100: DummyDefinition(20, 20, 2, self.refreshRates, "1:1 (Square)", false),
      110: DummyDefinition(9, 16, 2, self.refreshRates, "9:16 (HD/4K/5K/6K - Portrait)", false),
      120: DummyDefinition(10, 16, 2, self.refreshRates, "10:16 (W*XGA - Portrait)", false),
      130: DummyDefinition(12, 16, 2, self.refreshRates, "12:16 (VGA - Portrait)", false),
      140: DummyDefinition(135, 256, 2, self.refreshRates, "9:17 (4K-DCI - Portrait)", true),
      210: DummyDefinition(15, 10, 2, self.refreshRates, "3:2 (Photography)", false),
      220: DummyDefinition(15, 12, 2, self.refreshRates, "5:4 (Photography)", true),
      350: DummyDefinition(152, 100, 1, self.refreshRates, "15.2:10 (iPad Mini 2021)", false),
      360: DummyDefinition(66, 41, 2, self.refreshRates, "23:16 (iPad Air 2020)", false),
      370: DummyDefinition(199, 139, 2, self.refreshRates, "14.3:10 (iPad Pro 11\")", false),
    ]
  }
}

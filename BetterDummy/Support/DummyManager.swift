//
//  BetterDummy
//
//  Created by @waydabber
//

import Foundation

class DummyManager {
  struct DefinedDummy {
    var dummy: Dummy
    var definitionId: Int?
  }

  static var definedDummies: [Int: DefinedDummy] = [:]
  static var dummyCounter: Int = 0 // This is an ever increasing temporary number, does not reflect the actual number of dummies.
  static var sleepTempVirtualDisplay: CGVirtualDisplay?
  static var dummyDefinitions: [Int: DummyDefinition] = [:]

  static func createDummyByDefinitionId(_ dummyDefinitionId: Int, serialNum: UInt32 = 0, doConnect: Bool = true) -> Int? {
    if let dummyDefinition = self.dummyDefinitions[dummyDefinitionId] {
      return self.createDummy(dummyDefinition, dummyDefinitionId: dummyDefinitionId, serialNum: serialNum, doConnect: doConnect)
    }
    return nil
  }

  static func createDummy(_ dummyDefinition: DummyDefinition, dummyDefinitionId: Int? = nil, serialNum: UInt32 = 0, doConnect: Bool = true) -> Int {
    let dummy = Dummy(dummyDefinition: dummyDefinition, serialNum: serialNum, doConnect: doConnect)
    self.dummyCounter += 1
    self.definedDummies[self.dummyCounter] = DefinedDummy(dummy: dummy, definitionId: dummyDefinitionId)
    return self.dummyCounter
  }

  static func getDummies() -> [Dummy] {
    var dummies: [Dummy] = []
    for definedDummy in self.definedDummies.values {
      dummies.append(definedDummy.dummy)
    }
    return dummies
  }

  static func discardDummyByNumber(_ number: Int) {
    self.definedDummies[number] = nil
  }

  static func discardAllDummies() {
    self.definedDummies = [:]
    self.dummyCounter = 0
  }

  static func getDummyByNumber(_ number: Int) -> Dummy? {
    self.definedDummies[number]?.dummy
  }

  static func getDefinitionIdByNumber(_ number: Int) -> Int? {
    self.definedDummies[number]?.definitionId
  }

  static func getNumOfDummies() -> Int {
    self.definedDummies.count
  }

  static func updateDummyDefinitions() {
    let refreshRates: [Double] = [60] // [24, 25, 30, 48, 50, 60, 90, 120] -- only 60Hz seems to be useful in practice
    self.dummyDefinitions = [
      10: DummyDefinition(16, 9, 2, refreshRates, "16:9 (HD/4K/5K/6K)", false),
      20: DummyDefinition(16, 10, 2, refreshRates, "16:10 (W*XGA)", false),
      30: DummyDefinition(16, 12, 2, refreshRates, "4:3 (VGA, iPad)", false),
      40: DummyDefinition(256, 135, 2, refreshRates, "17:9 (4K-DCI)", true),
      50: DummyDefinition(64, 27, 2, refreshRates, "21.3:9 (UW-HD/4K/5K)", false),
      60: DummyDefinition(43, 18, 2, refreshRates, "21.5:9 (UW-QHD)", false),
      70: DummyDefinition(24, 10, 1, refreshRates, "24:10 (UW-QHD+)", false),
      80: DummyDefinition(32, 10, 1, refreshRates, "32:10 (D-W*XGA)", false),
      90: DummyDefinition(32, 9, 2, refreshRates, "32:9 (D-HD/QHD)", true),
      100: DummyDefinition(20, 20, 2, refreshRates, "1:1 (Square)", false),
      110: DummyDefinition(9, 16, 2, refreshRates, "9:16 (HD/4K/5K/6K - Portrait)", false),
      120: DummyDefinition(10, 16, 2, refreshRates, "10:16 (W*XGA - Portrait)", false),
      130: DummyDefinition(12, 16, 2, refreshRates, "12:16 (VGA - Portrait)", false),
      140: DummyDefinition(135, 256, 2, refreshRates, "9:17 (4K-DCI - Portrait)", true),
      210: DummyDefinition(15, 10, 2, refreshRates, "3:2 (Photography)", false),
      220: DummyDefinition(15, 12, 2, refreshRates, "5:4 (Photography)", true),
      350: DummyDefinition(152, 100, 1, refreshRates, "15.2:10 (iPad Mini 2021)", false),
      360: DummyDefinition(66, 41, 2, refreshRates, "23:16 (iPad Air 2020)", false),
      370: DummyDefinition(199, 139, 2, refreshRates, "14.3:10 (iPad Pro 11\")", false),
    ]
  }
}

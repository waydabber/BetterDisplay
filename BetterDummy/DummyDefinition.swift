//
//  DummyDefinition.swift
//  BetterDummy
//
//  Created by @waydabber
//

class DummyDefinition {
  let aspectWidth, aspectHeight, multiplierStep, minMultiplier, maxMultiplier: Int
  let refreshRates: [Double]
  let description: String
  let addSeparatorAfter: Bool

  static let refreshRates: [Double] = [60] // [24, 25, 30, 48, 50, 60, 90, 120] -- only 60Hz seems to work in practice
  static let dummyDefinitions: [Int: DummyDefinition] = [
    10: DummyDefinition(16, 9, 2, DummyDefinition.refreshRates, "16:9 (HD/4K/5K/6K)", false),
    20: DummyDefinition(16, 10, 2, DummyDefinition.refreshRates, "16:10 (W*XGA)", false),
    30: DummyDefinition(16, 12, 2, DummyDefinition.refreshRates, "4:3 (VGA, iPad)", false),
    40: DummyDefinition(256, 135, 2, DummyDefinition.refreshRates, "17:9 (4K-DCI)", true),
    50: DummyDefinition(64, 27, 2, DummyDefinition.refreshRates, "21.3:9 (UW-HD/4K/5K)", false),
    60: DummyDefinition(43, 18, 2, DummyDefinition.refreshRates, "21.5:9 (UW-QHD)", false),
    70: DummyDefinition(24, 10, 1, DummyDefinition.refreshRates, "24:10 (UW-QHD+)", false),
    80: DummyDefinition(32, 10, 1, DummyDefinition.refreshRates, "32:10 (D-W*XGA)", false),
    90: DummyDefinition(32, 9, 2, DummyDefinition.refreshRates, "32:9 (D-HD/QHD)", true),
    100: DummyDefinition(20, 20, 2, DummyDefinition.refreshRates, "1:1 (Square)", false),
    110: DummyDefinition(9, 16, 2, DummyDefinition.refreshRates, "9:16 (HD/4K/5K/6K - Portrait)", false),
    120: DummyDefinition(10, 16, 2, DummyDefinition.refreshRates, "10:16 (W*XGA - Portrait)", false),
    130: DummyDefinition(12, 16, 2, DummyDefinition.refreshRates, "12:16 (VGA - Portrait)", false),
    140: DummyDefinition(135, 256, 2, DummyDefinition.refreshRates, "9:17 (4K-DCI - Portrait)", true),
    210: DummyDefinition(15, 10, 2, DummyDefinition.refreshRates, "3:2 (Photography)", false),
    220: DummyDefinition(15, 12, 2, DummyDefinition.refreshRates, "5:4 (Photography)", true),
    350: DummyDefinition(152, 100, 1, DummyDefinition.refreshRates, "15.2:10 (iPad Mini 2021)", false),
    360: DummyDefinition(66, 41, 2, DummyDefinition.refreshRates, "23:16 (iPad Air 2020)", false),
    370: DummyDefinition(199, 139, 2, DummyDefinition.refreshRates, "14.3:10 (iPad Pro 11\")", false),
  ]

  convenience init(_ aspectWidth: Int, _ aspectHeight: Int, _ step: Int, _ refreshRates: [Double], _ description: String, _ addSeparatorAfter: Bool = false) {
    let minX: Int = 720
    let minY: Int = 720
    let maxX: Int = 8192
    let maxY: Int = 8192
    let minMultiplier = max(Int(ceil(Float(minX) / (Float(aspectWidth) * Float(step)))), Int(ceil(Float(minY) / (Float(aspectHeight) * Float(step)))))
    let maxMultiplier = min(Int(floor(Float(maxX) / (Float(aspectWidth) * Float(step)))), Int(floor(Float(maxY) / (Float(aspectHeight) * Float(step)))))
    self.init(aspectWidth, aspectHeight, minMultiplier, maxMultiplier, step, refreshRates, description, addSeparatorAfter)
  }

  init(_ aspectWidth: Int, _ aspectHeight: Int, _ minMultiplier: Int, _ maxMultiplier: Int, _ step: Int, _ refreshRates: [Double], _ description: String, _ addSeparatorAfter: Bool = false) {
    self.aspectWidth = aspectWidth
    self.aspectHeight = aspectHeight
    self.minMultiplier = minMultiplier
    self.maxMultiplier = maxMultiplier
    self.multiplierStep = step
    self.refreshRates = refreshRates
    self.description = description
    self.addSeparatorAfter = addSeparatorAfter
  }
}

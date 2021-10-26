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
    
    static let dummyDefinitions: [DummyDefinition] = [
        DummyDefinition( 16,   9, 25, 94, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:9 (HD/4K/5K/6K)"),
        DummyDefinition( 16,  10, 20, 84, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:10 (W*XGA)"),
        DummyDefinition( 16,  12, 24, 70, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:12 (VGA)"),
        DummyDefinition(256, 135,  6, 23, 1, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "17:9 (4K-DCI)"),
        DummyDefinition( 64,  27, 16, 47, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "21.3:9 (UW-HD/4K/5K)"),
        DummyDefinition( 43,  18, 24, 69, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "21.5:9 (UW-QHD)"),
        DummyDefinition( 24,  10, 20, 62, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "24:10 (UW-QHD+)"),
        DummyDefinition( 32,  10, 40, 94, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "32:10 (D-W*XGA)"),
        DummyDefinition( 32,   9, 40, 94, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "32:9 (D-HD/QHD)"),
        DummyDefinition( 20,  20, 19, 42, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "1:1 (Square)"),
        DummyDefinition(  9,  16, 25, 94, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "9:16 (HD/4K/5K/6K - Rotated)"),
        DummyDefinition( 10,  16, 20, 84, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "10:16 (W*XGA - Rotated)"),
        DummyDefinition( 12,  16, 24, 70, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "12:16 (VGA - Rotated)"),
        DummyDefinition(135, 256,  6, 23, 1, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "9:17 (4K-DCI - Rotated)"),
        DummyDefinition( 20,  25, 31, 84, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "10:12.5 (SXGA - Rotated)")
    ]
    
    init(_ aspectWidth: Int, _ aspectHeight: Int, _ minMultiplier: Int, _ maxMultiplier: Int, _ step: Int, _ refreshRates: [Double], _ description: String) {
        self.aspectWidth = aspectWidth
        self.aspectHeight = aspectHeight
        self.minMultiplier = minMultiplier
        self.maxMultiplier = maxMultiplier
        self.multiplierStep = step
        self.refreshRates = refreshRates
        self.description = description
    }
        
}

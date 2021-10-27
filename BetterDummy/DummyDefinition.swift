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
        DummyDefinition( 16,   9, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:9 (HD/4K/5K/6K)"),
        DummyDefinition( 16,  10, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:10 (W*XGA)"),
        DummyDefinition( 16,  12, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:12 (VGA)"),
        DummyDefinition(256, 135, 1, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "17:9 (4K-DCI)"),
        DummyDefinition( 64,  27, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "21.3:9 (UW-HD/4K/5K)"),
        DummyDefinition( 43,  18, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "21.5:9 (UW-QHD)"),
        DummyDefinition( 24,  10, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "24:10 (UW-QHD+)"),
        DummyDefinition( 32,  10, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "32:10 (D-W*XGA)"),
        DummyDefinition( 32,   9, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "32:9 (D-HD/QHD)"),
        DummyDefinition( 20,  20, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "1:1 (Square)"),
        DummyDefinition(  9,  16, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "9:16 (HD/4K/5K/6K - Portrait)"),
        DummyDefinition( 10,  16, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "10:16 (W*XGA - Portrait)"),
        DummyDefinition( 12,  16, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "12:16 (VGA - Portrait)"),
        DummyDefinition(135, 256, 1, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "9:17 (4K-DCI - Portrait)"),
    ]
    
    convenience init(_ aspectWidth: Int, _ aspectHeight: Int, _ step: Int, _ refreshRates: [Double], _ description: String) {
        let minX: Int = 1280
        let minY: Int = 720
        let maxX: Int = 8192
        let maxY: Int = 8192
        let minMultiplier = max(Int(ceil(Float(minX)/(Float(aspectWidth)*Float(step)))), Int(ceil(Float(minY)/(Float(aspectHeight)*Float(step)))))
        let maxMultiplier = min(Int(floor(Float(maxX)/(Float(aspectWidth)*Float(step)))), Int(floor(Float(maxY)/(Float(aspectHeight)*Float(step)))))
        self.init(aspectWidth, aspectHeight, minMultiplier, maxMultiplier, step, refreshRates, description)
    }
    
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

//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa

class BetterSlider: NSSlider {
  class BetterSliderCell: NSSliderCell {
    let knobFillColor = NSColor(white: 1, alpha: 1)
    let knobFillColorTracking = NSColor(white: 0.8, alpha: 1)
    let knobStrokeColor = NSColor.systemGray.withAlphaComponent(0.5)
    let knobShadowColor = NSColor(white: 0, alpha: 0.03)
    let barFillColor = NSColor.systemGray.withAlphaComponent(0.2)
    let barStrokeColor = NSColor.systemGray.withAlphaComponent(0.5)
    let barFilledFillColor = NSColor(white: 1, alpha: 1)
    let tickMarkColor = NSColor.systemGray.withAlphaComponent(0.5)

    let inset: CGFloat = 3.5
    let offsetX: CGFloat = -1.5
    let offsetY: CGFloat = -1.5

    let tickMarkKnobExtraInset: CGFloat = 4
    let tickMarkKnobExtraRadiusMultiplier: CGFloat = 0.25

    var numOfTickmarks: Int = 0

    var isTracking: Bool = false

    required init(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }

    override init() {
      super.init()
    }

    override func barRect(flipped: Bool) -> NSRect {
      let bar = super.barRect(flipped: flipped)
      let knob = super.knobRect(flipped: flipped)
      return NSRect(x: bar.origin.x, y: knob.origin.y, width: bar.width, height: knob.height).insetBy(dx: 0, dy: self.inset).offsetBy(dx: self.offsetX, dy: self.offsetY)
    }

    override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
      self.isTracking = true
      return super.startTracking(at: startPoint, in: controlView)
    }

    override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
      self.isTracking = false
      return super.stopTracking(last: lastPoint, current: stopPoint, in: controlView, mouseIsUp: flag)
    }

    override func drawKnob(_: NSRect) {}

    override func drawBar(inside aRect: NSRect, flipped _: Bool) {
      let value = Float((Double(self.floatValue) - self.minValue) / (self.maxValue - self.minValue))

      let barRadius = aRect.height * 0.5 * (self.numOfTickmarks == 0 ? 1 : self.tickMarkKnobExtraRadiusMultiplier)
      let bar = NSBezierPath(roundedRect: aRect, xRadius: barRadius, yRadius: barRadius)
      self.barFillColor.setFill()
      bar.fill()

      let barFilledWidth = (aRect.width - aRect.height) * CGFloat(value) + aRect.height
      let barFilledRect = NSRect(x: aRect.origin.x, y: aRect.origin.y, width: barFilledWidth, height: aRect.height)
      let barFilled = NSBezierPath(roundedRect: barFilledRect, xRadius: barRadius, yRadius: barRadius)
      self.barFilledFillColor.setFill()
      barFilled.fill()

      let knobMinX = aRect.origin.x + (aRect.width - aRect.height) * CGFloat(value)
      let knobMaxX = aRect.origin.x + (aRect.width - aRect.height) * CGFloat(value)
      let knobRect = NSRect(x: knobMinX + (self.numOfTickmarks == 0 ? CGFloat(0) : self.tickMarkKnobExtraInset), y: aRect.origin.y, width: aRect.height + CGFloat(knobMaxX - knobMinX), height: aRect.height).insetBy(dx: self.numOfTickmarks == 0 ? CGFloat(0) : self.tickMarkKnobExtraInset, dy: 0)
      let knobRadius = knobRect.height * 0.5 * (self.numOfTickmarks == 0 ? 1 : self.tickMarkKnobExtraRadiusMultiplier)

      if self.numOfTickmarks > 0 {
        for i in 1 ... self.numOfTickmarks - 2 {
          let currentMarkLocation = CGFloat((Float(1) / Float(self.numOfTickmarks - 1)) * Float(i))
          let tickMarkBounds = NSRect(x: aRect.origin.x + aRect.height + self.tickMarkKnobExtraInset - knobRect.height + self.tickMarkKnobExtraInset * 2 + CGFloat(Float((aRect.width - self.tickMarkKnobExtraInset * 5) * currentMarkLocation)), y: aRect.origin.y + aRect.height * (1 / 3), width: 4, height: aRect.height / 3)
          let tickmark = NSBezierPath(roundedRect: tickMarkBounds, xRadius: 1, yRadius: 1)
          self.tickMarkColor.setFill()
          tickmark.fill()
        }
      }

      let knobAlpha = CGFloat(max(0, min(1, (value - 0.08) * 5)))
      for i in 1 ... 3 {
        let knobShadow = NSBezierPath(roundedRect: knobRect.offsetBy(dx: CGFloat(-1 * 2 * i), dy: 0), xRadius: knobRadius, yRadius: knobRadius)
        self.knobShadowColor.withAlphaComponent(self.knobShadowColor.alphaComponent * knobAlpha).setFill()
        knobShadow.fill()
      }

      let knob = NSBezierPath(roundedRect: knobRect, xRadius: knobRadius, yRadius: knobRadius)
      (self.isTracking ? self.knobFillColorTracking : self.knobFillColor).withAlphaComponent(knobAlpha).setFill()
      knob.fill()

      self.knobStrokeColor.withAlphaComponent(self.knobStrokeColor.alphaComponent * knobAlpha).setStroke()
      knob.stroke()
      self.barStrokeColor.setStroke()
      bar.stroke()
    }
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    self.cell = BetterSliderCell()
  }

  func setNumOfCustomTickmarks(_ numOfCustomTickmarks: Int) {
    if let cell = self.cell as? BetterSliderCell {
      cell.numOfTickmarks = numOfCustomTickmarks
    }
  }

  override func scrollWheel(with event: NSEvent) {
    guard self.isEnabled else { return }
    let range = Float(self.maxValue - self.minValue)
    var delta = Float(0)
    if self.isVertical, self.sliderType == .linear {
      delta = Float(event.deltaY)
    } else if self.userInterfaceLayoutDirection == .rightToLeft {
      delta = Float(event.deltaY + event.deltaX)
    } else {
      delta = Float(event.deltaY - event.deltaX)
    }
    if event.isDirectionInvertedFromDevice {
      delta *= -1
    }
    let increment = range * delta / 100
    let value = self.floatValue + increment
    self.floatValue = value
    self.sendAction(self.action, to: self.target)
  }
}

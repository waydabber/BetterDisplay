//
//  BetterDummy
//
//  Created by @waydabber
//

// TODO: This is a work in progress...

import Cocoa
import os.log

class SliderHandler {
  var slider: BDSlider?
  var view: NSView?
  var resolutionBox: NSTextField?
  var display: Display?
  var value: Float = 0
  var title: String
  var icon: ClickThroughImageView?

  class BDSliderCell: NSSliderCell {
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

    override func drawKnob(_: NSRect) {
      // This is intentionally empty as the knob is inside the bar. Please leave it like this!
    }

    override func drawBar(inside aRect: NSRect, flipped _: Bool) {
      let value: Float = self.floatValue

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

  class BDSlider: NSSlider {
    required init?(coder: NSCoder) {
      super.init(coder: coder)
    }

    override init(frame frameRect: NSRect) {
      super.init(frame: frameRect)
      self.cell = BDSliderCell()
    }

    func setNumOfCustomTickmarks(_ numOfCustomTickmarks: Int) {
      if let cell = self.cell as? BDSliderCell {
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

  class ClickThroughImageView: NSImageView {
    override func hitTest(_ point: NSPoint) -> NSView? {
      subviews.first { subview in subview.hitTest(point) != nil
      }
    }
  }

  public init(display: Display?, title: String = "", position _: Int = 0) {
    self.title = title
    self.display = display
    let slider = SliderHandler.BDSlider(value: 0, minValue: 0, maxValue: 1, target: self, action: #selector(SliderHandler.valueChanged))
    let showResolution = prefs.bool(forKey: PrefKey.enableSliderResolution.rawValue)
    slider.isEnabled = true
    slider.setNumOfCustomTickmarks(prefs.bool(forKey: PrefKey.showTickMarks.rawValue) ? 5 : 0)
    self.slider = slider
    slider.frame.size.width = 180
    slider.frame.origin = NSPoint(x: 15, y: 5)
    let view = NSView(frame: NSRect(x: 0, y: 0, width: slider.frame.width + 30 + (showResolution ? 38 : 0), height: slider.frame.height + 14))
    view.frame.origin = NSPoint(x: 12, y: 0)
    let iconName: String = "circle.dashed" // TODO: Find proper icon
    let icon = SliderHandler.ClickThroughImageView()
    icon.image = NSImage(systemSymbolName: iconName, accessibilityDescription: title)
    icon.contentTintColor = NSColor.black.withAlphaComponent(0.6)
    icon.frame = NSRect(x: view.frame.origin.x + 6.5, y: view.frame.origin.y + 13, width: 15, height: 15)
    icon.imageAlignment = .alignCenter
    view.addSubview(slider)
    view.addSubview(icon)
    self.icon = icon
    if showResolution {
      let percentageBox = NSTextField(frame: NSRect(x: 15 + slider.frame.size.width - 2, y: 17, width: 40, height: 12))
      self.setupResolutionBox(percentageBox)
      self.resolutionBox = percentageBox
      view.addSubview(percentageBox)
    }
    self.view = view
    slider.maxValue = 1
  }

  func setupResolutionBox(_ resolutionBox: NSTextField) {
    resolutionBox.font = NSFont.systemFont(ofSize: 12)
    resolutionBox.isEditable = false
    resolutionBox.isBordered = false
    resolutionBox.drawsBackground = false
    resolutionBox.alignment = .right
    resolutionBox.alphaValue = 0.7
  }

  @objc func valueChanged(slider: BDSlider) {
    guard !app.isSleep, app.reconfigureID == 0 else {
      return
    }
    var value = slider.floatValue
    if prefs.bool(forKey: PrefKey.enableSliderSnap.rawValue) {
      let intPercent = Int(value * 100)
      let snapInterval = 25
      let snapThreshold = 3
      let closest = (intPercent + snapInterval / 2) / snapInterval * snapInterval
      if abs(closest - intPercent) <= snapThreshold {
        value = Float(closest) / 100
        slider.floatValue = value
      }
    }
    if self.resolutionBox == self.resolutionBox {
      self.resolutionBox?.stringValue = "\(Int(value))" // TODO: This is not right
    }
    // TODO: What to do with the new value?
  }

  func setValue(_ value: Float) {
    if let slider = self.slider {
      self.value = value
      slider.floatValue = value
      if self.resolutionBox == self.resolutionBox {
        self.resolutionBox?.stringValue = "\(Int(value))" // TODO: This is not right
      }
    }
  }
}

//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import os.log

class ResolutionSliderHandler {
  var slider: BetterSlider?
  var view: NSView?
  var resolutionBox: NSTextField?
  var value: Int = 0
  var title: String
  var icon: ClickThroughImageView?
  var display: Display
  var acceptedResolutions: [Int: (Int, Display.Resolution)] = [:]
  var minValue, maxValue: Int

  class ClickThroughImageView: NSImageView {
    override func hitTest(_ point: NSPoint) -> NSView? {
      subviews.first { subview in subview.hitTest(point) != nil
      }
    }
  }

  public init(display: Display) {
    self.title = "Resolution"
    self.display = display
    let resolutions = display.resolutions
    var index = 0
    var currentResolutionIndex = 0
    var previousWidth: UInt32 = 0
    for resolution in resolutions.sorted(by: { $0.0 < $1.0 }) where resolution.value.height >= 720 && resolution.value.hiDPI == true && resolution.value.width > previousWidth {
      self.acceptedResolutions[index] = (resolution.key, resolution.value)
      previousWidth = resolution.value.width
      if resolution.value.isActive {
        currentResolutionIndex = index
      }
      index += 1
    }
    self.minValue = 0
    self.maxValue = index
    let slider = BetterSlider(value: 0, minValue: 0, maxValue: Double(index), target: self, action: #selector(ResolutionSliderHandler.valueChanged))
    slider.isEnabled = true
    slider.setNumOfCustomTickmarks(prefs.bool(forKey: PrefKey.showTickMarks.rawValue) ? 5 : 0)
    self.slider = slider
    slider.frame.size.width = 186
    slider.frame.origin = NSPoint(x: 14, y: 20)
    let view = NSView(frame: NSRect(x: 0, y: 0, width: slider.frame.width + 24, height: slider.frame.height + 14 + 12 /* ResolutionBox */ ))
    view.frame.origin = NSPoint(x: 12, y: 13)
    let iconName: String = "rectangle.stack"
    let icon = ResolutionSliderHandler.ClickThroughImageView()
    icon.rotate(byDegrees: 180)
    icon.image = NSImage(systemSymbolName: iconName, accessibilityDescription: self.title)
    icon.contentTintColor = NSColor.black.withAlphaComponent(0.6)
    icon.frame = NSRect(x: view.frame.origin.x + 5, y: view.frame.origin.y + 14, width: 15, height: 15)
    icon.imageAlignment = .alignCenter
    view.addSubview(slider)
    view.addSubview(icon)
    self.icon = icon
    let resolutionBox = NSTextField(frame: NSRect(x: 12, y: 7, width: 180, height: 12))
    self.setupResolutionBox(resolutionBox)
    self.resolutionBox = resolutionBox
    view.addSubview(resolutionBox)
    self.view = view
    self.setValue(currentResolutionIndex)
  }

  func setupResolutionBox(_ resolutionBox: NSTextField) {
    resolutionBox.font = NSFont.systemFont(ofSize: 12)
    resolutionBox.isEditable = false
    resolutionBox.isBordered = false
    resolutionBox.drawsBackground = false
    resolutionBox.alignment = .left
    resolutionBox.alphaValue = 0.7
  }

  @objc func valueChanged(slider: BetterSlider) {
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
    self.value = Int(value)
    if let (resolutionKey, resolution) = self.acceptedResolutions[self.value] {
      self.resolutionBox?.stringValue = "Resolution: \(resolution.width)x\(resolution.height)"
      let event = NSApplication.shared.currentEvent
      if event?.type == NSEvent.EventType.leftMouseUp || event?.type == NSEvent.EventType.rightMouseUp {
        app.menu.appMenu.cancelTrackingWithoutAnimation()
        self.display.changeResolution(resolutionItemNumber: Int32(resolutionKey))
      }
    }
  }

  func setValue(_ value: Int) {
    if let slider = self.slider {
      self.value = value
      slider.integerValue = value
      if let (_, resolution) = self.acceptedResolutions[Int(value)] {
        self.resolutionBox?.stringValue = "Resolution: \(resolution.width)x\(resolution.height)"
      }
    }
  }
}

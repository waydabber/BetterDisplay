//
//  BetterDummy
//
//  Created by @waydabber
//

import AppKit
import os.log
import ServiceManagement

class AppMenu {
  var statusBarItem: NSStatusItem!

  let appMenu = NSMenu()
  let newMenu = NSMenu()
  let settingsMenu = NSMenu()

  func setupMenu() {
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: "status")
    }
    self.statusBarItem.menu = self.appMenu
    self.statusBarItem.isVisible = !prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue)
    self.populateNewMenu()
    self.populateSettingsMenu()
    self.populateAppMenu()
  }

  func emptyMenu(_ menuToEmpty: NSMenu) {
    var items: [NSMenuItem] = []
    for i in 0 ..< menuToEmpty.items.count {
      items.append(menuToEmpty.items[i])
    }
    for item in items {
      menuToEmpty.removeItem(item)
    }
  }

  func populateAppMenu() {
    self.emptyMenu(self.appMenu)
    var first = true
    for key in DummyManager.definedDummies.keys.sorted(by: <) {
      if let dummy = DummyManager.getDummyByNumber(key) {
        if !first {
          self.appMenu.addItem(NSMenuItem.separator())
        }
        self.addDummyToMenu(dummy, key)
        first = false
      }
    }
    if DummyManager.dummyCounter >= 1 {
      self.appMenu.addItem(NSMenuItem.separator())
    }

    let newSubmenu = NSMenuItem(title: "Create new dummy", action: nil, keyEquivalent: "")
    newSubmenu.submenu = self.newMenu
    self.appMenu.addItem(newSubmenu)

    self.addManageMenu()

    self.appMenu.addItem(NSMenuItem.separator())

    let settingsSubmenu = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
    settingsSubmenu.submenu = self.settingsMenu
    self.appMenu.addItem(settingsSubmenu)
    let updateItem = NSMenuItem(title: "Check for updates...", action: #selector(app.updaterController.checkForUpdates(_:)), keyEquivalent: "")
    updateItem.target = app.updaterController
    self.appMenu.addItem(updateItem)
    self.appMenu.addItem(NSMenuItem(title: "Please donate!", action: #selector(app.donate(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
  }

  func populateSettingsMenu() {
    self.emptyMenu(self.settingsMenu)

    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: app.getStartAtLogin(), label: "Start at login", selector: #selector(app.startAtLogin)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.SUEnableAutomaticChecks.rawValue), label: "Automatically check for updates", selector: #selector(app.SUEnableAutomaticChecks)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue), label: "Hide menu icon", selector: #selector(app.hideMenuIcon)))

    // ---
    self.settingsMenu.addItem(NSMenuItem.separator())

    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.enable16K.rawValue), label: "Enable up to 16K resolutions", selector: #selector(app.enable16K)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.useMenuForResolution.rawValue), label: "Use resolution submenu instad of slider", selector: #selector(app.useMenuForResolution)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.hideLowResolutionOption.rawValue), label: "Show low resolution (non-HiDPI) option", selector: #selector(app.hideLowResolutionOption)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.hidePortraitOption.rawValue), label: "Show portrait mode setting", selector: #selector(app.hidePortraitOption)))

    // ---
    self.settingsMenu.addItem(NSMenuItem.separator())

    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.disableTempSleep.rawValue), label: "Use mirrored dummy sleep workaround", selector: #selector(app.disableTempSleep)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.reconnectAfterSleep.rawValue), label: "Disconnect and reconnect on sleep", selector: #selector(app.reconnectAfterSleep)))

    // ---

    self.settingsMenu.addItem(NSMenuItem.separator())
    self.settingsMenu.addItem(NSMenuItem(title: "About BetterDummy", action: #selector(app.about(_:)), keyEquivalent: ""))
    self.settingsMenu.addItem(NSMenuItem(title: "Reset BetterDummy", action: #selector(app.reset(_:)), keyEquivalent: ""))
  }

  func populateNewMenu() {
    self.emptyMenu(self.newMenu)
    for key in DummyManager.dummyDefinitions.keys.sorted() {
      if let dummyDefinition = DummyManager.dummyDefinitions[key] {
        let item = NSMenuItem(title: "\(dummyDefinition.description)", action: #selector(app.createDummy(_:)), keyEquivalent: "")
        item.tag = key
        self.newMenu.addItem(item)
        if dummyDefinition.addSeparatorAfter {
          self.newMenu.addItem(NSMenuItem.separator())
        }
      }
    }
    os_log("New dummy menu populated.", type: .info)
  }

  func addManageMenu() {
    let manageMenu = NSMenu()

    if DummyManager.dummyCounter > 1 {
      var isThereDisconnected = false
      var isThereConnected = false
      var isThereAssociated = false
      var isThereAny = false
      for dummy in DummyManager.getDummies() {
        isThereAny = true
        if dummy.isConnected {
          isThereConnected = true
        }
        if !dummy.isConnected {
          isThereDisconnected = true
        }
        if dummy.hasAssociatedDisplay() {
          isThereAssociated = true
        }
      }

      if isThereAny {
        manageMenu.addItem(NSMenuItem.separator())
      }

      manageMenu.addItem(NSMenuItem.separator())
      if isThereDisconnected {
        manageMenu.addItem(NSMenuItem(title: "Connect all dummies", action: #selector(app.connectAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereConnected {
        manageMenu.addItem(NSMenuItem(title: "Disconnect all dummies", action: #selector(app.disconnectAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereAssociated {
        manageMenu.addItem(NSMenuItem(title: "Disassociate all dummies", action: #selector(app.disassociateAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereAny {
        manageMenu.addItem(NSMenuItem(title: "Discard all dummies", action: #selector(app.discardAllDummies(_:)), keyEquivalent: ""))
        let manageSubmenu = NSMenuItem(title: "Manage dummies", action: nil, keyEquivalent: "")
        manageSubmenu.submenu = manageMenu
        self.appMenu.addItem(manageSubmenu)
      }
    }
  }

  func getResolutionSubmenuItem(_ dummy: Dummy, _ number: Int) -> NSMenuItem? {
    if prefs.bool(forKey: PrefKey.useMenuForResolution.rawValue) {
      let resolutionMenu = NSMenu()
      if let resolutions = DisplayManager.getDisplayById(dummy.displayIdentifier)?.resolutions {
        for resolution in resolutions.sorted(by: { $0.0 < $1.0 }) where resolution.value.height >= 720 && resolution.value.hiDPI == true {
          let resolutionMenuItem = NSMenuItem(title: "\(resolution.value.width)x\(resolution.value.height)", action: #selector(app.dummyResolution(_:)), keyEquivalent: "")
          resolutionMenuItem.tag = number * 256 * 256 + resolution.key
          resolutionMenuItem.state = resolution.value.isActive ? .on : .off
          resolutionMenu.addItem(resolutionMenuItem)
        }
        resolutionMenu.addItem(NSMenuItem.separator())
        if !prefs.bool(forKey: PrefKey.hideLowResolutionOption.rawValue) {
          for resolution in resolutions.sorted(by: { $0.0 < $1.0 }) where resolution.value.height >= 720 && resolution.value.hiDPI == false {
            let resolutionMenuItem = NSMenuItem(title: "\(resolution.value.width)x\(resolution.value.height)" + " (low resolution)", action: #selector(app.dummyResolution(_:)), keyEquivalent: "")
            resolutionMenuItem.tag = number * 256 * 256 + resolution.key
            resolutionMenuItem.state = resolution.value.isActive ? .on : .off
            resolutionMenu.addItem(resolutionMenuItem)
          }
        }
      } else {
        let unavailableItem = NSMenuItem(title: "Unavailable", action: nil, keyEquivalent: "")
        unavailableItem.isEnabled = false
        resolutionMenu.addItem(unavailableItem)
      }
      let resolutionSubmenu = NSMenuItem(title: "Set resolution", action: nil, keyEquivalent: "")
      resolutionSubmenu.image = NSImage(systemSymbolName: "arrow.up.backward.and.arrow.down.forward", accessibilityDescription: "icon")
      resolutionSubmenu.submenu = resolutionMenu
      return resolutionSubmenu
    } else {
      if let display = DisplayManager.getDisplayById(dummy.displayIdentifier) {
        let sliderHandler = display.resolutionSliderHandler ?? ResolutionSliderHandler(display: display)
        display.resolutionSliderHandler = sliderHandler
        let sliderItem = NSMenuItem()
        sliderItem.view = sliderHandler.view
        return sliderItem
      }
    }
    return nil
  }

  func getAssociateSubmenuItem(_ dummy: Dummy, _ number: Int) -> NSMenuItem {
    let associateMenu = NSMenu()
    var foundAssociatedDisplay = false
    for displayNumber in DisplayManager.displays.keys {
      if let display = DisplayManager.displays[displayNumber], !display.isDummy {
        let displayItem = NSMenuItem(title: display.name, action: #selector(app.associateDummy(_:)), keyEquivalent: "")
        displayItem.tag = 0x100 * displayNumber + number // This is a composite tag identifying both the display and the dummy number
        if display.prefsId == dummy.associatedDisplayPrefsId, dummy.hasAssociatedDisplay() {
          displayItem.state = .on
          foundAssociatedDisplay = true
        }
        associateMenu.addItem(displayItem)
      }
    }
    if dummy.hasAssociatedDisplay() {
      if !foundAssociatedDisplay {
        let displayItem = NSMenuItem(title: "\(dummy.associatedDisplayName) (disconnected)", action: #selector(app.associateDummy(_:)), keyEquivalent: "")
        displayItem.state = .on
        associateMenu.addItem(displayItem)
        displayItem.tag = 0 // This signifies that this is a disconnected, already associated display
      }
      associateMenu.addItem(NSMenuItem.separator())
      let disassociateItem = NSMenuItem(title: "Disassociate", action: #selector(app.disassociateDummy(_:)), keyEquivalent: "")
      disassociateItem.tag = number
      associateMenu.addItem(disassociateItem)
    }
    let associateSubmenu = NSMenuItem(title: dummy.hasAssociatedDisplay() ? "\(dummy.associatedDisplayName)" : "Associate with...", action: nil, keyEquivalent: "")
    associateSubmenu.image = NSImage(systemSymbolName: dummy.hasAssociatedDisplay() ? "link" : "link.badge.plus", accessibilityDescription: "icon")
    associateSubmenu.submenu = associateMenu
    return associateSubmenu
  }

  func checkmarkedMenuItem(checked: Bool, label: String, tag: Int? = nil, selector: Selector) -> NSMenuItem {
    let menuItem = NSMenuItem(title: label, action: selector, keyEquivalent: "")
    if let tag = tag {
      menuItem.tag = tag
    }
    menuItem.state = checked ? .on : .off
    menuItem.onStateImage = nil
    menuItem.image = NSImage(systemSymbolName: checked ? "checkmark.circle" : "circle", accessibilityDescription: "icon")
    return menuItem
  }

  func addDummyToMenu(_ dummy: Dummy, _ number: Int) {
    let dummyHeaderItem = NSMenuItem()
    let attributedHeader = NSMutableAttributedString()
    var attrs: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]
    attributedHeader.append(NSAttributedString(string: "\(dummy.getName())", attributes: attrs))
    attrs = [.foregroundColor: NSColor.systemGray, .font: NSFont.systemFont(ofSize: 13)]
    attributedHeader.append(NSAttributedString(string: " (\(dummy.getSerialNumber()))", attributes: attrs))
    dummyHeaderItem.attributedTitle = attributedHeader
    self.appMenu.addItem(dummyHeaderItem)
    if dummy.isConnected, let resolutionSubmenuItem = self.getResolutionSubmenuItem(dummy, number) {
      self.appMenu.addItem(resolutionSubmenuItem)
    }
    self.appMenu.addItem(self.checkmarkedMenuItem(checked: dummy.isConnected, label: "Connected\(dummy.hasAssociatedDisplay() ? " (automatic)" : "")", tag: number, selector: #selector(app.connectDisconnectDummy)))
    if dummy.isConnected, !prefs.bool(forKey: PrefKey.hideLowResolutionOption.rawValue), !prefs.bool(forKey: PrefKey.useMenuForResolution.rawValue), let display = DisplayManager.getDisplayById(dummy.displayIdentifier) {
      self.appMenu.addItem(self.checkmarkedMenuItem(checked: !display.isHiDPI, label: "Low resolution mode", tag: number, selector: #selector(app.lowResolution)))
    }
    if !prefs.bool(forKey: PrefKey.hidePortraitOption.rawValue), dummy.dummyDefinition.aspectWidth != dummy.dummyDefinition.aspectHeight {
      self.appMenu.addItem(self.checkmarkedMenuItem(checked: dummy.isPortrait, label: "Portrait orientation", tag: number, selector: #selector(app.portrait)))
    }
    self.appMenu.addItem(self.getAssociateSubmenuItem(dummy, number))
    let deleteItem = NSMenuItem(title: "Discard dummy", action: #selector(app.discardDummy(_:)), keyEquivalent: "")
    deleteItem.image = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "icon")
    deleteItem.tag = number
    self.appMenu.addItem(deleteItem)
  }
}

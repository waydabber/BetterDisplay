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
  let manageMenu = NSMenu()
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
    if DummyManager.dummyCounter > 1 {
      self.appMenu.addItem(NSMenuItem.separator())
    }
    let manageSubmenu = NSMenuItem(title: "Manage dummies", action: nil, keyEquivalent: "")
    self.populateManageMenu()
    manageSubmenu.submenu = self.manageMenu
    self.appMenu.addItem(manageSubmenu)
    let settingsSubmenu = NSMenuItem(title: "Preferences", action: nil, keyEquivalent: "")
    settingsSubmenu.submenu = self.settingsMenu
    self.appMenu.addItem(settingsSubmenu)
    self.appMenu.addItem(NSMenuItem(title: "Please donate!", action: #selector(app.donate(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
  }

  func populateSettingsMenu() {
    self.emptyMenu(self.settingsMenu)

    let startAtLoginMenuItem = NSMenuItem(title: "Start at login", action: #selector(app.startAtLogin(_:)), keyEquivalent: "")
    startAtLoginMenuItem.state = app.getStartAtLogin() ? .on : .off
    self.settingsMenu.addItem(startAtLoginMenuItem)

    let automaticallyCheckForUpdatesMenuItem = NSMenuItem(title: "Automatically check for updates", action: #selector(app.SUEnableAutomaticChecks(_:)), keyEquivalent: "")
    automaticallyCheckForUpdatesMenuItem.state = prefs.bool(forKey: PrefKey.SUEnableAutomaticChecks.rawValue) ? .on : .off
    self.settingsMenu.addItem(automaticallyCheckForUpdatesMenuItem)

    let hideMenuIconMenuItem = NSMenuItem(title: "Hide menu icon", action: #selector(app.hideMenuIcon(_:)), keyEquivalent: "")
    hideMenuIconMenuItem.state = prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue) ? .on : .off
    self.settingsMenu.addItem(hideMenuIconMenuItem)

    // ---
    self.settingsMenu.addItem(NSMenuItem.separator())

    let enable16KMenuItem = NSMenuItem(title: "Enable up to 16K resolutions", action: #selector(app.enable16K(_:)), keyEquivalent: "")
    enable16KMenuItem.state = prefs.bool(forKey: PrefKey.enable16K.rawValue) ? .on : .off
    self.settingsMenu.addItem(enable16KMenuItem)

    let useMenuForResolutionMenuItem = NSMenuItem(title: "Use resolution submenu instad of slider", action: #selector(app.useMenuForResolution(_:)), keyEquivalent: "")
    useMenuForResolutionMenuItem.state = prefs.bool(forKey: PrefKey.useMenuForResolution.rawValue) ? .on : .off
    self.settingsMenu.addItem(useMenuForResolutionMenuItem)

    let showLowResolutionModesMenuItem = NSMenuItem(title: "Show low resolution (non-HiDPI) option", action: #selector(app.hideLowResolutionOption(_:)), keyEquivalent: "")
    showLowResolutionModesMenuItem.state = prefs.bool(forKey: PrefKey.hideLowResolutionOption.rawValue) ? .off : .on
    self.settingsMenu.addItem(showLowResolutionModesMenuItem)

    let showPortaitMenuItem = NSMenuItem(title: "Show portrait mode setting", action: #selector(app.hidePortraitOption(_:)), keyEquivalent: "")
    showPortaitMenuItem.state = prefs.bool(forKey: PrefKey.hidePortraitOption.rawValue) ? .off : .on
    self.settingsMenu.addItem(showPortaitMenuItem)

    // ---
    self.settingsMenu.addItem(NSMenuItem.separator())

    let useTempSleepMenuItem = NSMenuItem(title: "Use mirrored dummy sleep workaround", action: #selector(app.disableTempSleep(_:)), keyEquivalent: "")
    useTempSleepMenuItem.state = !prefs.bool(forKey: PrefKey.disableTempSleep.rawValue) ? .on : .off
    self.settingsMenu.addItem(useTempSleepMenuItem)

    let reconnectAfterSleepMenuItem = NSMenuItem(title: "Disconnect and reconnect on sleep", action: #selector(app.reconnectAfterSleep(_:)), keyEquivalent: "")
    reconnectAfterSleepMenuItem.state = prefs.bool(forKey: PrefKey.reconnectAfterSleep.rawValue) ? .on : .off
    self.settingsMenu.addItem(reconnectAfterSleepMenuItem)

    // ---

    self.settingsMenu.addItem(NSMenuItem.separator())
    let updateItem = NSMenuItem(title: "Check for updates...", action: #selector(app.updaterController.checkForUpdates(_:)), keyEquivalent: "")
    updateItem.target = app.updaterController
    self.settingsMenu.addItem(updateItem)
    self.settingsMenu.addItem(NSMenuItem(title: "About BetterDummy", action: #selector(app.about(_:)), keyEquivalent: ""))

    // ---
    self.settingsMenu.addItem(NSMenuItem.separator())

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

  func addManageMenuDummies() {
    for key in DummyManager.definedDummies.keys.sorted(by: <) {
      if let dummy = DummyManager.getDummyByNumber(key) {
        self.manageMenu.addItem(NSMenuItem.separator())
        let dummyHeaderItem = NSMenuItem()
        let attributedHeader = NSMutableAttributedString()
        var attrs: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]
        attributedHeader.append(NSAttributedString(string: "\(dummy.getName())", attributes: attrs))
        attrs = [.foregroundColor: NSColor.systemGray, .font: NSFont.systemFont(ofSize: 13)]
        attributedHeader.append(NSAttributedString(string: " (\(dummy.getSerialNumber()))", attributes: attrs))
        dummyHeaderItem.attributedTitle = attributedHeader
        self.manageMenu.addItem(dummyHeaderItem)
        self.manageMenu.addItem(self.getAssociateSubmenuItem(dummy, key))
        let deleteItem = NSMenuItem(title: "Discard dummy", action: #selector(app.discardDummy(_:)), keyEquivalent: "")
        deleteItem.tag = key
        self.manageMenu.addItem(deleteItem)
      }
    }
  }

  func populateManageMenu() {
    self.emptyMenu(self.manageMenu)

    let newSubmenu = NSMenuItem(title: "Create new dummy", action: nil, keyEquivalent: "")
    newSubmenu.submenu = self.newMenu
    self.manageMenu.addItem(newSubmenu)

    self.addManageMenuDummies()

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
        self.manageMenu.addItem(NSMenuItem.separator())
      }

      self.manageMenu.addItem(NSMenuItem.separator())
      if isThereDisconnected {
        self.manageMenu.addItem(NSMenuItem(title: "Connect all dummies", action: #selector(app.connectAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereConnected {
        self.manageMenu.addItem(NSMenuItem(title: "Disconnect all dummies", action: #selector(app.disconnectAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereAssociated {
        self.manageMenu.addItem(NSMenuItem(title: "Disassociate all dummies", action: #selector(app.disassociateAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereAny {
        self.manageMenu.addItem(NSMenuItem(title: "Discard all dummies", action: #selector(app.discardAllDummies(_:)), keyEquivalent: ""))
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
    let associateSubmenu = NSMenuItem(title: dummy.hasAssociatedDisplay() ? "Change association" : "Associate with display", action: nil, keyEquivalent: "")
    associateSubmenu.submenu = associateMenu
    return associateSubmenu
  }

  func checkmarkedMenuItem(checked: Bool, label: String, tag: Int, selector: Selector) -> NSMenuItem {
    let menuItemView = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 26))
    let icon = NSButton()
    icon.bezelStyle = .regularSquare
    icon.isBordered = false
    icon.setButtonType(.momentaryChange)
    icon.image = NSImage(systemSymbolName: checked ? "checkmark.circle" : "circle", accessibilityDescription: "Checkmark")
    icon.alternateImage = NSImage(systemSymbolName: checked ? "checkmark.circle.fill" : "circle.fill", accessibilityDescription: "Checkmark")
    icon.frame = NSRect(x: 12, y: 3.5, width: 19, height: 19)
    icon.imageScaling = .scaleProportionallyUpOrDown
    icon.action = selector
    icon.tag = tag
    let text = NSButton()
    let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.systemFont(ofSize: 13)]
    text.attributedTitle = NSAttributedString(string: label, attributes: attrs)
    text.frame = NSRect(x: 34, y: 4, width: 180, height: 18)
    text.bezelStyle = .regularSquare
    text.isBordered = false
    text.alignment = .left
    text.action = selector
    text.tag = tag
    menuItemView.addSubview(icon)
    menuItemView.addSubview(text)
    let item = NSMenuItem()
    item.view = menuItemView
    return item
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
      if !prefs.bool(forKey: PrefKey.hideLowResolutionOption.rawValue), !prefs.bool(forKey: PrefKey.useMenuForResolution.rawValue), let display = DisplayManager.getDisplayById(dummy.displayIdentifier) {
        self.appMenu.addItem(self.checkmarkedMenuItem(checked: !display.isHiDPI, label: "Low resolution mode", tag: number, selector: #selector(app.lowResolution)))
      }
    }
    if !prefs.bool(forKey: PrefKey.hidePortraitOption.rawValue), dummy.dummyDefinition.aspectWidth != dummy.dummyDefinition.aspectHeight {
      self.appMenu.addItem(self.checkmarkedMenuItem(checked: dummy.isPortrait, label: "Portrait orientation", tag: number, selector: #selector(app.portrait)))
    }
    self.appMenu.addItem(self.checkmarkedMenuItem(checked: dummy.isConnected, label: "Connected\(dummy.hasAssociatedDisplay() ? " (automatic)" : "")", tag: number, selector: #selector(app.connectDummy)))
  }
}

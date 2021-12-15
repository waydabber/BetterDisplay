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
    self.appMenu.addItem(NSMenuItem(title: "Donate...", action: #selector(app.donate(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
  }

  func populateSettingsMenu() {
    self.emptyMenu(self.settingsMenu)

    let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]

    let generalHeaderItem = NSMenuItem()
    generalHeaderItem.attributedTitle = NSAttributedString(string: "General settings", attributes: attrs)
    self.settingsMenu.addItem(generalHeaderItem)

    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: app.getStartAtLogin(), title: "Start at login", action: #selector(app.startAtLogin)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.SUEnableAutomaticChecks.rawValue), title: "Automatically check for updates", action: #selector(app.SUEnableAutomaticChecks)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue), title: "Hide menu icon", action: #selector(app.hideMenuIcon)))

    // ---
    self.settingsMenu.addItem(NSMenuItem.separator())

    let resolutionsHeaderItem = NSMenuItem()
    resolutionsHeaderItem.attributedTitle = NSAttributedString(string: "Resolutions", attributes: attrs)
    self.settingsMenu.addItem(resolutionsHeaderItem)

    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.enable16K.rawValue), title: "Enable up to 16K resolutions", action: #selector(app.enable16K)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: !prefs.bool(forKey: PrefKey.hideLowResolutionOption.rawValue), title: "Show low resolution (non-HiDPI) options", action: #selector(app.hideLowResolutionOption)))

    // ---
    self.settingsMenu.addItem(NSMenuItem.separator())

    let sleepHeaderItem = NSMenuItem()
    sleepHeaderItem.attributedTitle = NSAttributedString(string: "Sleep settings", attributes: attrs)
    self.settingsMenu.addItem(sleepHeaderItem)

    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: !prefs.bool(forKey: PrefKey.disableTempSleep.rawValue), title: "Use mirrored dummy sleep workaround", action: #selector(app.disableTempSleep)))
    self.settingsMenu.addItem(self.checkmarkedMenuItem(checked: prefs.bool(forKey: PrefKey.reconnectAfterSleep.rawValue), title: "Disconnect and reconnect on sleep", action: #selector(app.reconnectAfterSleep)))

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
    let resolutionMenu = NSMenu()
    if let resolutions = DisplayManager.getDisplayById(dummy.displayIdentifier)?.resolutions {
      let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]
      let hidpiHeaderItem = NSMenuItem()
      hidpiHeaderItem.attributedTitle = NSAttributedString(string: "HiDPI resolutions", attributes: attrs)
      resolutionMenu.addItem(hidpiHeaderItem)
      for resolution in resolutions.sorted(by: { $0.0 < $1.0 }) where resolution.value.height >= 720 && resolution.value.hiDPI == true {
        resolutionMenu.addItem(self.checkmarkedMenuItem(checked: resolution.value.isActive, title: "\(resolution.value.width)x\(resolution.value.height)", tag: number * 256 * 256 + resolution.key, action: #selector(app.dummyResolution(_:)), radio: true))
      }
      if !prefs.bool(forKey: PrefKey.hideLowResolutionOption.rawValue) {
        resolutionMenu.addItem(NSMenuItem.separator())
        let hidpiHeaderItem = NSMenuItem()
        hidpiHeaderItem.attributedTitle = NSAttributedString(string: "Low resolutions", attributes: attrs)
        resolutionMenu.addItem(hidpiHeaderItem)
        for resolution in resolutions.sorted(by: { $0.0 < $1.0 }) where resolution.value.height >= 720 && resolution.value.hiDPI == false {
          resolutionMenu.addItem(self.checkmarkedMenuItem(checked: resolution.value.isActive, title: "\(resolution.value.width)x\(resolution.value.height) (low)", tag: number * 256 * 256 + resolution.key, action: #selector(app.dummyResolution(_:)), radio: true))
        }
      }
    } else {
      let unavailableItem = NSMenuItem(title: "Unavailable", action: nil, keyEquivalent: "")
      unavailableItem.isEnabled = false
      resolutionMenu.addItem(unavailableItem)
    }
    let resolutionSubmenu = NSMenuItem(title: "Set resolution", action: nil, keyEquivalent: "")
    resolutionSubmenu.image = NSImage(systemSymbolName: "rectangle.stack", accessibilityDescription: "icon")
    resolutionSubmenu.submenu = resolutionMenu
    return resolutionSubmenu
  }

  func getAssociateSubmenuItem(_ dummy: Dummy, _ number: Int) -> NSMenuItem {
    let associateMenu = NSMenu()
    var foundAssociatedDisplay = false
    for displayNumber in DisplayManager.displays.keys {
      if let display = DisplayManager.displays[displayNumber], !display.isDummy {
        var checked = false
        if display.prefsId == dummy.associatedDisplayPrefsId, dummy.hasAssociatedDisplay() {
          checked = true
          foundAssociatedDisplay = true
        }
        associateMenu.addItem(self.checkmarkedMenuItem(checked: checked, title: display.name, tag: 0x100 * displayNumber + number, action: #selector(app.associateDummy(_:)), radio: true))
      }
    }
    if dummy.hasAssociatedDisplay(), !foundAssociatedDisplay {
      associateMenu.addItem(self.checkmarkedMenuItem(checked: true, title: "\(dummy.associatedDisplayName) (disconnected)", tag: 0, action: #selector(app.associateDummy(_:)), radio: true))
    }
    associateMenu.addItem(self.checkmarkedMenuItem(checked: !dummy.hasAssociatedDisplay(), title: "None (disassociated)", tag: number, action: #selector(app.disassociateDummy(_:)), radio: true))
    let associateSubmenu = NSMenuItem(title: dummy.hasAssociatedDisplay() ? "Change association" : "Set up association", action: nil, keyEquivalent: "")
    associateSubmenu.image = NSImage(systemSymbolName: dummy.hasAssociatedDisplay() ? "link" : "link.badge.plus", accessibilityDescription: "icon")
    associateSubmenu.submenu = associateMenu
    return associateSubmenu
  }

  func checkmarkedMenuItem(checked: Bool, title: String, tag: Int? = nil, action: Selector, radio: Bool = false) -> NSMenuItem {
    let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: "")
    if let tag = tag {
      menuItem.tag = tag
    }
    menuItem.state = checked ? .on : .off
    menuItem.onStateImage = nil
    menuItem.image = NSImage(systemSymbolName: checked ? (radio ? "record.circle" : "checkmark.circle") : (radio ? "circle" : "circle"), accessibilityDescription: "icon")
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
    self.appMenu.addItem(self.getAssociateSubmenuItem(dummy, number))
    if dummy.isConnected, let resolutionSubmenuItem = self.getResolutionSubmenuItem(dummy, number) {
      self.appMenu.addItem(resolutionSubmenuItem)
    }
    self.appMenu.addItem(self.checkmarkedMenuItem(checked: dummy.isConnected, title: "Connected\(dummy.hasAssociatedDisplay() ? " (automatic)" : "")", tag: number, action: #selector(app.connectDisconnectDummy)))
    let deleteItem = NSMenuItem(title: "Discard dummy", action: #selector(app.discardDummy(_:)), keyEquivalent: "")
    deleteItem.image = NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "icon")
    deleteItem.tag = number
    self.appMenu.addItem(deleteItem)
  }
}

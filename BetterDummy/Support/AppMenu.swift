//
//  BetterDummy
//
//  Created by @waydabber
//

import AppKit
import os.log

class AppMenu {
  let appMenu = NSMenu()
  var statusBarItem: NSStatusItem!
  let manageMenu = NSMenu()
  let manageSubmenu = NSMenuItem(title: "Manage dummies", action: nil, keyEquivalent: "")
  let startAtLoginMenuItem = NSMenuItem(title: "Start at login", action: #selector(app.handleStartAtLogin(_:)), keyEquivalent: "")
  let hideMenuIconMenuItem = NSMenuItem(title: "Hide menu icon", action: #selector(app.handleHideMenuIcon(_:)), keyEquivalent: "")
  let automaticallyCheckForUpdatesMenuItem = NSMenuItem(title: "Automatically check for updates", action: #selector(app.handleSimpleCheckMenu(_:)), keyEquivalent: "")
  let enable16KMenuItem = NSMenuItem(title: "Enable up to 16K resolutions", action: #selector(app.handleEnable16K(_:)), keyEquivalent: "")
  let useMenuForResolutionMenuItem = NSMenuItem(title: "Use resolution submenu instad of slider", action: #selector(app.handleUseMenuForResolution(_:)), keyEquivalent: "")
  let showLowResolutionModesMenuItem = NSMenuItem(title: "Show non-HiDPI modes in resolution submenu", action: #selector(app.handleShowLowResolutionModes(_:)), keyEquivalent: "")
  let reconnectAfterSleepMenuItem = NSMenuItem(title: "Disconnect and reconnect on sleep", action: #selector(app.handleSimpleCheckMenu(_:)), keyEquivalent: "")
  let useTempSleepMenuItem = NSMenuItem(title: "Use mirrored dummy sleep workaround", action: #selector(app.handleSimpleCheckMenu(_:)), keyEquivalent: "")

  @available(macOS, deprecated: 10.10)
  func setupMenu() {
    let newMenu = NSMenu()
    let newSubmenu = NSMenuItem(title: "Create new dummy", action: nil, keyEquivalent: "")
    newSubmenu.submenu = newMenu
    self.manageSubmenu.submenu = self.manageMenu
    self.manageSubmenu.isHidden = true
    let settingsMenu = NSMenu()
    settingsMenu.addItem(self.startAtLoginMenuItem)
    settingsMenu.addItem(self.automaticallyCheckForUpdatesMenuItem)
    settingsMenu.addItem(self.hideMenuIconMenuItem)
    settingsMenu.addItem(NSMenuItem.separator())
    settingsMenu.addItem(self.enable16KMenuItem)
    settingsMenu.addItem(self.useMenuForResolutionMenuItem)
    settingsMenu.addItem(self.showLowResolutionModesMenuItem)
    settingsMenu.addItem(NSMenuItem.separator())
    settingsMenu.addItem(self.useTempSleepMenuItem)
    settingsMenu.addItem(self.reconnectAfterSleepMenuItem)
    settingsMenu.addItem(NSMenuItem.separator())
    settingsMenu.addItem(NSMenuItem(title: "Reset BetterDummy", action: #selector(app.handleReset(_:)), keyEquivalent: ""))
    let settingsSubmenu = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
    settingsSubmenu.submenu = settingsMenu
    self.appMenu.addItem(newSubmenu)
    self.appMenu.addItem(self.manageSubmenu)
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(settingsSubmenu)
    let updateItem = NSMenuItem(title: "Check for updates...", action: #selector(app.updaterController.checkForUpdates(_:)), keyEquivalent: "")
    updateItem.target = app.updaterController
    self.appMenu.addItem(updateItem)
    self.appMenu.addItem(NSMenuItem(title: "About BetterDummy", action: #selector(app.handleAbout(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem(title: "Donate", action: #selector(app.handleDonate(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    self.populateNewMenu(newMenu)
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: "status")
    }
    self.statusBarItem.menu = self.appMenu
    self.statusBarItem.isVisible = !prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue)
  }

  func populateNewMenu(_ newMenu: NSMenu) {
    for key in DummyManager.dummyDefinitions.keys.sorted() {
      if let dummyDefinition = DummyManager.dummyDefinitions[key] {
        let item = NSMenuItem(title: "\(dummyDefinition.description)", action: #selector(app.handleCreateDummy(_:)), keyEquivalent: "")
        item.tag = key
        newMenu.addItem(item)
        if dummyDefinition.addSeparatorAfter {
          newMenu.addItem(NSMenuItem.separator())
        }
      }
    }
    os_log("New dummy menu populated.", type: .info)
  }

  func emptyManageMenu() {
    var items: [NSMenuItem] = []
    for i in 0 ..< self.manageMenu.items.count {
      items.append(self.manageMenu.items[i])
    }
    for item in items {
      self.manageMenu.removeItem(item)
    }
  }

  func repopulateManageMenu() {
    self.emptyManageMenu()
    var first = true
    for key in DummyManager.definedDummies.keys.sorted(by: <) {
      if let dummy = DummyManager.getDummyByNumber(key) {
        if !first {
          self.manageMenu.addItem(NSMenuItem.separator())
        }
        self.addDummyToManageMenu(dummy, key)
        first = false
      }
    }
    self.addStandardManageMenuOptions()
    if DummyManager.getNumOfDummies() == 0 {
      self.manageSubmenu.isHidden = true
    }
  }

  func addStandardManageMenuOptions() {
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
      self.manageMenu.addItem(NSMenuItem.separator())
      if isThereDisconnected {
        self.manageMenu.addItem(NSMenuItem(title: "Connect all dummies", action: #selector(app.handleConnectAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereConnected {
        self.manageMenu.addItem(NSMenuItem(title: "Disconnect all dummies", action: #selector(app.handleDisconnectAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereAssociated {
        self.manageMenu.addItem(NSMenuItem(title: "Disassociate all dummies", action: #selector(app.handleDisassociateAllDummies(_:)), keyEquivalent: ""))
      }
      if isThereAny {
        self.manageMenu.addItem(NSMenuItem(title: "Discard all dummies", action: #selector(app.handleDiscardAllDummies(_:)), keyEquivalent: ""))
      }
    }
  }

  func getResolutionSubmenuItem(_ dummy: Dummy, _ number: Int) -> NSMenuItem? {
    if prefs.bool(forKey: PrefKey.useMenuForResolution.rawValue) {
      let resolutionMenu = NSMenu()
      if let resolutions = DisplayManager.getDisplayById(dummy.displayIdentifier)?.resolutions {
        for resolution in resolutions.sorted(by: { $0.0 < $1.0 }) where resolution.value.height >= 720 && resolution.value.hiDPI == true {
          let resolutionMenuItem = NSMenuItem(title: "\(resolution.value.width)x\(resolution.value.height)", action: #selector(app.handleDummyResolution(_:)), keyEquivalent: "")
          resolutionMenuItem.tag = number * 256 * 256 + resolution.key
          resolutionMenuItem.state = resolution.value.isActive ? .on : .off
          resolutionMenu.addItem(resolutionMenuItem)
        }
        resolutionMenu.addItem(NSMenuItem.separator())
        if prefs.bool(forKey: PrefKey.showLowResolutionModes.rawValue) {
          for resolution in resolutions.sorted(by: { $0.0 < $1.0 }) where resolution.value.height >= 720 && resolution.value.hiDPI == false {
            let resolutionMenuItem = NSMenuItem(title: "\(resolution.value.width)x\(resolution.value.height)" + " (low resolution)", action: #selector(app.handleDummyResolution(_:)), keyEquivalent: "")
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
        let displayItem = NSMenuItem(title: display.name, action: #selector(app.handleAssociateDummy(_:)), keyEquivalent: "")
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
        let displayItem = NSMenuItem(title: "\(dummy.associatedDisplayName) (disconnected)", action: #selector(app.handleAssociateDummy(_:)), keyEquivalent: "")
        displayItem.state = .on
        associateMenu.addItem(displayItem)
        displayItem.tag = 0 // This signifies that this is a disconnected, already associated display
      }
      associateMenu.addItem(NSMenuItem.separator())
      let disassociateItem = NSMenuItem(title: "Disassociate", action: #selector(app.handleDisassociateDummy(_:)), keyEquivalent: "")
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
    icon.image = NSImage(systemSymbolName: checked ? "checkmark.square" : "square", accessibilityDescription: "Checkmark")
    icon.alternateImage = NSImage(systemSymbolName: checked ? "checkmark.square.fill" : "square.fill", accessibilityDescription: "Checkmark")
    icon.frame = NSRect(x: 12, y: 3, width: 19, height: 18)
    icon.imageScaling = .scaleProportionallyUpOrDown
    icon.action = selector
    icon.tag = tag
    let text = NSButton()
    let attrs: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.systemFont(ofSize: 13)]
    text.attributedTitle = NSAttributedString(string: label, attributes: attrs)
    text.frame = NSRect(x: 35, y: 4, width: 180, height: 18)
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

  func addDummyToManageMenu(_ dummy: Dummy, _ number: Int) {
    let dummyHeaderItem = NSMenuItem()
    let attributedHeader = NSMutableAttributedString()
    var attrs: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]
    attributedHeader.append(NSAttributedString(string: "\(dummy.getName())", attributes: attrs))
    attrs = [.foregroundColor: NSColor.systemGray, .font: NSFont.systemFont(ofSize: 13)]
    attributedHeader.append(NSAttributedString(string: " (\(dummy.getSerialNumber()))", attributes: attrs))
    dummyHeaderItem.attributedTitle = attributedHeader
    self.manageMenu.addItem(dummyHeaderItem)
    if dummy.isConnected {
      if let resolutionSubmenuItem = self.getResolutionSubmenuItem(dummy, number) {
        self.manageMenu.addItem(resolutionSubmenuItem)
      }
      self.manageMenu.addItem(self.checkmarkedMenuItem(checked: true, label: "Connected", tag: number, selector: #selector(app.handleDisconnectDummy)))
      self.manageMenu.addItem(self.getAssociateSubmenuItem(dummy, number))
    } else {
      self.manageMenu.addItem(self.checkmarkedMenuItem(checked: false, label: "Connected", tag: number, selector: #selector(app.handleConnectDummy)))
      self.manageMenu.addItem(self.getAssociateSubmenuItem(dummy, number))
    }
    let deleteItem = NSMenuItem(title: "Discard dummy", action: #selector(app.handleDiscardDummy(_:)), keyEquivalent: "")
    deleteItem.tag = number
    self.manageMenu.addItem(deleteItem)
    self.manageSubmenu.isHidden = false
  }
}

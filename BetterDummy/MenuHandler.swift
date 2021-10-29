//
//  menuHandler.swift
//  BetterDummy
//
//  Created by @waydabber
//

import AppKit
import os.log

class MenuHandler {
  var appMenu = NSMenu()
  var statusBarItem: NSStatusItem!
  let manageMenu = NSMenu()
  let manageSubmenu = NSMenuItem(title: "Manage Dummy", action: nil, keyEquivalent: "")
  let startAtLoginMenuItem = NSMenuItem(title: "Start at Login", action: #selector(app.handleStartAtLogin(_:)), keyEquivalent: "")
  let automaticallyCheckForUpdatesMenuItem = NSMenuItem(title: "Automatically check for updates", action: #selector(app.handleAutomaticallyCheckForUpdates(_:)), keyEquivalent: "")
  let reconnectAfterSleepMenuItem = NSMenuItem(title: "Disconnect and Reconnect on Sleep", action: #selector(app.handleReconnectAfterSleep(_:)), keyEquivalent: "")

  init() {
    let newMenu = NSMenu()
    let newSubmenu = NSMenuItem(title: "Create Dummy", action: nil, keyEquivalent: "")
    newSubmenu.submenu = newMenu
    self.manageSubmenu.submenu = self.manageMenu
    self.manageSubmenu.isHidden = true
    let settingsMenu = NSMenu()
    settingsMenu.addItem(self.startAtLoginMenuItem)
    settingsMenu.addItem(self.automaticallyCheckForUpdatesMenuItem)
    settingsMenu.addItem(self.reconnectAfterSleepMenuItem)
    let settingsSubmenu = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
    settingsSubmenu.submenu = settingsMenu
    self.appMenu.addItem(newSubmenu)
    self.appMenu.addItem(self.manageSubmenu)
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(settingsSubmenu)
    self.appMenu.addItem(NSMenuItem(title: "Check for updates...", action: #selector(app.updaterController.checkForUpdates(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem(title: "About BetterDummy", action: #selector(app.handleAbout(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem(title: "Contribute...", action: #selector(app.handleDonate(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    self.populateNewMenu(newMenu)
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "BetterDummy")
    }
    self.statusBarItem.menu = self.appMenu
  }

  func populateNewMenu(_ newMenu: NSMenu) {
    var i = 0
    for displayDefinition in DummyDefinition.dummyDefinitions {
      let item = NSMenuItem(title: "\(displayDefinition.description)", action: #selector(app.handleCreateDummy(_:)), keyEquivalent: "")
      item.tag = i
      newMenu.addItem(item)
      i += 1
    }
    os_log("New dummy menu populated.", type: .info)
  }

  func repopulateManageMenu() {
    var items: [NSMenuItem] = []
    for i in 0 ..< self.manageMenu.items.count {
      items.append(self.manageMenu.items[i])
    }
    for item in items {
      self.manageMenu.removeItem(item)
    }
    for i in app.dummies.keys {
      if let dummy = app.dummies[i] {
        self.addDummyToManageMenu(dummy)
      }
    }
  }

  func addDummyToManageMenu(_ dummy: Dummy) {
    var disconnectDisconnectItem: NSMenuItem
    if dummy.isConnected {
      disconnectDisconnectItem = NSMenuItem(title: "\(dummy.getMenuItemTitle()) - Disconnect", action: #selector(app.handleDisconnectDummy(_:)), keyEquivalent: "")
    } else {
      disconnectDisconnectItem = NSMenuItem(title: "\(dummy.getMenuItemTitle()) - Connect", action: #selector(app.handleConnectDummy(_:)), keyEquivalent: "")
    }
    disconnectDisconnectItem.tag = dummy.number
    let deleteItem = NSMenuItem(title: "\(dummy.getMenuItemTitle()) - Discard", action: #selector(app.handleDiscardDummy(_:)), keyEquivalent: "")
    deleteItem.tag = dummy.number
    self.manageMenu.addItem(disconnectDisconnectItem)
    self.manageMenu.addItem(deleteItem)
    self.manageSubmenu.isHidden = false
  }
}

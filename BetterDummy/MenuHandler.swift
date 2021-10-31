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
  let manageSubmenu = NSMenuItem(title: "Manage Dummies", action: nil, keyEquivalent: "")
  let startAtLoginMenuItem = NSMenuItem(title: "Start at Login", action: #selector(app.handleStartAtLogin(_:)), keyEquivalent: "")
  let automaticallyCheckForUpdatesMenuItem = NSMenuItem(title: "Automatically Check for Updates", action: #selector(app.handleAutomaticallyCheckForUpdates(_:)), keyEquivalent: "")
  let reconnectAfterSleepMenuItem = NSMenuItem(title: "Disconnect and Reconnect on Sleep", action: #selector(app.handleReconnectAfterSleep(_:)), keyEquivalent: "")

  func setupMenu() {
    let newMenu = NSMenu()
    let newSubmenu = NSMenuItem(title: "Create New Dummy", action: nil, keyEquivalent: "")
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
    let updateItem = NSMenuItem(title: "Check for Updates...", action: #selector(app.updaterController.checkForUpdates(_:)), keyEquivalent: "")
    updateItem.target = app.updaterController
    self.appMenu.addItem(updateItem)
    self.appMenu.addItem(NSMenuItem(title: "About BetterDummy", action: #selector(app.handleAbout(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem(title: "Contribute...", action: #selector(app.handleDonate(_:)), keyEquivalent: ""))
    self.appMenu.addItem(NSMenuItem.separator())
    self.appMenu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    self.populateNewMenu(newMenu)
    self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
    if let button = self.statusBarItem.button {
      button.image = NSImage(named: "status")
    }
    self.statusBarItem.menu = self.appMenu
  }

  func populateNewMenu(_ newMenu: NSMenu) {
    for key in DummyDefinition.dummyDefinitions.keys.sorted() {
      if let dummyDefinition = DummyDefinition.dummyDefinitions[key] {
        let item = NSMenuItem(title: "\(dummyDefinition.description)", action: #selector(app.handleCreateDummy(_:)), keyEquivalent: "")
        item.tag = key
        newMenu.addItem(item)
      }
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
    var first = true
    for key in app.dummies.keys.sorted(by: <) {
      if let dummy = app.dummies[key] {
        if !first {
          self.manageMenu.addItem(NSMenuItem.separator())
        }
        self.addDummyToManageMenu(dummy)
        first = false
      }
    }
  }

  func addDummyToManageMenu(_ dummy: Dummy) {
    let dummyHeaderItem = NSMenuItem()
    let attrsHeader: [NSAttributedString.Key: Any] = [.foregroundColor: NSColor.headerTextColor, .font: NSFont.boldSystemFont(ofSize: 13)]
    dummyHeaderItem.attributedTitle = NSAttributedString(string: "\(dummy.getMenuItemTitle())", attributes: attrsHeader)
    self.manageMenu.addItem(dummyHeaderItem)
    var disconnectDisconnectItem: NSMenuItem
    if dummy.isConnected {
      disconnectDisconnectItem = NSMenuItem(title: "Disconnect Dummy", action: #selector(app.handleDisconnectDummy(_:)), keyEquivalent: "")
    } else {
      disconnectDisconnectItem = NSMenuItem(title: "Connect Dummy", action: #selector(app.handleConnectDummy(_:)), keyEquivalent: "")
    }
    disconnectDisconnectItem.tag = dummy.number
    let deleteItem = NSMenuItem(title: "Discard Dummy", action: #selector(app.handleDiscardDummy(_:)), keyEquivalent: "")
    deleteItem.tag = dummy.number
    self.manageMenu.addItem(disconnectDisconnectItem)
    self.manageMenu.addItem(deleteItem)
    self.manageSubmenu.isHidden = false
  }
}

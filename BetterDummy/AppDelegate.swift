//
//  AppDelegate.swift
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import os.log
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
        
    var dummyCounter: Int = 0
    var dummies = [Int: Dummy]()
    var statusBarItem: NSStatusItem!
    var sleepTemporaryDisplay: Any?
    let manageMenu = NSMenu()
    let manageSubmenu = NSMenuItem(title: "Manage Dummy", action: nil, keyEquivalent: "")
    let startAtLoginMenuItem = NSMenuItem(title: "Start at Login", action: #selector(handleStartAtLogin(_:)), keyEquivalent: "")
    let reconnectAfterSleepMenuItem = NSMenuItem(title: "Disconnect and Reconnect After Sleep", action: #selector(handleReconnectAfterSleep(_:)), keyEquivalent: "")
    let prefs = UserDefaults.standard

    // MARK: *** Setup app
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        app = self
        setupMenu()
        restoreSettings()
        setupNotifications()
    }

    func setupNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleSleepNotification), name: NSWorkspace.screensDidSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleSleepNotification), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleWakeNotification), name: NSWorkspace.screensDidWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleWakeNotification), name: NSWorkspace.didWakeNotification, object: nil)
    }
    
    // MARK: *** Menus

    func setupMenu() {
        let newMenu = NSMenu()
        populateNewMenu(newMenu)
        let newSubmenu = NSMenuItem(title: "Create Dummy", action: nil, keyEquivalent: "")
        newSubmenu.submenu = newMenu
        manageSubmenu.submenu = manageMenu
        manageSubmenu.isHidden = true
        let menu = NSMenu()
        let settingsMenu = NSMenu()
        settingsMenu.addItem(startAtLoginMenuItem)
        settingsMenu.addItem(reconnectAfterSleepMenuItem)
        let settingsSubmenu = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
        settingsSubmenu.submenu = settingsMenu
        menu.addItem(newSubmenu)
        menu.addItem(manageSubmenu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(settingsSubmenu)
        menu.addItem(NSMenuItem(title: "About BetterDummy", action: #selector(handleAbout(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Visit GitHub Page", action: #selector(handleVisitGithubPage(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
             button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "BetterDummy")
        }
        statusBarItem.menu = menu
    }
    
    func populateNewMenu(_ newMenu: NSMenu) {
        var i = 0
        for displayDefinition in DummyDefinition.dummyDefinitions {
            let item = NSMenuItem(title: "\(displayDefinition.description)", action: #selector(handleCreateDummy(_:)), keyEquivalent: "")
            item.tag = i
            newMenu.addItem(item)
            i += 1
        }
        os_log("New dummy menu populated.", type: .info)
    }
    
    func repopulateManageMenu() {
        var items: [NSMenuItem] = []
        for i in 0 ..< manageMenu.items.count {
            items.append(manageMenu.items[i])
        }
        for item in items {
            manageMenu.removeItem(item)
        }
        for i in dummies.keys {
            if let dummy = dummies[i] {
                addDummyToManageMenu(dummy)
            }
        }
    }
    
    func addDummyToManageMenu(_ dummy: Dummy) {
        // MARK: TODO: Make manage menu look better
        var disconnectDisconnectItem: NSMenuItem
        if dummy.isConnected {
            disconnectDisconnectItem = NSMenuItem(title: "\(dummy.getMenuItemTitle()) - Disconnect", action: #selector(app.handleDisconnectDummy(_:)), keyEquivalent: "")
        } else {
            disconnectDisconnectItem = NSMenuItem(title: "\(dummy.getMenuItemTitle()) - Connect", action: #selector(app.handleConnectDummy(_:)), keyEquivalent: "")
        }
        disconnectDisconnectItem.tag = dummy.number
        let deleteItem = NSMenuItem(title: "\(dummy.getMenuItemTitle()) - Discard", action: #selector(app.handleDiscardDummy(_:)), keyEquivalent: "")
        deleteItem.tag = dummy.number
        app.manageMenu.addItem(disconnectDisconnectItem)
        app.manageMenu.addItem(deleteItem)
        app.manageSubmenu.isHidden = false
    }
    
    func processCreatedDummy(_ dummy: Dummy) {
        dummies[dummy.number] = dummy
        addDummyToManageMenu(dummy)
        dummyCounter += 1
    }
    
    // MARK: *** Save and restore
    
    func saveSettings() {
        if let bundleID = Bundle.main.bundleIdentifier {
            prefs.removePersistentDomain(forName: bundleID)
            os_log("Preferences wiped.", type: .info)
        }
        guard dummies.count > 0 else {
            return
        }
        prefs.set(Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1, forKey: PrefKeys.buildNumber.rawValue)
        prefs.set(startAtLoginMenuItem.state == .on, forKey: PrefKeys.startAtLogin.rawValue)
        prefs.set(reconnectAfterSleepMenuItem.state == .on, forKey: PrefKeys.reconnectAfterSleep.rawValue)
        prefs.set(dummies.count, forKey: PrefKeys.numOfDummyDisplays.rawValue)
        var i = 1
        for virtualDisplay in dummies {
            prefs.set(virtualDisplay.value.dummyDefinitionItem, forKey: "\(PrefKeys.display.rawValue)\(i)")
            prefs.set(virtualDisplay.value.serialNum, forKey: "\(PrefKeys.serial.rawValue)\(i)")
            prefs.set(virtualDisplay.value.isConnected, forKey: "\(PrefKeys.isConnected.rawValue)\(i)")
            i += 1
        }
        os_log("Preferences stored.", type: .info)
    }

    func restoreSettings() {
        os_log("Restoring settings.", type: .info)
        // startAtLoginMenuItem.state = false ? .on : .off // MARK: TODO: Implement auto-start
        reconnectAfterSleepMenuItem.state = prefs.bool(forKey: PrefKeys.reconnectAfterSleep.rawValue) ? .on : .off
        guard prefs.integer(forKey: "numOfDummyDisplays") > 0 else {
            return
        }
        for i in 1 ... prefs.integer(forKey: PrefKeys.numOfDummyDisplays.rawValue) where prefs.object(forKey: "\(PrefKeys.display.rawValue)\(i)") != nil {
            let dummy = Dummy(number: dummyCounter, dummyDefinitionItem: prefs.integer(forKey: "\(PrefKeys.display.rawValue)\(i)"), serialNum: UInt32(prefs.integer(forKey: "\(PrefKeys.serial.rawValue)\(i)")), doConnect: prefs.bool(forKey: "\(PrefKeys.isConnected.rawValue)\(i)"))
            processCreatedDummy(dummy)
        }
    }
    
    // MARK: *** Handlers
    
    @objc func handleCreateDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem, menuItem.tag >= 0, menuItem.tag < DummyDefinition.dummyDefinitions.count {
            os_log("Connecting display tagged in new menu as %{public}@", type: .info, "\(menuItem.tag)")
            let dummy = Dummy(number: dummyCounter, dummyDefinitionItem: menuItem.tag)
            if dummy.isConnected {
                processCreatedDummy(dummy)
                app.saveSettings()
            } else {
                os_log("Discarding new dummy tagged as %{public}@", type: .info, "\(menuItem.tag)")
            }
        }
    }

    @objc func handleDisconnectDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            os_log("Disconnecting display tagged in delete menu as %{public}@", type: .info, "\(menuItem.tag)")
            dummies[menuItem.tag]?.disconnect()
            self.repopulateManageMenu()
            saveSettings()
        }
    }
    
    @objc func handleConnectDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            os_log("Connecting display tagged in delete menu as %{public}@", type: .info, "\(menuItem.tag)")
            if let dummy = dummies[menuItem.tag] {
                if !dummy.connect() {
                    let alert = NSAlert()
                    alert.messageText = "Unable to Connect Dummy"
                    alert.informativeText = "An error occured during connecting Dummy."
                    alert.runModal()
                }
            }
            self.repopulateManageMenu()
            saveSettings()
        }
    }
    
    @objc func handleDiscardDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            os_log("Removing display tagged in manage menu as %{public}@", type: .info, "\(menuItem.tag)")
            dummies[menuItem.tag] = nil
            self.repopulateManageMenu()
            saveSettings()
            if dummies.count == 0 {
                manageSubmenu.isHidden = true
            }
        }
    }
    
    @objc func handleStartAtLogin(_ sender: NSMenuItem) {
        // MARK: TODO: Implement Start at Login
    }

    @objc func handleReconnectAfterSleep(_ sender: AnyObject?) {
        reconnectAfterSleepMenuItem.state = reconnectAfterSleepMenuItem.state == .on ? .off : .on
        saveSettings()
    }
    
    @objc func handleAbout(_ sender: AnyObject?) {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "UNKNOWN"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "UNKNOWN"
        let year = Calendar.current.component(.year, from: Date())
        let alert = NSAlert()
        alert.messageText = "About BetterDummy"
        alert.informativeText = "Version \(version) Build \(build)\n\nCopyright Ⓒ \(year) @waydabber. \nMIT Licensed, feel free to improve.\nContact me on the GitHub page if you want to help out. :)"
        alert.runModal()
    }
    
    @objc func handleVisitGithubPage(_ sender: AnyObject?) {
        if let url = URL(string: "https://github.com/waydabber/BetterDummy#readme") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func handleWakeNotification() {
        os_log("Wake intercepted, removing temporary display if there is any.", type: .info)
        sleepTemporaryDisplay = nil
        if reconnectAfterSleepMenuItem.state == .on {
            os_log("Disconnecting and reconnecting dummies.", type: .info)
            for i in dummies.keys {
                if let dummy = dummies[i], dummy.isConnected {
                    dummy.disconnect()
                    _ = dummy.connect()
                }
             }
        }
    }

    @objc func handleSleepNotification() {
        if dummies.count > 0 {
            sleepTemporaryDisplay = Dummy.createVirtualDisplay(DummyDefinition(1920,1080, 1, 1, 1, [60], "Dummy Temp"), name: "Dummy Temp", serialNum: 0)
            os_log("Sleep intercepted, created temporary display.", type: .info)
            // Note: for some reason, if we create a transient virtual display on sleep, the sleep proceeds as normal. This is a result of some trial & error and might not work on all systems.
        }
    }
    
}

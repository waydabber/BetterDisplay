//
//  AppDelegate.swift
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import os.log

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var dummyCounter: Int = 0
    var dummies = [Int: Dummy]()
    var statusBarItem: NSStatusItem!
    var sleepTemporaryDisplay: Any?
    let deleteMenu = NSMenu()
    let deleteSubmenu = NSMenuItem(title: "Delete Dummy", action: nil, keyEquivalent: "")
    let prefs = UserDefaults.standard

    // MARK: Setup app
    
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
    
    // MARK: Menus

    func setupMenu() {
        let newMenu = NSMenu()
        populateNewMenu(newMenu)
        let newSubmenu = NSMenuItem(title: "Create Dummy", action: nil, keyEquivalent: "")
        newSubmenu.submenu = newMenu
        deleteSubmenu.submenu = deleteMenu
        deleteSubmenu.isHidden = true
        let menu = NSMenu()
        menu.addItem(newSubmenu)
        menu.addItem(deleteSubmenu)
        menu.addItem(NSMenuItem.separator())
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
    
    func processCreatedDummy(_ dummy: Dummy) {
        dummies[dummy.number] = dummy
        let menuItem = NSMenuItem(title: dummy.getMenuItemTitle(), action: #selector(app.handleDestroyDummy(_:)), keyEquivalent: "")
        menuItem.tag = dummy.number
        app.deleteMenu.addItem(menuItem)
        app.deleteSubmenu.isHidden = false
        dummyCounter += 1
    }
    
    // MARK: Save and restore
    
    func saveSettings() {
        if let bundleID = Bundle.main.bundleIdentifier {
            prefs.removePersistentDomain(forName: bundleID)
            os_log("Preferences wiped.", type: .info)
        }
        guard dummies.count > 0 else {
            return
        }
        prefs.set(dummies.count, forKey: "numOfDummyDisplays")
        prefs.set(Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1, forKey: "buildNumber")
        var i = 1
        for virtualDisplay in dummies {
            prefs.set(virtualDisplay.value.dummyDefinitionItem, forKey: "Display\(i)")
            prefs.set(virtualDisplay.value.serialNum, forKey: "Serial\(i)")
            i += 1
        }
        os_log("Preferences stored.", type: .info)
    }

    func restoreSettings() {
        os_log("Restoring settings.", type: .info)
        guard prefs.integer(forKey: "numOfDummyDisplays") > 0 else {
            return
        }
        for i in 1 ... prefs.integer(forKey: "numOfDummyDisplays") where prefs.object(forKey: "Display\(i)") != nil {
            let dummy = Dummy(number: dummyCounter, dummyDefinitionItem: prefs.integer(forKey: "Display\(i)"), serialNum: UInt32(prefs.integer(forKey: "Serial\(i)")))
            if dummy.isConnected {
                processCreatedDummy(dummy)
            }
        }
    }
    
    // MARK: Handlers
    
    @objc func handleCreateDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem, menuItem.tag >= 0, menuItem.tag < DummyDefinition.dummyDefinitions.count {
            os_log("Connecting display tagged in new menu as %{public}@", type: .info, "\(menuItem.tag)")
            let dummy = Dummy(number: dummyCounter, dummyDefinitionItem: menuItem.tag)
            if dummy.isConnected {
                processCreatedDummy(dummy)
                app.saveSettings()
            }
        }
    }
    
    @objc func handleDestroyDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            os_log("Removing display  tagged in delete menu as %{public}@", type: .info, "\(menuItem.tag)")
            dummies[menuItem.tag] = nil
            menuItem.menu?.removeItem(menuItem)
            saveSettings()
            if dummies.count == 0 {
                deleteSubmenu.isHidden = true
            }
        }
    }
    
    @objc func handleAbout(_ sender: AnyObject?) {
        let alert = NSAlert()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "UNKNOWN"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "UNKNOWN"
        let year = Calendar.current.component(.year, from: Date())
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
    }

    @objc func handleSleepNotification() {
        if dummies.count > 0 {
            sleepTemporaryDisplay = Dummy.createVirtualDisplay(DummyDefinition(3840,2160, 1, 1, 1, [60], "Dummy Temp"), name: "Dummy Temp", serialNum: 1)
            os_log("Sleep intercepted, created temporary display.", type: .info)
            // Note: for some reason, if we create a transient virtual display on sleep, the sleep proceeds as normal. This is a result of some trial & error and might not work on all systems.
        }
    }
    
}

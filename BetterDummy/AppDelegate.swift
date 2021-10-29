//
//  AppDelegate.swift
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import os.log
import ServiceManagement
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
  var dummyCounter: Int = 0
  var dummies = [Int: Dummy]()
  var sleepTemporaryDisplay: Any?
  var isSleep: Bool = false
  let prefs = UserDefaults.standard
  let updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: UpdaterDelegate(), userDriverDelegate: nil)
  let menu = MenuHandler()

  // MARK: *** Setup app

  @available(macOS, deprecated: 10.10)
  func applicationDidFinishLaunching(_: Notification) {
    app = self
    self.menu.setupMenu()
    self.setDefaultPrefs()
    self.restoreSettings()
    self.setupNotifications()
    self.updaterController.startUpdater()
  }

  func setupNotifications() {
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleSleepNotification), name: NSWorkspace.screensDidSleepNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleSleepNotification), name: NSWorkspace.willSleepNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleWakeNotification), name: NSWorkspace.screensDidWakeNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleWakeNotification), name: NSWorkspace.didWakeNotification, object: nil)
  }

  // MARK: *** Save and restore

  func setDefaultPrefs() {
    if !self.prefs.bool(forKey: PrefKeys.appAlreadyLaunched.rawValue) {
      self.prefs.set(true, forKey: PrefKeys.appAlreadyLaunched.rawValue)
      self.prefs.set(true, forKey: PrefKeys.SUEnableAutomaticChecks.rawValue)
    }
  }

  func saveSettings() {
    if let bundleID = Bundle.main.bundleIdentifier {
      self.prefs.removePersistentDomain(forName: bundleID)
      os_log("Preferences wiped.", type: .info)
    }
    guard self.dummies.count > 0 else {
      return
    }
    self.prefs.set(true, forKey: PrefKeys.appAlreadyLaunched.rawValue)
    self.prefs.set(self.menu.automaticallyCheckForUpdatesMenuItem.state == .on, forKey: PrefKeys.SUEnableAutomaticChecks.rawValue)
    self.prefs.set(Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1, forKey: PrefKeys.buildNumber.rawValue)
    self.prefs.set(self.menu.startAtLoginMenuItem.state == .on, forKey: PrefKeys.startAtLogin.rawValue)
    self.prefs.set(self.menu.reconnectAfterSleepMenuItem.state == .on, forKey: PrefKeys.reconnectAfterSleep.rawValue)
    self.prefs.set(self.dummies.count, forKey: PrefKeys.numOfDummyDisplays.rawValue)
    var i = 1
    for virtualDisplay in self.dummies {
      self.prefs.set(virtualDisplay.value.dummyDefinitionItem, forKey: "\(PrefKeys.display.rawValue)\(i)")
      self.prefs.set(virtualDisplay.value.serialNum, forKey: "\(PrefKeys.serial.rawValue)\(i)")
      self.prefs.set(virtualDisplay.value.isConnected, forKey: "\(PrefKeys.isConnected.rawValue)\(i)")
      i += 1
    }
    os_log("Preferences stored.", type: .info)
  }

  @available(macOS, deprecated: 10.10)
  func restoreSettings() {
    os_log("Restoring settings.", type: .info)
    let startAtLogin = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]])?.first { $0["Label"] as? String == "\(Bundle.main.bundleIdentifier!)Helper" }?["OnDemand"] as? Bool ?? false
    self.menu.startAtLoginMenuItem.state = startAtLogin ? .on : .off
    self.menu.automaticallyCheckForUpdatesMenuItem.state = self.prefs.bool(forKey: PrefKeys.SUEnableAutomaticChecks.rawValue) ? .on : .off
    self.menu.reconnectAfterSleepMenuItem.state = self.prefs.bool(forKey: PrefKeys.reconnectAfterSleep.rawValue) ? .on : .off
    guard self.prefs.integer(forKey: "numOfDummyDisplays") > 0 else {
      return
    }
    for i in 1 ... self.prefs.integer(forKey: PrefKeys.numOfDummyDisplays.rawValue) where self.prefs.object(forKey: "\(PrefKeys.display.rawValue)\(i)") != nil {
      let dummy = Dummy(number: dummyCounter, dummyDefinitionItem: prefs.integer(forKey: "\(PrefKeys.display.rawValue)\(i)"), serialNum: UInt32(prefs.integer(forKey: "\(PrefKeys.serial.rawValue)\(i)")), doConnect: prefs.bool(forKey: "\(PrefKeys.isConnected.rawValue)\(i)"))
      processCreatedDummy(dummy)
    }
  }

  // MARK: *** Handlers

  func processCreatedDummy(_ dummy: Dummy) {
    self.dummies[dummy.number] = dummy
    self.menu.addDummyToManageMenu(dummy)
    self.dummyCounter += 1
  }

  @objc func handleCreateDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem, menuItem.tag >= 0, menuItem.tag < DummyDefinition.dummyDefinitions.count {
      os_log("Connecting display tagged in new menu as %{public}@", type: .info, "\(menuItem.tag)")
      let dummy = Dummy(number: dummyCounter, dummyDefinitionItem: menuItem.tag)
      if dummy.isConnected {
        self.processCreatedDummy(dummy)
        app.saveSettings()
      } else {
        os_log("Discarding new dummy tagged as %{public}@", type: .info, "\(menuItem.tag)")
      }
    }
  }

  @objc func handleDisconnectDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      os_log("Disconnecting display tagged in delete menu as %{public}@", type: .info, "\(menuItem.tag)")
      self.dummies[menuItem.tag]?.disconnect()
      self.menu.repopulateManageMenu()
      self.saveSettings()
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
      self.menu.repopulateManageMenu()
      self.saveSettings()
    }
  }

  @objc func handleDiscardDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      os_log("Removing display tagged in manage menu as %{public}@", type: .info, "\(menuItem.tag)")
      self.dummies[menuItem.tag] = nil
      self.menu.repopulateManageMenu()
      self.saveSettings()
      if self.dummies.count == 0 {
        self.menu.manageSubmenu.isHidden = true
      }
    }
  }

  @objc func handleStartAtLogin(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    let identifier = "\(Bundle.main.bundleIdentifier!)Helper" as CFString
    SMLoginItemSetEnabled(identifier, sender.state == .on ? true : false)
  }

  @objc func handleReconnectAfterSleep(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    self.saveSettings()
  }

  @objc func handleAutomaticallyCheckForUpdates(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    self.saveSettings()
  }

  @objc func handleAbout(_: AnyObject?) {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "UNKNOWN"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "UNKNOWN"
    let year = Calendar.current.component(.year, from: Date())
    let alert = NSAlert()
    alert.messageText = "About BetterDummy"
    alert.informativeText = "Version \(version) Build \(build)\n\nCopyright Ⓒ \(year) @waydabber. \nMIT Licensed, feel free to improve.\n\nCheck out the GitHub page for instructions or to report issues!"
    alert.addButton(withTitle: "Visit GitHub page")
    alert.addButton(withTitle: "OK")
    alert.alertStyle = NSAlert.Style.informational
    if alert.runModal() == .alertFirstButtonReturn {
      if let url = URL(string: "https://github.com/waydabber/BetterDummy#readme") {
        NSWorkspace.shared.open(url)
      }
    }
  }

  @objc func handleDonate(_: NSMenuItem) {
    let alert = NSAlert()
    alert.messageText = "Would you like to help out?"
    alert.informativeText = "If you find the app useful, please consider supporting the developer. :) Thank you!"
    alert.addButton(withTitle: "Of course!")
    alert.addButton(withTitle: "Not this time.")
    if alert.runModal() == .alertFirstButtonReturn {
      if let url = URL(string: "https://opencollective.com/betterdummy/donate") {
        NSWorkspace.shared.open(url)
      }
    }
  }

  @objc func handleWakeNotification() {
    guard self.isSleep else {
      return
    }
    self.isSleep = false
    os_log("Wake intercepted, removing temporary display if there is any.", type: .info)
    self.sleepTemporaryDisplay = nil
    if self.menu.reconnectAfterSleepMenuItem.state == .on {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        self.asyncWakeReconnect()
      }
    }
  }

  func asyncWakeReconnect() {
    guard !self.isSleep else {
      return
    }
    os_log("Reconnecting dummies on wake.", type: .info)
    for i in self.dummies.keys {
      if let dummy = dummies[i], !dummy.isConnected {
        _ = dummy.connect(sleepConnect: true)
      }
    }
  }

  @objc func handleSleepNotification() {
    guard !self.isSleep else {
      return
    }
    self.isSleep = true
    if self.dummies.count > 0 {
      self.sleepTemporaryDisplay = Dummy.createVirtualDisplay(DummyDefinition(1920, 1080, 1, 1, 1, [60], "Dummy Temp"), name: "Dummy Temp", serialNum: 0)
      os_log("Sleep intercepted, created temporary display.", type: .info)
      // Note: for some reason, if we create a transient virtual display on sleep, the sleep proceeds as normal. This is a result of some trial & error and might not work on all systems.
    }
    if self.menu.reconnectAfterSleepMenuItem.state == .on {
      os_log("Disconnecting dummies on sleep.", type: .info)
      for i in self.dummies.keys {
        if let dummy = dummies[i], dummy.isConnected {
          dummy.disconnect(sleepDisconnect: true)
        }
      }
    }
  }
}

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
  var sleepTemporaryDisplay: CGVirtualDisplay?
  var isSleep: Bool = false
  let updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: UpdaterDelegate(), userDriverDelegate: nil)
  let menu = MenuHandler()

  // MARK: *** Setup app

  @available(macOS, deprecated: 10.10)
  func applicationDidFinishLaunching(_: Notification) {
    app = self
    DummyDefinition.updateDummyDefinitions()
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
    if !prefs.bool(forKey: PrefKeys.appAlreadyLaunched.rawValue) {
      prefs.set(true, forKey: PrefKeys.appAlreadyLaunched.rawValue)
      prefs.set(true, forKey: PrefKeys.SUEnableAutomaticChecks.rawValue)
      os_log("Setting default preferences.", type: .info)
    }
  }

  func saveSettings() {
    guard self.dummies.count > 0 else {
      return
    }
    prefs.set(true, forKey: PrefKeys.appAlreadyLaunched.rawValue)
    prefs.set(self.menu.automaticallyCheckForUpdatesMenuItem.state == .on, forKey: PrefKeys.SUEnableAutomaticChecks.rawValue)
    prefs.set(Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1, forKey: PrefKeys.buildNumber.rawValue)
    prefs.set(self.menu.startAtLoginMenuItem.state == .on, forKey: PrefKeys.startAtLogin.rawValue)
    prefs.set(self.menu.enable16KMenuItem.state == .on, forKey: PrefKeys.enable16K.rawValue)
    prefs.set(self.menu.reconnectAfterSleepMenuItem.state == .on, forKey: PrefKeys.reconnectAfterSleep.rawValue)
    prefs.set(self.menu.useTempSleepMenuItem.state == .off, forKey: PrefKeys.disableTempSleep.rawValue)
    prefs.set(self.dummies.count, forKey: PrefKeys.numOfDummyDisplays.rawValue)
    var i = 1
    for dummy in self.dummies {
      prefs.set(dummy.value.dummyDefinitionItem, forKey: "\(PrefKeys.display.rawValue)\(i)")
      prefs.set(dummy.value.serialNum, forKey: "\(PrefKeys.serial.rawValue)\(i)")
      prefs.set(dummy.value.isConnected, forKey: "\(PrefKeys.isConnected.rawValue)\(i)")
      i += 1
    }
    os_log("Preferences stored.", type: .info)
  }

  @available(macOS, deprecated: 10.10)
  func restoreSettings() {
    os_log("Restoring settings.", type: .info)
    let startAtLogin = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]])?.first { $0["Label"] as? String == "\(Bundle.main.bundleIdentifier!)Helper" }?["OnDemand"] as? Bool ?? false
    self.menu.startAtLoginMenuItem.state = startAtLogin ? .on : .off
    self.menu.automaticallyCheckForUpdatesMenuItem.state = prefs.bool(forKey: PrefKeys.SUEnableAutomaticChecks.rawValue) ? .on : .off
    self.menu.enable16KMenuItem.state = prefs.bool(forKey: PrefKeys.enable16K.rawValue) ? .on : .off
    self.menu.reconnectAfterSleepMenuItem.state = prefs.bool(forKey: PrefKeys.reconnectAfterSleep.rawValue) ? .on : .off
    self.menu.useTempSleepMenuItem.state = !prefs.bool(forKey: PrefKeys.disableTempSleep.rawValue) ? .on : .off
    guard prefs.integer(forKey: "numOfDummyDisplays") > 0 else {
      return
    }
    for i in 1 ... prefs.integer(forKey: PrefKeys.numOfDummyDisplays.rawValue) where prefs.object(forKey: "\(PrefKeys.display.rawValue)\(i)") != nil {
      let dummy = Dummy(number: dummyCounter, dummyDefinitionItem: prefs.integer(forKey: "\(PrefKeys.display.rawValue)\(i)"), serialNum: UInt32(prefs.integer(forKey: "\(PrefKeys.serial.rawValue)\(i)")), doConnect: prefs.bool(forKey: "\(PrefKeys.isConnected.rawValue)\(i)"))
      processCreatedDummy(dummy)
    }
  }

  // MARK: *** Handlers

  func processCreatedDummy(_ dummy: Dummy) {
    self.dummies[dummy.number] = dummy
    self.dummyCounter += 1
    self.menu.repopulateManageMenu()
  }

  @objc func handleCreateDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
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
          alert.alertStyle = .warning
          alert.messageText = "Unable to Connect Dummy"
          alert.informativeText = "An error occured during connecting Dummy."
          alert.runModal()
        }
      }
      self.menu.repopulateManageMenu()
      self.saveSettings()
    }
  }

  @objc func handleResolution(_: AnyObject?) {
    // TODO: Implement handle resolution change
  }

  @objc func handleAssociate(_: AnyObject?) {
    // TODO: Implement handle display association
  }

  @objc func handleDisassociate(_: AnyObject?) {
    // TODO: Implement handle display disassociation
  }

  @objc func handleDiscardDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Do you want to discard Dummy?"
      alert.informativeText = "If you would like to use a Dummy later, use disconnect so macOS display configuration data is preserved."
      alert.addButton(withTitle: "Cancel")
      alert.addButton(withTitle: "Discard")
      if alert.runModal() == .alertSecondButtonReturn {
        os_log("Removing display tagged in manage menu as %{public}@", type: .info, "\(menuItem.tag)")
        self.dummies[menuItem.tag] = nil
        self.menu.repopulateManageMenu()
        self.saveSettings()
        if self.dummies.count == 0 {
          self.menu.manageSubmenu.isHidden = true
        }
      }
    }
  }

  @objc func handleStartAtLogin(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    let identifier = "\(Bundle.main.bundleIdentifier!)Helper" as CFString
    SMLoginItemSetEnabled(identifier, sender.state == .on ? true : false)
  }

  @available(macOS, deprecated: 10.10)
  @objc func handleReset(_: NSMenuItem) {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "Are sure you want to reset BetterDummy?"
    alert.informativeText = "This restores the default settings and discards all dummies."
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Reset")
    if alert.runModal() == .alertSecondButtonReturn {
      for key in self.dummies.keys {
        self.dummies[key] = nil
      }
      self.menu.emptyManageMenu()
      os_log("Cleared dummies.", type: .info)
      if let bundleID = Bundle.main.bundleIdentifier {
        prefs.removePersistentDomain(forName: bundleID)
      }
      os_log("Preferences reset complete.", type: .info)
      self.setDefaultPrefs()
      self.restoreSettings()
    }
  }

  @objc func handleSimpleCheckMenu(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    self.saveSettings()
  }

  @objc func handleEnable16K(_ sender: NSMenuItem) {
    if sender.state == .off {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Are you sure to enable 16K?"
      alert.informativeText = "Using dummies over 8K can greatly reduce performance."
      alert.addButton(withTitle: "Cancel")
      alert.addButton(withTitle: "Enable")
      if alert.runModal() == .alertFirstButtonReturn {
        return
      }
    }
    sender.state = sender.state == .on ? .off : .on
    self.saveSettings()
    DummyDefinition.updateDummyDefinitions()
    for dummy in self.dummies.values where dummy.isConnected {
      dummy.disconnect()
      _ = dummy.connect()
    }
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
    alert.informativeText = "If you find this app useful, please consider supporting the project with a financial contribution. :)"
    alert.addButton(withTitle: "Yes!")
    alert.addButton(withTitle: "Nope")
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
    self.sleepTemporaryDisplay = nil
    os_log("Wake intercepted, removed temporary display if present.", type: .info)
    self.isSleep = false
    if prefs.bool(forKey: PrefKeys.reconnectAfterSleep.rawValue) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
        self.delayedWakeReconnect()
      }
    }
  }

  func delayedWakeReconnect() {
    guard !self.isSleep else {
      return
    }
    os_log("Delayed reconnecting dummies after wake.", type: .info)
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
    if self.dummies.count > 0, !prefs.bool(forKey: PrefKeys.disableTempSleep.rawValue) {
      self.sleepTemporaryDisplay = Dummy.createVirtualDisplay(DummyDefinition(1920, 1080, 1, 1, 1, [60], "Dummy Temp", false), name: "Dummy Temp", serialNum: 0)
      os_log("Sleep intercepted, created temporary display.", type: .info)
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

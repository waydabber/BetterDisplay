//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import os.log
import ServiceManagement
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate, SPUUpdaterDelegate {
  var isSleep: Bool = false
  var reconfigureID: Int = 0
  var skipReconfiguration = false
  let updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: UpdaterDelegate(), userDriverDelegate: nil)
  let menu = AppMenu()

  // MARK: *** Setup app

  func applicationDidFinishLaunching(_: Notification) {
    app = self
    DummyManager.updateDummyDefinitions()
    self.menu.setupMenu()
    self.setDefaultPrefs()
    DummyManager.restoreDummiesFromPrefs()
    self.updaterController.startUpdater()
    self.displayReconfiguration(force: true)

    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.sleepNotification), name: NSWorkspace.screensDidSleepNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.sleepNotification), name: NSWorkspace.willSleepNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.wakeNotification), name: NSWorkspace.screensDidWakeNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.wakeNotification), name: NSWorkspace.didWakeNotification, object: nil)
    CGDisplayRegisterReconfigurationCallback({ _, _, _ in app.displayReconfiguration() }, nil)
  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    let alert = NSAlert()
    alert.alertStyle = .informational
    alert.messageText = "BetterDummy is already running!"
    if prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue) || self.menu.statusBarItem.isVisible == false {
      self.menu.statusBarItem.isVisible = true
      prefs.set(true, forKey: PrefKey.hideMenuIcon.rawValue)
      DummyManager.storeDummesToPrefs()
      self.menu.populateSettingsMenu()
      alert.informativeText = "The menu icon was hidden but it is now set to visible. You can hide it again in Settings."
    } else {
      alert.informativeText = "To configure the app, use the BetterDummy menu icon in the macOS menu bar!"
    }
    alert.runModal()
    return true
  }

  func setDefaultPrefs() {
    if !prefs.bool(forKey: PrefKey.appAlreadyLaunched.rawValue) {
      prefs.set(true, forKey: PrefKey.appAlreadyLaunched.rawValue)
      prefs.set(true, forKey: PrefKey.SUEnableAutomaticChecks.rawValue)
      os_log("Setting default preferences.", type: .info)
    }
    prefs.set(Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1, forKey: PrefKey.buildNumber.rawValue)
  }

  func getStartAtLogin() -> Bool {
    (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]])?.first { $0["Label"] as? String == "\(Bundle.main.bundleIdentifier!)Helper" }?["OnDemand"] as? Bool ?? false
  }

  // MARK: *** Handlers - Specific dummy management

  @objc func createDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      os_log("Connecting dummy tagged in new menu as %{public}@", type: .info, "\(menuItem.tag)")
      if let number = DummyManager.createDummyByDefinitionId(menuItem.tag) {
        self.menu.populateAppMenu()
        DummyManager.storeDummesToPrefs()
        if let dummy = DummyManager.getDummyByNumber(number), dummy.isConnected {
          os_log("Dummy successfully created and connected.", type: .info)
        } else {
          os_log("There seems to be a problem with the created dummy.", type: .info)
        }
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Your new dummy was created and connected."
        alert.informativeText = "Use Displays under System Preferences to configure your new dummy display! You can use the Manage dummies menu item to manage your dummy."
        alert.runModal()
      } else {
        os_log("Could not create dummy using menu item tag number.", type: .info)
      }
    }
  }

  @objc func connectDummy(_ sender: AnyObject?) {
    if let controlItem = sender as? NSControl, let dummy = DummyManager.getDummyByNumber(controlItem.tag) {
      if !dummy.isConnected {
        os_log("Connecting dummy tagged in delete menu as %{public}@", type: .info, "\(controlItem.tag)")
        if dummy.hasAssociatedDisplay() {
          let alert = NSAlert()
          alert.alertStyle = .warning
          alert.messageText = "A dummy associated with a display cannot be manually connected!"
          alert.informativeText = "A dummy which is associated with a display will connect automatically when the associated display is connected."
          alert.runModal()
        } else {
          if !dummy.connect() {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Unable to connect dummy"
            alert.informativeText = "An error occured during connecting the dummy."
            alert.runModal()
          }
        }
      } else {
        os_log("Disconnecting dummy tagged in delete menu as %{public}@", type: .info, "\(controlItem.tag)")
        if dummy.hasAssociatedDisplay() {
          let alert = NSAlert()
          alert.alertStyle = .warning
          alert.messageText = "A dummy associated with a display cannot be manually disconnected!"
          alert.informativeText = "A dummy which is associated with a display will disconnect automatically when the associated display is disconnected."
          alert.runModal()
        } else {
          dummy.disconnect()
        }
      }
      self.menu.populateAppMenu()
      DummyManager.storeDummesToPrefs()
    }
  }

  @objc func discardDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Do you want to discard the dummy?"
      alert.informativeText = "If you would like to use a dummy later, use disconnect instead so macOS display configuration data is preserved."
      alert.addButton(withTitle: "Cancel")
      alert.addButton(withTitle: "Discard")
      if alert.runModal() == .alertSecondButtonReturn {
        os_log("Removing dummy tagged in manage menu as %{public}@", type: .info, "\(menuItem.tag)")
        DummyManager.discardDummyByNumber(menuItem.tag)
        self.menu.populateAppMenu()
        DummyManager.storeDummesToPrefs()
      }
    }
  }

  @objc func lowResolution(_: AnyObject?) {
    // TODO:
  }

  @objc func portrait(_: AnyObject?) {
    // TODO:
  }

  @objc func associateDummy(_ sender: NSMenuItem) {
    os_log("Received association request from tag %{public}@", type: .info, "\(sender.tag)")
    guard sender.tag != 0 else {
      return
    }
    let displayNumber = (sender.tag >> 8) & 0xFF
    let dummyNumber = sender.tag & 0xFF
    if let dummy = DummyManager.getDummyByNumber(dummyNumber), let display = DisplayManager.getDisplayByNumber(displayNumber) {
      dummy.associateDisplay(display: display)
      var askedForPermission = false
      for otherDummy in DummyManager.getDummies() where otherDummy != dummy {
        if otherDummy.hasAssociatedDisplay(), otherDummy.associatedDisplayPrefsId == dummy.associatedDisplayPrefsId {
          if askedForPermission {
            otherDummy.disassociateDisplay()
          } else {
            let alert = NSAlert()
            alert.alertStyle = .warning
            alert.messageText = "Disassociate and disconnect other associated dummies?"
            alert.informativeText = "At least one other dummy is associated with this display. To avoid confusion, it is best to avoid this situation."
            alert.addButton(withTitle: "Disassociate")
            alert.addButton(withTitle: "No")
            if alert.runModal() == .alertFirstButtonReturn {
              otherDummy.disassociateDisplay()
              otherDummy.disconnect()
              askedForPermission = true
            } else {
              break
            }
          }
        }
      }
      if !dummy.isConnected, DisplayManager.getDisplayByPrefsId(dummy.associatedDisplayPrefsId) != nil {
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "This dummy will now be connected."
        alert.informativeText = "The dummy is now associated with a display that is connected therefore the dummy will automtically connect."
        alert.runModal()
        _ = dummy.connect()
      }
      self.menu.populateAppMenu()
      DummyManager.storeDummesToPrefs()
    }
    _ = sender.tag
  }

  @objc func disassociateDummy(_ sender: NSMenuItem) {
    if let dummy = DummyManager.getDummyByNumber(sender.tag), dummy.hasAssociatedDisplay() {
      let associatedDisplayPrefsId = dummy.associatedDisplayPrefsId
      dummy.disassociateDisplay()
      if dummy.isConnected, DisplayManager.getDisplayByPrefsId(associatedDisplayPrefsId) != nil {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Do you want to disconnect the dummy as well?"
        alert.informativeText = "The dummy is now disassociated from a display but the dummy is still connected."
        alert.addButton(withTitle: "Disconnect")
        alert.addButton(withTitle: "No")
        if alert.runModal() == .alertFirstButtonReturn {
          dummy.disconnect()
        }
      }
      self.menu.populateAppMenu()
      DummyManager.storeDummesToPrefs()
    }
  }

  @objc func dummyResolution(_ sender: NSMenuItem) {
    os_log("Received resolution change from tag %{public}@", type: .info, "\(sender.tag)")
    guard sender.tag != 0 else {
      return
    }
    let dummyNumber = (sender.tag >> 16) & 0xFFFF
    let resolutionItemNumber = sender.tag & 0xFFFF
    os_log("- Resolution change dummy %{public}@", type: .info, "\(dummyNumber)")
    os_log("- Resolution change item %{public}@", type: .info, "\(resolutionItemNumber)")
    if let dummy = DummyManager.getDummyByNumber(dummyNumber), let display = DisplayManager.getDisplayById(dummy.displayIdentifier) {
      display.changeResolution(resolutionItemNumber: Int32(resolutionItemNumber))
    }
  }

  // MARK: *** Handlers - General dummy management

  @objc func connectAllDummies(_: AnyObject?) {
    os_log("Connecting all dummies.", type: .info)
    var hasAssociated = false
    for dummy in DummyManager.getDummies() where !dummy.isConnected {
      if !dummy.hasAssociatedDisplay() {
        _ = dummy.connect()
      } else {
        hasAssociated = true
      }
    }
    if hasAssociated {
      let alert = NSAlert()
      alert.alertStyle = .warning
      alert.messageText = "Dummies associated with displays cannot be manually connected!"
      alert.informativeText = "A dummy which is associated with a display will automatically connect when the associated display is connected. All other dummies were connected."
      alert.runModal()
    }
    self.menu.populateAppMenu()
    DummyManager.storeDummesToPrefs()
  }

  @objc func disconnectAllDummies(_: AnyObject?) {
    os_log("Disconnecting all dummies.", type: .info)
    var hasAssociated = false
    for dummy in DummyManager.getDummies() where dummy.isConnected {
      if !dummy.hasAssociatedDisplay() {
        dummy.disconnect()
      } else {
        hasAssociated = true
      }
    }
    if hasAssociated {
      let alert = NSAlert()
      alert.alertStyle = .warning
      alert.messageText = "Dummies associated with displays cannot be manually disconnected!"
      alert.informativeText = "A dummy which is associated with a display will automatically disconnect when the associated display is disconnected. All other dummies were disconnected."
      alert.runModal()
    }
    self.menu.populateAppMenu()
    DummyManager.storeDummesToPrefs()
  }

  @objc func discardAllDummies(_: AnyObject?) {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "Do you want to discard all dummies?"
    alert.informativeText = "If you would like to use the dummies later, it is better to use disconnect so macOS display configuration data is preserved."
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Discard")
    if alert.runModal() == .alertSecondButtonReturn {
      os_log("Removing dummies.", type: .info)
      DummyManager.discardAllDummies()
      self.menu.populateAppMenu()
      DummyManager.storeDummesToPrefs()
    }
  }

  @objc func disassociateAllDummies(_: AnyObject?) {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "Do you want to disassociate all dummies from all displays?"
    alert.informativeText = "Connected dummies will remain connected after this operation."
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Disassociate")
    if alert.runModal() == .alertSecondButtonReturn {
      os_log("Disassociating dummies.", type: .info)
      for dummy in DummyManager.getDummies() {
        dummy.disassociateDisplay()
        self.menu.populateAppMenu()
        DummyManager.storeDummesToPrefs()
      }
    }
  }

  // MARK: *** Handlers - Display reconfiguration

  @objc func displayReconfiguration(dispatchedReconfigureID: Int = 0, force: Bool = false) {
    guard !self.skipReconfiguration else {
      os_log("Display reconfiguration is forcefully skipped", type: .info)
      return
    }
    if !force, dispatchedReconfigureID == 0 || self.isSleep {
      self.reconfigureID += 1
      os_log("Bumping reconfigureID to %{public}@", type: .info, String(self.reconfigureID))
      if !self.isSleep {
        let dispatchedReconfigureID = self.reconfigureID
        os_log("Displays to be reconfigured with reconfigureID %{public}@", type: .info, String(dispatchedReconfigureID))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
          self.displayReconfiguration(dispatchedReconfigureID: dispatchedReconfigureID)
        }
      }
    } else if dispatchedReconfigureID == self.reconfigureID || force {
      os_log("Request for display configuration with reconfigreID %{public}@", type: .info, String(dispatchedReconfigureID))
      self.reconfigureID = 0
      DisplayManager.configureDisplays()
      DisplayManager.addDisplayCounterSuffixes()
      DummyManager.connectDisconnectAssociatedDummies()
      self.menu.populateAppMenu()
      DummyManager.storeDummesToPrefs()
    }
  }

  // MARK: *** Handlers - Settings

  @objc func startAtLogin(_: AnyObject?) {
    let startAtLogin = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]])?.first { $0["Label"] as? String == "\(Bundle.main.bundleIdentifier!)Helper" }?["OnDemand"] as? Bool ?? false
    let identifier = "\(Bundle.main.bundleIdentifier!)Helper" as CFString
    SMLoginItemSetEnabled(identifier, !startAtLogin)
    self.menu.populateSettingsMenu()
  }

  @objc func reset(_: AnyObject?) {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "Are sure you want to reset BetterDummy?"
    alert.informativeText = "This restores the default settings and discards all dummies in the process."
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Reset")
    if alert.runModal() == .alertSecondButtonReturn {
      DummyManager.discardAllDummies()
      DummyManager.dummyCounter = 0
      os_log("Cleared dummies.", type: .info)
      if let bundleID = Bundle.main.bundleIdentifier {
        prefs.removePersistentDomain(forName: bundleID)
      }
      os_log("Preferences reset complete.", type: .info)
      self.setDefaultPrefs()
      DummyManager.restoreDummiesFromPrefs()
      self.menu.populateAppMenu()
      self.menu.populateSettingsMenu()
    }
  }

  @objc func hideMenuIcon(_: AnyObject?) {
    if prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue) {
      prefs.set(false, forKey: PrefKey.hideMenuIcon.rawValue)
      self.menu.statusBarItem.isVisible = true
    } else {
      let alert = NSAlert()
      alert.alertStyle = .warning
      alert.messageText = "Do you want to hide the menu icon?"
      alert.informativeText = "You can reveal the menu icon by launching the app again while the app is already running."
      alert.addButton(withTitle: "Hide")
      alert.addButton(withTitle: "No")
      if alert.runModal() == .alertFirstButtonReturn {
        prefs.set(true, forKey: PrefKey.hideMenuIcon.rawValue)
        self.menu.statusBarItem.isVisible = false
      }
    }
    self.menu.populateSettingsMenu()
  }

  @objc func SUEnableAutomaticChecks(_: AnyObject?) {
    prefs.set(!prefs.bool(forKey: PrefKey.SUEnableAutomaticChecks.rawValue), forKey: PrefKey.SUEnableAutomaticChecks.rawValue)
    self.menu.populateSettingsMenu()
  }

  @objc func disableTempSleep(_: AnyObject?) {
    prefs.set(!prefs.bool(forKey: PrefKey.disableTempSleep.rawValue), forKey: PrefKey.disableTempSleep.rawValue)
    self.menu.populateSettingsMenu()
  }

  @objc func reconnectAfterSleep(_: AnyObject?) {
    prefs.set(!prefs.bool(forKey: PrefKey.reconnectAfterSleep.rawValue), forKey: PrefKey.reconnectAfterSleep.rawValue)
    self.menu.populateSettingsMenu()
  }

  @objc func enable16K(_: AnyObject?) {
    if !prefs.bool(forKey: PrefKey.enable16K.rawValue) {
      let alert = NSAlert()
      alert.alertStyle = .critical
      alert.messageText = "Are you sure to enable 16K?"
      alert.informativeText = "Using dummies over 8K can severely reduce performance on some setups."
      alert.addButton(withTitle: "Cancel")
      alert.addButton(withTitle: "Enable")
      if alert.runModal() == .alertFirstButtonReturn {
        return
      }
    }
    prefs.set(!prefs.bool(forKey: PrefKey.enable16K.rawValue), forKey: PrefKey.enable16K.rawValue)
    self.menu.populateSettingsMenu()
    DummyManager.updateDummyDefinitions()
  }

  @objc func useMenuForResolution(_: AnyObject?) {
    prefs.set(!prefs.bool(forKey: PrefKey.useMenuForResolution.rawValue), forKey: PrefKey.useMenuForResolution.rawValue)
    self.menu.populateSettingsMenu()
    self.menu.populateAppMenu()
  }

  @objc func showLowResolutionModes(_: AnyObject?) {
    prefs.set(!prefs.bool(forKey: PrefKey.showLowResolutionModes.rawValue), forKey: PrefKey.showLowResolutionModes.rawValue)
    self.menu.populateSettingsMenu()
    self.menu.populateAppMenu()
  }

  @objc func showPortrait(_: AnyObject?) {
    prefs.set(!prefs.bool(forKey: PrefKey.showPortrait.rawValue), forKey: PrefKey.showPortrait.rawValue)
    self.menu.populateSettingsMenu()
    self.menu.populateAppMenu()
  }

  // MARK: *** Handlers - Others

  @objc func about(_: AnyObject?) {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "UNKNOWN"
    let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "UNKNOWN"
    let year = Calendar.current.component(.year, from: Date())
    let alert = NSAlert()
    alert.messageText = "About BetterDummy"
    alert.informativeText = "Version \(version) Build \(build)\n\nCopyright Ⓒ \(year) @waydabber.\n\nCheck out the GitHub page for instructions or to report issues!"
    alert.addButton(withTitle: "Visit GitHub page")
    alert.addButton(withTitle: "OK")
    alert.alertStyle = NSAlert.Style.informational
    if alert.runModal() == .alertFirstButtonReturn {
      if let url = URL(string: "https://github.com/waydabber/BetterDummy#readme") {
        NSWorkspace.shared.open(url)
      }
    }
  }

  @objc func donate(_: AnyObject?) {
    if let url = URL(string: "https://opencollective.com/betterdummy/donate") {
      NSWorkspace.shared.open(url)
    }
    let alert = NSAlert()
    alert.messageText = "Thank you for your generousity!"
    alert.informativeText = "If you find this app useful, please support the developer with your donation:\n\nopencollective.com/betterdummy\n\nWe opened the page for you in your browser. :)"
    alert.runModal()
  }

  // MARK: *** Handlers - Sleep and wake

  @objc func wakeNotification() {
    guard self.isSleep else {
      return
    }
    DummyManager.sleepTempVirtualDisplay = nil
    os_log("Wake intercepted, removed temporary display if present.", type: .info)
    self.isSleep = false
    if prefs.bool(forKey: PrefKey.reconnectAfterSleep.rawValue) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
        if !self.isSleep {
          os_log("Delayed reconnecting dummies after wake.", type: .info)
          for dummy in DummyManager.getDummies() where !dummy.isConnected {
            _ = dummy.connect(sleepConnect: true)
          }
        }
      }
    }
  }

  @objc func sleepNotification() {
    guard !self.isSleep else {
      return
    }
    self.isSleep = true
    if DummyManager.getNumOfDummies() > 0, !prefs.bool(forKey: PrefKey.disableTempSleep.rawValue) {
      let maxWidth = 1920
      let maxHeight = 1080
      DummyManager.sleepTempVirtualDisplay = Dummy.createVirtualDisplay(DummyDefinition(maxWidth, maxHeight, 1, 1, 1, [60], "Dummy Temp", false), name: "Dummy Temp", serialNum: 0)
      os_log("Sleep intercepted, created temporary display with the size of %{public}@x%{public}@", type: .info, String(maxWidth), String(maxHeight))
    }
    if prefs.bool(forKey: PrefKey.reconnectAfterSleep.rawValue) {
      os_log("Disconnecting dummies on sleep.", type: .info)
      for dummy in DummyManager.getDummies() where dummy.isConnected {
        dummy.disconnect(sleepDisconnect: true)
      }
    }
  }
}

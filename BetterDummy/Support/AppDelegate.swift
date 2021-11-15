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
  let updaterController = SPUStandardUpdaterController(startingUpdater: false, updaterDelegate: UpdaterDelegate(), userDriverDelegate: nil)
  let menu = AppMenu()

  // MARK: *** Setup app

  @available(macOS, deprecated: 10.10)
  func applicationDidFinishLaunching(_: Notification) {
    app = self
    DummyManager.updateDummyDefinitions()
    self.menu.setupMenu()
    Util.setDefaultPrefs()
    Util.restoreSettings()
    self.updaterController.startUpdater()
    self.handleDisplayReconfiguration(force: true)

    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleSleepNotification), name: NSWorkspace.screensDidSleepNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleSleepNotification), name: NSWorkspace.willSleepNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleWakeNotification), name: NSWorkspace.screensDidWakeNotification, object: nil)
    NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.handleWakeNotification), name: NSWorkspace.didWakeNotification, object: nil)
    CGDisplayRegisterReconfigurationCallback({ _, _, _ in app.handleDisplayReconfiguration() }, nil)
  }

  func applicationShouldHandleReopen(_: NSApplication, hasVisibleWindows _: Bool) -> Bool {
    let alert = NSAlert()
    alert.alertStyle = .informational
    alert.messageText = "BetterDummy is already running!"
    if prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue) || self.menu.statusBarItem.isVisible == false {
      self.menu.statusBarItem.isVisible = true
      Util.saveSettings()
      self.handleHideMenuIcon(self.menu.hideMenuIconMenuItem)
      alert.informativeText = "The menu icon was hidden but it is now set to visible. You can hide it again in Settings."
    } else {
      alert.informativeText = "To configure the app, use the BetterDummy menu icon in the macOS menu bar!"
    }
    alert.runModal()
    return true
  }

  // MARK: *** Handlers - Dummy management

  @objc func handleCreateDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      os_log("Connecting dummy tagged in new menu as %{public}@", type: .info, "\(menuItem.tag)")
      if let number = DummyManager.createDummyByDefinitionId(menuItem.tag) {
        self.menu.repopulateManageMenu()
        Util.saveSettings()
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

  @objc func handleConnectDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      os_log("Connecting dummy tagged in delete menu as %{public}@", type: .info, "\(menuItem.tag)")
      if let dummy = DummyManager.getDummyByNumber(menuItem.tag) {
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
      }
      self.menu.repopulateManageMenu()
      Util.saveSettings()
    }
  }

  @objc func handleDisconnectDummy(_ sender: AnyObject?) {
    if let menuItem = sender as? NSMenuItem {
      os_log("Disconnecting dummy tagged in delete menu as %{public}@", type: .info, "\(menuItem.tag)")
      if let dummy = DummyManager.getDummyByNumber(menuItem.tag) {
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

      self.menu.repopulateManageMenu()
      Util.saveSettings()
    }
  }

  @objc func handleDiscardDummy(_ sender: AnyObject?) {
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
        self.menu.repopulateManageMenu()
        Util.saveSettings()
      }
    }
  }

  @objc func handleAssociateDummy(_ sender: NSMenuItem) {
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
      self.menu.repopulateManageMenu()
      Util.saveSettings()
    }
    _ = sender.tag
  }

  @objc func handleDisassociateDummy(_ sender: NSMenuItem) {
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
      self.menu.repopulateManageMenu()
      Util.saveSettings()
    }
  }

  @objc func handleDummyResolution(_ sender: NSMenuItem) {
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

  @objc func handleConnectAllDummies(_: AnyObject?) {
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
    self.menu.repopulateManageMenu()
    Util.saveSettings()
  }

  @objc func handleDisconnectAllDummies(_: AnyObject?) {
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
    self.menu.repopulateManageMenu()
    Util.saveSettings()
  }

  @objc func handleDiscardAllDummies(_: AnyObject?) {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "Do you want to discard all dummies?"
    alert.informativeText = "If you would like to use the dummies later, it is better to use disconnect so macOS display configuration data is preserved."
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Discard")
    if alert.runModal() == .alertSecondButtonReturn {
      os_log("Removing dummies.", type: .info)
      DummyManager.discardAllDummies()
      self.menu.repopulateManageMenu()
      Util.saveSettings()
    }
  }

  @objc func handleDisassociateAllDummies(_: AnyObject?) {
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
        self.menu.repopulateManageMenu()
        Util.saveSettings()
      }
    }
  }

  // MARK: *** Handlers - Display reconfiguration

  @objc func handleDisplayReconfiguration(dispatchedReconfigureID: Int = 0, force: Bool = false) {
    if !force, dispatchedReconfigureID == 0 || self.isSleep {
      self.reconfigureID += 1
      os_log("Bumping reconfigureID to %{public}@", type: .info, String(self.reconfigureID))
      if !self.isSleep {
        let dispatchedReconfigureID = self.reconfigureID
        os_log("Displays to be reconfigured with reconfigureID %{public}@", type: .info, String(dispatchedReconfigureID))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
          self.handleDisplayReconfiguration(dispatchedReconfigureID: dispatchedReconfigureID)
        }
      }
    } else if dispatchedReconfigureID == self.reconfigureID || force {
      os_log("Request for display configuration with reconfigreID %{public}@", type: .info, String(dispatchedReconfigureID))
      self.reconfigureID = 0
      DisplayManager.configureDisplays()
      DisplayManager.addDisplayCounterSuffixes()
      DummyManager.connectDisconnectAssociatedDummies()
      self.menu.repopulateManageMenu()
      Util.saveSettings()
    }
  }

  // MARK: *** Handlers - Settings and others

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
    alert.informativeText = "This restores the default settings and discards all dummies in the process."
    alert.addButton(withTitle: "Cancel")
    alert.addButton(withTitle: "Reset")
    if alert.runModal() == .alertSecondButtonReturn {
      DummyManager.discardAllDummies()
      DummyManager.dummyCounter = 0
      self.menu.emptyManageMenu()
      os_log("Cleared dummies.", type: .info)
      if let bundleID = Bundle.main.bundleIdentifier {
        prefs.removePersistentDomain(forName: bundleID)
      }
      os_log("Preferences reset complete.", type: .info)
      Util.setDefaultPrefs()
      Util.restoreSettings()
    }
  }

  @objc func handleHideMenuIcon(_ sender: NSMenuItem) {
    if sender.state == .on {
      sender.state = .off
      self.menu.statusBarItem.isVisible = true
    } else {
      let alert = NSAlert()
      alert.alertStyle = .warning
      alert.messageText = "Do you want to hide the menu icon?"
      alert.informativeText = "You can reveal the menu icon by launching the app again while the app is already running."
      alert.addButton(withTitle: "Hide")
      alert.addButton(withTitle: "No")
      if alert.runModal() == .alertFirstButtonReturn {
        sender.state = .on
        self.menu.statusBarItem.isVisible = false
      }
    }
    Util.saveSettings()
  }

  @objc func handleSimpleCheckMenu(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    Util.saveSettings()
  }

  @objc func handleEnable16K(_ sender: NSMenuItem) {
    if sender.state == .off {
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
    sender.state = sender.state == .on ? .off : .on
    Util.saveSettings()
    DummyManager.updateDummyDefinitions()
  }

  @objc func handleShowLowResolutionModes(_ sender: NSMenuItem) {
    sender.state = sender.state == .on ? .off : .on
    Util.saveSettings()
    self.menu.repopulateManageMenu()
  }

  @objc func handleAbout(_: AnyObject?) {
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

  @objc func handleDonate(_: NSMenuItem) {
    if let url = URL(string: "https://opencollective.com/betterdummy/donate") {
      NSWorkspace.shared.open(url)
    }
    let alert = NSAlert()
    alert.messageText = "Thank you for your generousity!"
    alert.informativeText = "If you find this app useful, please support the developer with your donation:\n\nopencollective.com/betterdummy\n\nWe opened the page for you in your browser. :)"
    alert.runModal()
  }

  // MARK: *** Handlers - Sleep and wake

  @objc func handleWakeNotification() {
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

  @objc func handleSleepNotification() {
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
    if self.menu.reconnectAfterSleepMenuItem.state == .on {
      os_log("Disconnecting dummies on sleep.", type: .info)
      for dummy in DummyManager.getDummies() where dummy.isConnected {
        dummy.disconnect(sleepDisconnect: true)
      }
    }
  }
}

//
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa
import Foundation
import os.log
import ServiceManagement

class Util {
  // MARK: Save and restore settings

  static func setDefaultPrefs() {
    if !prefs.bool(forKey: PrefKey.appAlreadyLaunched.rawValue) {
      prefs.set(true, forKey: PrefKey.appAlreadyLaunched.rawValue)
      prefs.set(true, forKey: PrefKey.SUEnableAutomaticChecks.rawValue)
      os_log("Setting default preferences.", type: .info)
    }
  }

  static func saveSettings() {
    guard DummyManager.getNumOfDummies() > 0 else {
      return
    }
    prefs.set(true, forKey: PrefKey.appAlreadyLaunched.rawValue)
    prefs.set(app.menu.automaticallyCheckForUpdatesMenuItem.state == .on, forKey: PrefKey.SUEnableAutomaticChecks.rawValue)
    prefs.set(Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1, forKey: PrefKey.buildNumber.rawValue)
    prefs.set(app.menu.startAtLoginMenuItem.state == .on, forKey: PrefKey.startAtLogin.rawValue)
    prefs.set(app.menu.hideMenuIconMenuItem.state == .on, forKey: PrefKey.hideMenuIcon.rawValue)
    prefs.set(app.menu.enable16KMenuItem.state == .on, forKey: PrefKey.enable16K.rawValue)
    prefs.set(app.menu.showLowResolutionModesMenuItem.state == .on, forKey: PrefKey.showLowResolutionModes.rawValue)
    prefs.set(app.menu.reconnectAfterSleepMenuItem.state == .on, forKey: PrefKey.reconnectAfterSleep.rawValue)
    prefs.set(app.menu.useTempSleepMenuItem.state == .off, forKey: PrefKey.disableTempSleep.rawValue)
    prefs.set(DummyManager.getNumOfDummies(), forKey: PrefKey.numOfDummyDisplays.rawValue)
    var i = 1
    for key in DummyManager.definedDummies.keys.sorted(by: <) {
      if let definedDummy = DummyManager.definedDummies[key] {
        prefs.set(definedDummy.definitionId, forKey: "\(PrefKey.display.rawValue)\(i)")
        prefs.set(definedDummy.dummy.serialNum, forKey: "\(PrefKey.serial.rawValue)\(i)")
        prefs.set(definedDummy.dummy.isConnected, forKey: "\(PrefKey.isConnected.rawValue)\(i)")
        prefs.set(definedDummy.dummy.associatedDisplayPrefsId, forKey: "\(PrefKey.associatedDisplayPrefsId.rawValue)\(i)")
        prefs.set(definedDummy.dummy.associatedDisplayName, forKey: "\(PrefKey.associatedDisplayName.rawValue)\(i)")
        i += 1
      }
    }
    os_log("Preferences stored.", type: .info)
  }

  @available(macOS, deprecated: 10.10)
  static func restoreSettings() {
    os_log("Restoring settings.", type: .info)
    let startAtLogin = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]])?.first { $0["Label"] as? String == "\(Bundle.main.bundleIdentifier!)Helper" }?["OnDemand"] as? Bool ?? false
    app.menu.startAtLoginMenuItem.state = startAtLogin ? .on : .off
    app.menu.automaticallyCheckForUpdatesMenuItem.state = prefs.bool(forKey: PrefKey.SUEnableAutomaticChecks.rawValue) ? .on : .off
    app.menu.hideMenuIconMenuItem.state = prefs.bool(forKey: PrefKey.hideMenuIcon.rawValue) ? .on : .off
    app.menu.enable16KMenuItem.state = prefs.bool(forKey: PrefKey.enable16K.rawValue) ? .on : .off
    app.menu.showLowResolutionModesMenuItem.state = prefs.bool(forKey: PrefKey.showLowResolutionModes.rawValue) ? .on : .off
    app.menu.reconnectAfterSleepMenuItem.state = prefs.bool(forKey: PrefKey.reconnectAfterSleep.rawValue) ? .on : .off
    app.menu.useTempSleepMenuItem.state = !prefs.bool(forKey: PrefKey.disableTempSleep.rawValue) ? .on : .off
    guard prefs.integer(forKey: "numOfDummyDisplays") > 0 else {
      return
    }
    for i in 1 ... prefs.integer(forKey: PrefKey.numOfDummyDisplays.rawValue) where prefs.object(forKey: "\(PrefKey.display.rawValue)\(i)") != nil {
      if let number = DummyManager.createDummyByDefinitionId(prefs.integer(forKey: "\(PrefKey.display.rawValue)\(i)"), serialNum: UInt32(prefs.integer(forKey: "\(PrefKey.serial.rawValue)\(i)")), doConnect: prefs.bool(forKey: "\(PrefKey.isConnected.rawValue)\(i)")) {
        DummyManager.getDummyByNumber(number)?.associatedDisplayPrefsId = prefs.string(forKey: "\(PrefKey.associatedDisplayPrefsId.rawValue)\(i)") ?? ""
        DummyManager.getDummyByNumber(number)?.associatedDisplayName = prefs.string(forKey: "\(PrefKey.associatedDisplayName.rawValue)\(i)") ?? ""
      }
    }
    app.menu.repopulateManageMenu()
  }
}

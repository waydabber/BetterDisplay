import Cocoa
import CoreGraphics
import Foundation
import os.log

autoreleasepool { () -> Void in
    let app = NSApplication.shared
    let appDelegate = AppDelegate()
    app.delegate = appDelegate
    app.run()
}

class AppDelegate: NSObject, NSApplicationDelegate {

    struct DisplayDefinition {
        let aspectWidth, aspectHeight, multiplierStep, minMultiplier, maxMultiplier: Int
        let refreshRates: [Double]
        let description: String
        init(_ aspectWidth: Int, _ aspectHeight: Int, _ minMultiplier: Int, _ maxMultiplier: Int, _ step: Int, _ refreshRates: [Double], _ description: String) {
            self.aspectWidth = aspectWidth
            self.aspectHeight = aspectHeight
            self.minMultiplier = minMultiplier
            self.maxMultiplier = maxMultiplier
            self.multiplierStep = step
            self.refreshRates = refreshRates
            self.description = description
        }
    }
    let displayDefinitions: [DisplayDefinition] = [
        DisplayDefinition( 16,   9, 25, 94, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:9 (HD/4K/5K/6K)"),
        DisplayDefinition( 16,  10, 20, 84, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:10 (W*XGA)"),
        DisplayDefinition( 16,  12, 24, 70, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "16:12 (VGA)"),
        DisplayDefinition(256, 135,  6, 23, 1, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "17:9 (4K-DCI)"),
        DisplayDefinition( 64,  27, 16, 47, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "21.3:9 (UW-HD/4K/5K)"),
        DisplayDefinition( 43,  18, 24, 69, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "21.5:9 (UW-QHD)"),
        DisplayDefinition( 24,  10, 20, 62, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "24:10 (UW-QHD+)"),
        DisplayDefinition( 32,  10, 40, 94, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "32:10 (D-W*XGA)"),
        DisplayDefinition( 32,   9, 40, 94, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "32:9 (D-HD/QHD)"),
        DisplayDefinition( 20,  20, 19, 42, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "1:1 (Square)"),
        DisplayDefinition(  9,  16, 25, 94, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "9:16 (HD/4K/5K/6K - Rotated)"),
        DisplayDefinition( 10,  16, 20, 84, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "10:16 (W*XGA - Rotated)"),
        DisplayDefinition( 12,  16, 24, 70, 4, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "12:16 (VGA - Rotated)"),
        DisplayDefinition(135, 256,  6, 23, 1, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "9:17 (4K-DCI - Rotated)"),
        DisplayDefinition( 20,  25, 31, 84, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "10:12.5 (SXGA - Rotated)")
    ]
    struct VirtualDisplay {
        let number: Int
        var display: Any?
        let displayDefinitionItem: Int
    }
    var virtualDisplayCounter: Int = 0
    var virtualDisplays = [Int: VirtualDisplay]()
    var statusBarItem: NSStatusItem!
    var transientDisplay: Any?
    let deleteMenu = NSMenu()
    let deleteSubmenu = NSMenuItem(title: "Disconnect Dummy", action: nil, keyEquivalent: "")
    let prefs = UserDefaults.standard

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupMenu()
        restoreSettings()
        setupNotifications()
    }

    func setupNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.sleepNotification), name: NSWorkspace.screensDidSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.sleepNotification), name: NSWorkspace.willSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.wakeNotification), name: NSWorkspace.screensDidWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.wakeNotification), name: NSWorkspace.didWakeNotification, object: nil)
    }

    func setupMenu() {

        let newMenu = NSMenu()
        populateNewMenu(newMenu)
        let newSubmenu = NSMenuItem(title: "Connect Dummy", action: nil, keyEquivalent: "")
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
        for displayDefinition in displayDefinitions {
            let item = NSMenuItem(title: "\(displayDefinition.description)", action: #selector(handleConnectDummy(_:)), keyEquivalent: "")
            item.tag = i
            newMenu.addItem(item)
            i += 1
            os_log("New dummy menu populated.", type: .info)
        }
    }
    
    func connectDummy(displayDefinitionItem: Int, skipSaveSettings: Bool = false) {
        let displayDefinition = displayDefinitions[displayDefinitionItem]
        let name: String = "Dummy \(displayDefinition.description.components(separatedBy: " ").first ?? displayDefinition.description)"
        if let display = createVirtualDisplay(displayDefinition, name) {
            virtualDisplays[virtualDisplayCounter] = VirtualDisplay(number: virtualDisplayCounter, display: display, displayDefinitionItem: displayDefinitionItem)
            let menuItem = NSMenuItem(title: "\(displayDefinition.description)", action: #selector(handleDisconnectDummy(_:)), keyEquivalent: "")
            menuItem.tag = virtualDisplayCounter
            deleteMenu.addItem(menuItem)
            deleteSubmenu.isHidden = false
            virtualDisplayCounter += 1
            os_log("Display %{public}@ successfully created", type: .info, "\(name)")
            if !skipSaveSettings {
                saveSettings()
            }
        } else {
            os_log("Failed to create display %{public}@", type: .info, "\(name)")
        }
    }
    
    func createVirtualDisplay(_ displayDefinition: DisplayDefinition, _ name: String) -> CGVirtualDisplay? {
        if let descriptor = CGVirtualDisplayDescriptor() {
            descriptor.queue = DispatchQueue.global(qos: .userInteractive)
            descriptor.name = name
            descriptor.maxPixelsWide = UInt32(displayDefinition.aspectWidth * displayDefinition.multiplierStep * displayDefinition.maxMultiplier)
            descriptor.maxPixelsHigh = UInt32(displayDefinition.aspectHeight * displayDefinition.multiplierStep * displayDefinition.maxMultiplier)
            descriptor.sizeInMillimeters = CGSize(width: 25.4 * Double(descriptor.maxPixelsWide) / 200, height: 25.4 * Double(descriptor.maxPixelsHigh) / 200)
            descriptor.serialNum = UInt32(min(displayDefinition.aspectWidth-1,255)*256+min(displayDefinition.aspectHeight-1,255))
            descriptor.productID = UInt32(min(displayDefinition.aspectWidth-1,255)*256+min(displayDefinition.aspectHeight-1,255))
            descriptor.vendorID = UInt32(0xF0F0)
            if let display = CGVirtualDisplay(descriptor: descriptor) {
                var modes = [CGVirtualDisplayMode?](repeating: nil, count: displayDefinition.maxMultiplier-displayDefinition.minMultiplier+1)
                for multiplier in displayDefinition.minMultiplier...displayDefinition.maxMultiplier  {
                    for refreshRate in displayDefinition.refreshRates {
                        modes[multiplier-displayDefinition.minMultiplier] = CGVirtualDisplayMode(width: UInt32(displayDefinition.aspectWidth * multiplier * displayDefinition.multiplierStep), height: UInt32(displayDefinition.aspectHeight * multiplier * displayDefinition.multiplierStep), refreshRate: refreshRate)!
                    }
                }
                if let settings = CGVirtualDisplaySettings() {
                    settings.hiDPI = 1
                    settings.modes = modes as [Any]
                    if display.applySettings(settings) {
                        return display
                    }
                }
            }
        }
        return nil
    }
    
    func restoreSettings() {
        guard prefs.integer(forKey: "numOfDummyDisplays") > 0 else {
            return
        }
        for i in 1 ... prefs.integer(forKey: "numOfDummyDisplays") where prefs.object(forKey: String(i)) != nil {
            connectDummy(displayDefinitionItem: prefs.integer(forKey: String(i)), skipSaveSettings: true)
        }
    }
    
    func saveSettings() {
        if let bundleID = Bundle.main.bundleIdentifier {
            prefs.removePersistentDomain(forName: bundleID)
            os_log("Preferences wiped.", type: .info)
        }
        guard virtualDisplays.count > 0 else {
            return
        }
        prefs.set(virtualDisplays.count, forKey: "numOfDummyDisplays")
        prefs.set(Int(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1") ?? 1, forKey: "buildNumber")
        var i = 1
        for virtualDisplay in virtualDisplays {
            prefs.set(virtualDisplay.value.displayDefinitionItem, forKey: String(i))
            i += 1
        }
        os_log("Preferences stored.", type: .info)
    }
    
    @objc func handleConnectDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem, menuItem.tag >= 0, menuItem.tag < displayDefinitions.count {
            os_log("Connecting display tagged in new menu as %{public}@", type: .info, "\(menuItem.tag)")
            connectDummy(displayDefinitionItem: menuItem.tag)
        }
    }
    
    @objc func handleDisconnectDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            os_log("Removing display  tagged in delete menu as %{public}@", type: .info, "\(menuItem.tag)")
            virtualDisplays[menuItem.tag] = nil
            menuItem.menu?.removeItem(menuItem)
            saveSettings()
            if virtualDisplays.count == 0 {
                deleteSubmenu.isHidden = true
            }
        }
    }
    
    @objc func wakeNotification() {
        os_log("Wake intercepted, removing transient display if there is any.", type: .info)
        transientDisplay = nil
    }

    @objc func sleepNotification() {
        if virtualDisplays.count > 0 {
            transientDisplay = createVirtualDisplay(DisplayDefinition(3840,2160, 1, 1, 1, [60], "Transient"), "Transient")
            os_log("Sleep intercepted, created transient display.", type: .info)
            // Note: for some reason, if we create a transient virtual display on sleep, the sleep proceeds as normal. This is a result of some trial & error and might not work on all systems.
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
    
}

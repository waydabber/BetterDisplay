import Cocoa
import CoreGraphics
import Foundation

autoreleasepool { () -> Void in
    let app = NSApplication.shared
    let appDelegate = AppDelegate()
    app.delegate = appDelegate
    app.run()
}

class AppDelegate: NSObject, NSApplicationDelegate {

    struct DisplayDefinition {
        let aspectWidth, aspectHeight, multiplierStep: Float
        let minMultiplier, maxMultiplier: Int
        let refreshRates: [Double]
        let description: String
        init(_ aspectWidth: Float, _ aspectHeight: Float, _ minMultiplier: Int, _ maxMultiplier: Int, _ step: Float, _ refreshRates: [Double], _ description: String) {
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
        DisplayDefinition( 25,  20, 31, 84, 2, [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], "12.5:10 (SXGA)")
    ]
    struct VirtualDisplay {
        let number: Int
        let display: Any
        let displayDefinitionItem: Int
    }
    var virtualDisplayCounter: Int = 0
    var virtualDisplays = [Int: VirtualDisplay]()
    var statusBarItem: NSStatusItem!
    let newSubmenu = NSMenuItem(title: "Connect Dummy", action: nil, keyEquivalent: "")
    let deleteSubmenu = NSMenuItem(title: "Disconnect Dummy", action: nil, keyEquivalent: "")
    let deleteMenu = NSMenu()
    let prefs = UserDefaults.standard

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
             button.image = NSImage(systemSymbolName: "display.2", accessibilityDescription: "BetterDummy")
        }
        let menu = NSMenu()
        let newMenu = NSMenu()
        var i = 0
        for displayDefinition in displayDefinitions {
            let item = NSMenuItem(title: "\(displayDefinition.description)", action: #selector(handleConnectDummy(_:)), keyEquivalent: "")
            item.tag = i
            newMenu.addItem(item)
            i += 1
        }
        newSubmenu.submenu = newMenu
        menu.addItem(newSubmenu)
        deleteSubmenu.submenu = deleteMenu
        menu.addItem(deleteSubmenu)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit BetterDummy", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusBarItem.menu = menu
        restoreSettings()
        if virtualDisplays.count == 0 {
            deleteSubmenu.isHidden = true
        }
    }
    
    func restoreSettings() {
        guard prefs.integer(forKey: "numOfDummyDisplays") > 0 else {
            return
        }
        for i in 1 ... prefs.integer(forKey: "numOfDummyDisplays") where prefs.object(forKey: String(i)) != nil {
            connectDummy(displayDefinitionItem: prefs.integer(forKey: String(i)))
        }
    }
    
    func saveSettings() {
        if let bundleID = Bundle.main.bundleIdentifier {
          prefs.removePersistentDomain(forName: bundleID)
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
    }

    func connectDummy(displayDefinitionItem: Int) {
        let displayDefinition = displayDefinitions[displayDefinitionItem]
        let name: String = "Dummy \(displayDefinition.description.components(separatedBy: " ").first ?? displayDefinition.description)"
        if let display = createDisplay(displayDefinition, name) {
            virtualDisplays[virtualDisplayCounter] = VirtualDisplay(number: virtualDisplayCounter, display: display, displayDefinitionItem: displayDefinitionItem)
            let menuItem = NSMenuItem(title: "\(displayDefinition.description) display", action: #selector(handleDisconnectDummy(_:)), keyEquivalent: "")
            menuItem.tag = virtualDisplayCounter
            deleteMenu.addItem(menuItem)
            deleteSubmenu.isHidden = false
            virtualDisplayCounter += 1
        }
        saveSettings()
    }

    @objc func handleConnectDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem, menuItem.tag >= 0, menuItem.tag < displayDefinitions.count {
            connectDummy(displayDefinitionItem: menuItem.tag)
        }
    }
    
    @objc func handleDisconnectDummy(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            virtualDisplays[menuItem.tag] = nil
            menuItem.menu?.removeItem(menuItem)
            saveSettings()
            if virtualDisplays.count == 0 {
                deleteSubmenu.isHidden = true
            }
        }
    }
    
    func createDisplay(_ displayDefinition: DisplayDefinition, _ name: String) -> CGVirtualDisplay? {
        if let descriptor = CGVirtualDisplayDescriptor() {
            descriptor.queue = DispatchQueue.global(qos: .userInteractive)
            descriptor.name = name
            descriptor.maxPixelsWide = UInt32(displayDefinition.aspectWidth * displayDefinition.multiplierStep * Float(displayDefinition.maxMultiplier))
            descriptor.maxPixelsHigh = UInt32(displayDefinition.aspectHeight * displayDefinition.multiplierStep * Float(displayDefinition.maxMultiplier))
            descriptor.sizeInMillimeters = CGSize(width: 25.4 * Double(descriptor.maxPixelsWide) / 200, height: 25.4 * Double(descriptor.maxPixelsHigh) / 200)
            descriptor.serialNum = 0
            descriptor.productID = 0
            descriptor.vendorID = 0
            if let display = CGVirtualDisplay(descriptor: descriptor) {
                var modes = [CGVirtualDisplayMode?](repeating: nil, count: displayDefinition.maxMultiplier-displayDefinition.minMultiplier+1)
                for multiplier in displayDefinition.minMultiplier...displayDefinition.maxMultiplier  {
                    for refreshRate in displayDefinition.refreshRates {
                        modes[multiplier-displayDefinition.minMultiplier] = CGVirtualDisplayMode(width: UInt32(displayDefinition.aspectWidth*Float(multiplier)*displayDefinition.multiplierStep), height: UInt32(displayDefinition.aspectHeight*Float(multiplier)*displayDefinition.multiplierStep), refreshRate: refreshRate)!
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

}

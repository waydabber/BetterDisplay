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
        init(aW: Float, aH: Float, minX: Int, maxX: Int, step: Float, rR: [Double], desc: String) {
            self.aspectWidth = aW
            self.aspectHeight = aH
            self.minMultiplier = minX
            self.maxMultiplier = maxX
            self.multiplierStep = step
            self.refreshRates = rR
            self.description = desc
        }
    }
    let displayDefinitions: [DisplayDefinition] = [
        DisplayDefinition(aW: 16, aH: 09, minX: 25, maxX: 94, step: 4, rR: [24, 25, 30, 48, 50, 60, 72, 75, 90, 96, 100, 120, 125, 144, 150], desc: "16:9")
    ]
    struct VirtualDisplay {
        let number: Int
        let display: Any
    }
    var virtualDisplayCounter: Int = 0
    var virtualDisplays = [Int: VirtualDisplay]()
    var statusBarItem: NSStatusItem!
    let newSubmenu = NSMenuItem(title: "New", action: nil, keyEquivalent: "")
    let deleteSubmenu = NSMenuItem(title: "Delete", action: nil, keyEquivalent: "")
    let deleteMenu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
             button.image = NSImage(systemSymbolName: "4k.tv", accessibilityDescription: "BetterDummy")
        }
        let menu = NSMenu()
        let newMenu = NSMenu()
        var i = 0
        for displayDefinition in displayDefinitions {
            let item = NSMenuItem(title: "\(displayDefinition.description) display", action: #selector(newDisplay(_:)), keyEquivalent: "")
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
    }

    @objc func newDisplay(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            if menuItem.tag >= 0 && menuItem.tag < displayDefinitions.count {
                let displayDefinition = displayDefinitions[menuItem.tag]
                let name: String = "Dummy \(displayDefinition.description) " + (virtualDisplayCounter > 1 ? "(\(virtualDisplayCounter))" : "")
                if let display = createDisplay(displayDefinition, name) {
                    virtualDisplays[virtualDisplayCounter] = VirtualDisplay(number: virtualDisplayCounter, display: display)
                    let menuItem = NSMenuItem(title: "\(displayDefinition.description) display", action: #selector(deleteDisplay(_:)), keyEquivalent: "")
                    menuItem.tag = virtualDisplayCounter
                    deleteMenu.addItem(menuItem)
                    deleteSubmenu.isHidden = false
                    virtualDisplayCounter += 1
                }
            }
        }
    }

    @objc func deleteDisplay(_ sender: AnyObject?) {
        if let menuItem = sender as? NSMenuItem {
            virtualDisplays[menuItem.tag] = nil
            menuItem.menu?.removeItem(menuItem)
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

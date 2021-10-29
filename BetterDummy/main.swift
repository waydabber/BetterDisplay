//
//  main.swift
//  BetterDummy
//
//  Created by @waydabber
//

import Cocoa

var app: AppDelegate!

autoreleasepool { () -> Void in
  let app = NSApplication.shared
  let appDelegate = AppDelegate()
  app.delegate = appDelegate
  app.run()
}

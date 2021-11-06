//
//  UpdaterDelegate.swift
//  BetterDummy
//
//  Created by @waydabber
//

import Foundation
import Sparkle

class UpdaterDelegate: NSObject, SPUUpdaterDelegate {
  func allowedChannels(for _: SPUUpdater) -> Set<String> {
    prefs.bool(forKey: PrefKeys.isBetaChannel.rawValue) ? Set(["beta"]) : Set([])
  }
}

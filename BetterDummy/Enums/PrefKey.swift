//
//  BetterDummy
//
//  Created by @waydabber
//

enum PrefKey: String {
  // Dummy specific
  case display
  case serial
  case isConnected
  case associatedDisplayPrefsId
  case associatedDisplayName

  // General
  case appAlreadyLaunched
  case numOfDummyDisplays
  case buildNumber
  case startAtLogin
  case reconnectAfterSleep
  case disableTempSleep
  case SUEnableAutomaticChecks
  case isBetaChannel
  case enable16K
}

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
  case isPortrait

  // General
  case appAlreadyLaunched
  case numOfDummyDisplays
  case buildNumber
  case startAtLogin
  case hideMenuIcon
  case reconnectAfterSleep
  case disableTempSleep
  case SUEnableAutomaticChecks
  case isBetaChannel
  case enable16K
  case hideLowResolutionOption
  case hidePortraitOption
  case useMenuForResolution

  // Not used
  case enableSliderSnap
  case showTickMarks
}

<img src=".github/Icon-1024.png" width="230" alt="App icon" align="left"/>

<div>
<h2>BetterDummy</h2>
<p>Dummy Display for Apple Silicon/Intel Macs to Have Custom HiDPI Resolutions - an app from one of the makers of <a href="https://github.com/MonitorControl/MonitorControl">MonitorControl</a>.<p>
<a href="https://github.com/waydabber/BetterDummy/releases"><img src=".github/macos_badge_noborder.png" width="175" alt="Download for macOS"/></a>
</div>

<br />

<div align="center">
<!-- shields -->
<!-- downloads -->
<a href="https://github.com/waydabber/BetterDummy/releases">
<img src="https://img.shields.io/github/downloads/waydabber/BetterDummy/total.svg?style=flat" alt="downloads"/>
</a>
<!-- version -->
<a href="https://github.com/waydabber/BetterDummy/releases">
<img src="https://img.shields.io/github/release-pre/waydabber/BetterDummy.svg?style=flat" alt="latest version"/>
</a>
<!-- license -->
<a href="https://github.com/waydabber/BetterDummy/blob/main/LICENSE">
<img src="https://img.shields.io/github/license/waydabber/BetterDummy.svg?style=flat" alt="license"/>
</a>
<!-- platform -->
<a href="https://github.com/waydabber/BetterDummy">
<img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat" alt="platform"/>
</a>
<!-- backers -->
<a href="https://opencollective.com/betterdummy">
<img src="https://opencollective.com/betterdummy/tiers/badge.svg" alt="backers"/>
</a>
</div>
  
<hr>
  
## About

M1 macs tend to have issues with custom resolutions. Notoriously they don't allow sub-4K resolution displays to have HiDPI ("Retina") resolutions even though (for example) a 24" QHD 1440p display would greatly benefit from having an 1920x1080 HiDPI "Retina" mode.

To fix this issue, some resort to buying a 4K HDMI dummy dongle to fool macOS into thinking that a 4K display is connected and then mirror the contents of this dummy display to their actual monitor in order to have HiDPI resolutions available. Others use the built in screens of their MacBooks to mirror to the external display. These approaches have obvious drawbacks and cannot solve all problems.

To fix this problem, BetterDummy creates a virtual dummy display which you can then utilize as a mirror main.

Advantages of BetterDummy over a physical 4K HDMI dummy plug or mirroring your internal display:

- Your HDMI port will remain usable for an other display on the Mac Mini.
- Your internal screen will be available as an extended space on a MacBook (or you can use clamshell mode).
- Does not suffer from issues that prevalent with the physical dummy (like jittery mouse cursor).
- Offers a much wider variety of HiDPI and standard resolutions.
- Works with all aspect ratios, does not depend on what resoluations are recorded in the dummy's EDID/firmware.
- Does not utilize graphics hardware in vain so it is somewhat faster.
- Available instantly.

Some other possible uses:

- The app is also useful for anybody who is not satisfied with the offered default HiDPI resolutions offered by macOS - as in some cases this could be rather limiting - especially on Wide or UltraWide displays.
- Use headless Macs (servers) with any resolution and HiDPI mode for remote access (tested on Intel Mac with Intel UHD 630 - please note that the app runs in user space after login).
- Scale Sidecar resolutions.
- Better quality zooming (`System Preferences`»`Accessibility`»`Zoom`) or High Quality screenshots even on Full HD displays.
- You can use it instead of or alongside other apps that create custom native resolutions.

## Usage

1. Start the app
2. In the app menu choose `Create New Dummy` and select your desired aspect ratio
<br/>
<div align="center">
<img src=".github/menu.png" width="469"/>
</div>
<br/>
  
3. In `System Preferences` -> `Displays` you'll see the new Dummy display (for example `Dummy 16:9`)
4. Activate mirroring. The `Main` display should be the Dummy display
5. Set the Dummy display as `Optimize for`
6. Set `Resolution` as `Scaled` - **you should hold the `Option` key while clicking on the `Scaled` option for a fuller list of resolutions!**
7. You can also click `Show all resolutions` for even more resolutions

<div align="center">
<img src=".github/displayprefs.png" width="550"/>
</div>

8. Select the desired mode.

The app saves the dummy display configuration and automatically restores it upon next restart.

For more information on usage, see the [the additional help section](#additional-help).

Notes:

- Instead of using the `System Preferences` -> `Displays` to change the resolution, you can use the in-app menu for this as well (`Manage Dummies` -> `Set resolution`) as of v1.0.10
- The tutorial was compiled on an Apple Silicon Mac running macOS Monterey (the app works on Intel and Big Sur as well - steps are slightly differnt, see [this article](https://macfinder.co.uk/blog/how-to-mirror-specific-displays-in-os-x-mirror-some-but-not-all-of-your-monitors-on-an-apple-system/) on how to customize mirroring on Big Sur).
- For most configurations, you'll see HiDPI 'Retina' resolutions in the list by default and see and additional non-HiDPI resolutions marked with a `(low resolution)` tag in the resolution list if `Show all resolutions` is toggled. On some configurations however, you might see HiDPI (high resolution) display modes marked with a `(HiDPI)` tag and standard resolutions _without a tag_.
- You might have to fight a bit with macOS Monterey's new `Displays` tab in Preferences as the `Optimize for` setting tends to reset at random times to the physical display for unknown reasons during changing settings. If this happens, you can set it back to the Dummy.
- You may want to enable the `System Preferences`»`Notifications & Focus`»`Allow Notifications`»`When mirroring or sharing the display` option to allow notifications when mirroring is turned on.
- Please note that the app cannot increase the number of pixels on your display and is unable to make a 1080p display look like a 4K display (the only benefit for a 1080p display is better clarity in zooming or the ability to make high resolution screenshots).

## Installation

- Download the [latest release](https://github.com/waydabber/BetterDummy/releases)
- Move the app to Applications
- Start the app
- Use the app menu bar item to interact.

## Supporting the project

I am thankful for each of you who [contributed to the project](https://opencollective.com/betterdummy). Every little bit helps. If you find use in the app and did not contribute so far, please consider a donation. Thank you!

Please don't forget to star the GitHub page and spread the word about the app. :)

## Compatibility

- The app should be compatible with all M1 class machines running macOS Monterey (MacBook Air, Mini, 2020 and 2021 MacBook Pros).
- The app is also compatible with Intel and macOS Big Sur (testing was limited to a single Intel Mac with Intel UHD 630 running Big Sur).
- The app is compatible with headless mode as well (this was tested on Intel).

## Additional help

For most of the time, the app is self explanatory but here is a brief overview of some of the additional functions in the app.

### Manage your dummies

<div align="center">
<img src=".github/manage.png" width="469"/>
</div>

- The `Manage dummies` submenu header contains some basic info about the dummy - its aspect ratio and unique serial number.
- `Connect dummy` / `Disconnect dummy` - You can easily connect or disconnect a dummy. Only dummes that are not associated to a display can be connected or disconnected manually.
- `Set resolution` - This allows for a quick resolution change. The list conatains all supported resolutions. If `Show low resolution modes` is enabled under `Settings`, then additional non-HiDPI resolutions are shown at the bottom of the list.
- `Associate with display` or `Change association` - You can associate a dummy to a real display. This will make the dummy automatically connect or disconnect whenever the display is connected or disconnected. It is useful when docking/undocking your macbook so you don't have to manage your dummy manually every time.
- `Discard dummy` - Destroys the dummy. Use it only if you don't need a dummy anymore - otherwise it is better to just disconnect or disassociate the dummy so macOS can remember the dummy for later use (by its unique serial number).

### App settings

<div align="center">
<img src=".github/settings.png" width="469"/>
</div>

- `Start at login`, `Automatically check for updates` - general options
- `Hide menu icon` - when the menu icon is hidden, you can still change settings - simply launch the app again while it is already running and the menu icon will reappear.
- `Enable up to 16K resolutions` - you can enable up to 16384x16384 resolution (this translates to 8192x8192 HiDPI). This is mostly useful for ultrawide and double-wide displays, where the stanrad 8192px max resolution might still be constraining. Use with caution as very high resolutions tax the system heavily.
- `Show low resolution modes in menu` will allow you to set low (non-HiDPI) resolutions in the app menu under `Manage dummies`
- `Use mirrored dummy sleep workaround` - macOS has a bug that makes virtual displays (like Sidecar, AirPlay, DisplayLink, BetterDummy) freeze when they act as a mirror main on some configurations. This workaround intends to solve that issue (more or less successfully).
- `Disconnect and reconnect on sleep` - This disconnects dummies upon sleeps and reconnects them after wake.
- `Reset BetterdDummy` - discard all dummies and reset all application settings to default.

### Known issues

There are some issues which are related to limitations/issues in macOS itself:

- High refresh displays (refresh rates above 60Hz) are not supported.
- Only SDR content is supported.
- Mirroring any content to the internal display of the 2021 MacBook Pros will force the mirror under the notch.
- Due to a bug present in the current macOS versions, mirroring virtual displays (Sidecar, BetterDummy, etc) might cause sleep issues on some configurations. The app has some workarounds for this issue but these might not work on all configurations.
- Due to a bug present in the current macOS versions, swiping or keyboard shortcuts to switch spaces do not work on extended (secondary) mirror sets that involve virtual displays.

Some of these issues affect physical dummy mirrors as well.

## Don't forget to check out

**If you like this app, you'll like [MonitorControl](https://monitorcontrol.app) as well!** Control the brightness, volume of your external display like a native Apple display!

## Discord channel

You can join the (mostly self help) discussion on the new [BetterDummy discord channel](https://discord.gg/aKe5yCWXSp).

## Thanks

- [@tml1024](https://github.com/tml1024)! - FluffyDisplay + reused adapted CGVirtualDisplay headers reverse engineered by [@w0lfschild](https://github.com/w0lfschild)
- [@JoniVR](https://github.com/JoniVR) - MonitorControl + sparkle scripts
- [@the0neyouseek](https://github.com/the0neyouseek) - MonitorControl + sparkle scripts

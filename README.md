<a href="https://github.com/waydabber/BetterDisplay/releases"><img src="https://github.com/waydabber/BetterDisplay/assets/37590873/c9eaae81-78b8-4bd7-aeea-0ec445f1b0ea" width="210" alt="App icon" align="left"/></a>

<div>
<h3>BetterDisplay</h3>
<p>Custom Resolutions, XDR/HDR Extra Brightness, Virtual Screens, Picture in Picture, Soft-disconnect, Config and EDID overrides & More!</p>
<a href="https://github.com/waydabber/BetterDisplay/releases/download/v2.3.9/BetterDisplay-v2.3.9.dmg"><img src="https://user-images.githubusercontent.com/37590873/219133640-8b7a0179-20a7-4e02-8887-fbbd2eaad64b.png" width="140" alt="Download for macOS"/></a><br/>
<sub>For macOS Sequoia, Sonoma, Ventura, Monterey. For Big Sur & older: <a href="https://github.com/waydabber/BetterDisplay/releases/tag/v1.4.15">legacy v1.x</a></sub>
</div>

<br />

<div align="center">
<a href="https://github.com/waydabber/BetterDisplay/releases"><img src="https://img.shields.io/github/downloads/waydabber/BetterDisplay/total.svg?style=flat&color=blue" alt="downloads"/></a>
<a href="https://github.com/waydabber/BetterDisplay/releases"><img src="https://img.shields.io/github/release/waydabber/BetterDisplay.svg?style=flat&color=blue" alt="latest version"/></a>
<a href="https://github.com/waydabber/BetterDisplay/releases"><img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat&color=blue" alt="platform"/></a>
<a href="https://discord.gg/aKe5yCWXSp"><img src="https://img.shields.io/badge/chat-discord_invite-blue?logo=discord&style=flat&" alt="discord"/></a>
</div>

## About BetterDisplay

**BetterDisplay** is a truly wonderful tool! It lets you convert your displays to **fully scalable screens**, manage **display configuration overrides**, allows **brightness and color control**, provides **XDR/HDR brightness upscaling** (extra brightness beyond 100% for compatible XDR or HDR displays on Apple Silicon and Intel Macs - multiple methods available), **full dimming** to black, helps you **create and manage virtual screens** for your Mac, create **Picture in Picture** windows of your displays and gives you a host of other features to **manage your display's settings** easily from the menu bar. It can even **disconnect/reconnect displays** on-the-fly!

<div align="center">
<img width="832" alt="bd_rounded_2" src="https://github.com/waydabber/BetterDisplay/assets/37590873/62688588-176a-4ed1-a67f-b2c5af15b6f2">
</div>

## Key Features

- **NEW: Full support for **macOS Sequoia**.**
- [Reach the full brightness potential of your XDR or HDR display](https://github.com/waydabber/BetterDisplay/wiki/XDR-and-HDR-brightness-upscaling) - XDR brightness upscale to 1600 nits, external HDR display brightness upscale depending on the display's capability. Native XDR, color table (Apple Silicon) and Metal (Apple Silicon and Intel) methods are all supported. *
- [Native brightness upscaling for Apple XDR displays](https://github.com/waydabber/BetterDisplay/wiki/XDR-and-HDR-brightness-upscaling#enablingdisabling-hardware-native-xdr-upscaling-apple-silicon-intel-requires-apple-xdr-display) (built-in) - provides full unlock for the entire brightness range with no strings attached - no clipped or overblown HDR videos, full native sliders compatibility, no extra CPU/GPU usage. *
- Display group and synchronization features - sync brightness and other image controls among multiple displays!
- Display UI scale matching - synchronize display UI scale / resolution among multiple displays (recommended for displays with flexible scaling enabled). *
- Layout protection - create and protect an adaptive display arrangement using anchor points for natural traversal among screens. *
- Change the display's brightness, volume and colors via software and hardware (DDC) control using sliders, native or custom keyboard shortcuts!
- BetterDisplay is the only app currently with DDC control for all modern Macs (full DDC support for all Apple Silicon Macs including the M1 built-in HDMI ports, and 2018 mini built-in HDMI port).
- Change display inputs using DDC on supported displays.
- Option to auto-disconnect built-in screen upon connecting an external display - requires Apple Silicon (note: Settings/Displays/Overview/Connection management settings...). *
- [Convert your internal and natively connected external displays to flexible-scaled HiDPI displays](https://github.com/waydabber/BetterDisplay/wiki/Fully-scalable-HiDPI-desktop) using flexbile scaling (displays with notch, HDR, HDCP, high refresh rate are all supported)! *
- Change the resolution easily with a slider!
- Quickly accessible refresh rate and screen rotation menu.
- Better quality zooming (`System Preferences`»`Accessibility`»`Zoom`) or High Quality screenshots even on 1080p displays.
- Define favorite resolutions and reach them using the app menu, resolution slider or keyboard shortcuts. *
- Create custom HiDPI resolutions for real displays manually. Redefine various system display parameters!
- Disconnect and reconnect displays (removing them from the display layout and adding them back) on Apple Silicon (macOS Ventura or newer required) and Intel (all macOS version supported - on Intel the feature is considered experimental and can cause issues)! *
- Protect display configuration (resolution, refresh rate/VRR, rotation, color profile). *
- Color profile (and XDR Preset) selector.
- Auto switch color profile for SDR and HDR modes. *
- EDID override support for both Intel and Apple Silicon Macs! *
- Export display EDID and show detailed display information (Intel and Apple Silicon).
- Create any number of virtual screens with varying aspect ratios and resolutions.
- Use headless Macs (servers) with any resolution and HiDPI mode for remote access.
- [Scaled Sidecar resolutions and portrait SideCar support (via virtual screen streaming)](https://github.com/waydabber/BetterDisplay/wiki/Rotated-Sidecar). *
- [Use your iPad or monitor as a DIY Teleprompter](https://github.com/waydabber/BetterDisplay/wiki/DIY-teleprompter-flipped-screen). *
- [Enable Night Shift for your TV](https://github.com/waydabber/BetterDisplay/wiki/Enable-Night-Shift-for-televisions).
- [Help width display flickering (PWM, temporal dithering)](https://github.com/waydabber/BetterDisplay/wiki/Eye-care:-prevent-PWM-and-or-temporal-dithering).
- Create Picture in Picture window for any real display or virtual screen. *
- Redirect your display's contents (real or virtual) to another screen with local streaming. *
- Use the bottom half of your TV as a wide screen display (off-center streaming). *
- Simplify creating mirrored sets. *
- Easily move around displays relative to each other using the app menu.
- Keyboard shortcuts for brightness and audio control.
- Advanced keyboard shortcuts support. *
- [Various CLI and app integration features](https://github.com/waydabber/BetterDisplay/wiki/Integration-features,-CLI) (command line, [betterdisplaycli](https://github.com/waydabber/betterdisplaycli), custom URL schema, HTTP, notifications).
- MacOS Shortcuts (App Intents) support for various operations.
- [MediaMate](https://wouter01.github.io/MediaMate/) support for OSDs with fresh visuals (latest versions required for both apps). *

... [and more is coming](https://github.com/waydabber/BetterDisplay/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3Aenhancement)! :)

_Note: features marked with an asterisk (*) require a [Pro license](https://github.com/waydabber/BetterDisplay/wiki/Getting-a-Pro-License)._

[For a list of free and Pro features and comparison to MonitorControl, click here...](https://github.com/waydabber/BetterDisplay/wiki/List-of-free-and-Pro-features)

## Getting a Pro license to unlock all features

You can support development and unlock all features of the app by **[purchasing a Pro license for $18 / €18](https://betterdisplay.pro/buy)** (Sales Tax or VAT may also apply depending on selected territory). You can also get Pro inside the app - just navigate to `Settings` (gear icon) > `Pro` and click on `Buy BetterDisplay Pro`.

<div align="center">
<a href="https://betterdisplay.pro/buy"><img width="500" src="https://github.com/waydabber/BetterDisplay/assets/37590873/6a732657-1e72-4b98-91e6-7a56abb716d3"></a>
</div>

Please note that even if you don't buy the app, you can still use many of the features for free (if you are a non-business user). A 14-day trial is also available to fully evaluate BetterDisplay Pro before purchase.

[More information on purchasing Pro & payment methods](https://github.com/waydabber/BetterDisplay/wiki/Getting-a-Pro-License)

For more information on licensing, trial, prices and refund, privacy, please read the [License Terms & Conditions, Refund and Privacy Policy](https://github.com/waydabber/BetterDisplay/discussions/739)!

Please don't forget to star the GitHub page and spread the word about the app! :)

## Installation

Install the app using one of the following methods:

### Manual
1. Download the [latest version](https://github.com/waydabber/BetterDisplay/releases)
1. Open the `.dmg` file and move the app to `/Applications` folder.
1. Start the app from `/Applications` folder or from Launchpad / Spotlight.
1. Use the BetterDisplay icon in the menu bar to access the app's features.

### Homebrew
1. Install [Homebrew](https://brew.sh/)
1. Run `brew install --cask betterdisplay`
   
## Using the App

The app contains detailed explanations for most features (under `Settings` - click the gear icon at the bottom of the app menu). Check out the [Wiki section](https://github.com/waydabber/BetterDisplay/wiki) for more info on app usage.

If you have any questions, search for answers under [Discussions](https://github.com/waydabber/BetterDisplay/discussions) and the BetterDisplay [Discord channel](https://discord.gg/aKe5yCWXSp) (it has an extensive history and forum threads, most questions have been asked and answered several times over). If you don't find answers, feel free to create a new discussion or Discord forum thread!

## Compatibility

- The latest v2.x version of the app is compatible with all **Apple Silicon** and **Intel** Macs running macOS **Sequoia** (app version v2.3.5 and up), **Sonoma**, **Ventura** and the latest version of **Monterey**.
- The v1.x app version is compatible with macOS **Monterey**, **Big Sur**, **Catalina** and **Mojave**.
- XDR/HDR upscaling requires an Apple XDR display (built-in or external) or a natively connected external HDR display (VESA DisplayHDR 600 or higher recommended).
- The display connect/disconnect feature requires an Apple Silicon Mac running at least macOS Ventura or an Intel Mac (all macOS versions supported - on Intel the feature is experimental only). External display sleep/suspend on disconnect is available only on Apple Silicon (on Intel, dimming or DDC backlight off is available for third party displays - backlight off works for Apple and built-in displays).
- Flexible scaling requires macOS Monterey 12.4 (or newer) and natively connected displays. For Intel all macOS versions work.
- Maximum flexible scaling resolutions depend on GPU capabilities and the display's resolution (horizontal width limit is 6144 pixels for entry level Apple Silicon Macs, 7680 pixels for the Pro/Max/Ultra versions).
- External display hardware backlight control and volume control require DDC capable, natively connected display or an Apple display. Some docks and dongles may not support DDC. All built-in ports of all Macs that can run the app are supported for DDC communication.
- The app is compatible with headless Macs to create custom virtual screen resolutions for remote access.

## Discord Channel

You can join the discussion on the [BetterDisplay Discord channel](https://discord.gg/aKe5yCWXSp). If you have any issues or questions, don't hesitate to ask!

## Localization

The app supports localization. Special thanks to everybody who has contributed and is contributing to the localization effort!

[Check out the current localization status and on how to contribute!](https://github.com/waydabber/BetterDisplay/discussions/2165)!


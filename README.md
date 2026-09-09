<div align="center">
<a href="https://github.com/waydabber/BetterDisplay/releases"><img src="https://github.com/user-attachments/assets/3a3e7683-1bfc-4ba1-9a91-4a458488899f" width="290" height="290" alt="BetterDisplay" align="center"/></a>

<h2>BetterDisplay Pro</h2>
<p>Flexible HiDPI scaling, advanced image adjustments, custom 3D LUTs, XDR/HDR brightness, virtual screens, picture-in-picture, display arrangement, DDC and HDMI-CEC control, and more.</p>
<a href="https://github.com/waydabber/BetterDisplay/releases/download/v5.0.5/BetterDisplay-v5.0.5.dmg"><img src="https://user-images.githubusercontent.com/37590873/219133640-8b7a0179-20a7-4e02-8887-fbbd2eaad64b.png" width="180" alt="Download for macOS"/></a><br/>
<sub>
<b>macOS 27 Golden Gate and macOS 26 Tahoe:</b> Download the <a href="https://github.com/waydabber/BetterDisplay/releases/tag/v5.0.5">BetterDisplay v5.0.5</a><br/>
<b>macOS Sequoia, Sonoma, and Ventura:</b> Download <a href="https://github.com/waydabber/BetterDisplay/releases/download/v4.3.6/BetterDisplay-v4.3.6.dmg">BetterDisplay v4.3.6</a><br/>
Previous versions:
<a href="https://github.com/waydabber/BetterDisplay/releases/download/v3.5.6/BetterDisplay-v3.5.6b.dmg">v3.5.6</a> |
<a href="https://github.com/waydabber/BetterDisplay/releases/download/v2.3.9/BetterDisplay-v2.3.9.dmg">v2.3.9 — macOS Monterey</a> |
<a href="https://github.com/waydabber/BetterDisplay/releases/download/v1.4.15/BetterDisplay-v1.4.15.dmg">v1.4.15 — macOS Mojave, Catalina, and Big Sur</a><br/>
<a href="https://github.com/waydabber/BetterDisplay/releases">Browse all releases</a>
</sub>
</div>

<br/>

<div align="center">
<a href="https://github.com/waydabber/BetterDisplay/releases"><img src="https://img.shields.io/github/downloads/waydabber/BetterDisplay/total.svg?style=flat&color=blue" alt="Total downloads"/></a>
<a href="https://github.com/waydabber/BetterDisplay/releases"><img src="https://img.shields.io/badge/platform-macOS-lightgrey.svg?style=flat&color=blue" alt="Platform: macOS"/></a>
<a href="https://discord.gg/aKe5yCWXSp"><img src="https://img.shields.io/discord/903276571773771796?label=chat&style=flat&color=blue&logo=discord" alt="BetterDisplay Discord community"/></a>
</div>

<br/>

## About BetterDisplay

**BetterDisplay** gives you control over your Mac’s displays from the menu bar. Configure **flexible HiDPI scaling**, adjust **brightness and color**, unlock additional brightness on compatible **XDR and HDR displays**, and manage **display arrangements, configuration overrides, and virtual screens**.

Use **advanced image filters and custom 3D LUTs**, view displays or selected windows in **picture-in-picture**, and connect or disconnect displays without unplugging them. Hardware controls, display groups, keyboard shortcuts, and automation help you manage everything from a single monitor to a complex multi-display setup.

<div align="center">
<img width="832" height="630" src="https://github.com/user-attachments/assets/c9c9be58-d86b-402e-bf33-a7ddfb5915bf" alt="BetterDisplay interface and display controls"/>
</div>

## Key Features

**NEW** marks features introduced or substantially expanded in BetterDisplay 5.

- **NEW — Advanced image adjustments:** Apply expanded compositor filters for sharpening, geometry, and color adjustments, with support for display-group syncing, the CLI, and macOS Shortcuts. \*
- **NEW — Custom 3D LUTs:** Import and apply custom 3D LUTs to display image adjustments and PIP/stream video filters. \*
- **NEW — Selected-window streaming:** Create picture-in-picture views of individual windows or window groups, with filters, presentation options, and target frame-rate controls. \*
- **NEW — HDMI-CEC control:** Control TV volume, mute, power, and input selection through compatible HDMI connections, including through the CLI.
- **NEW — Sidebar and refreshed app menu:** Choose an optional Control Center-style sidebar, use the updated Liquid Glass interface, and access common actions by right-clicking the menu bar icon.
- **NEW — Visual display arrangement:** Arrange displays directly from the app menu using visual controls, on-screen guides, and grid snapping.
- **NEW — Built-in console and expanded automation:** Access CLI features and app logs inside BetterDisplay. Configure per-display commands for connection, disconnection, sleep, and wake events. Per-display command integration requires Pro.
- **NEW — Expanded display diagnostics:** Inspect connection, bandwidth, compression, and tiling information, and access EDID, DPCD, DSC, HDMI-CEC, and Apple brightness reports through the CLI.
- **NEW — Broader localization:** Use BetterDisplay in 38 language and regional variants, with expanded translations and right-to-left interface support for Arabic, Hebrew, and Persian.
- **Flexible HiDPI scaling:** [Make built-in and natively connected external displays fully scalable](https://github.com/waydabber/BetterDisplay/wiki/Fully-scalable-HiDPI-desktop), including support for notched displays, HDR, HDCP, and high refresh rates. \*
- **XDR/HDR brightness upscaling:** [Access additional brightness on compatible displays](https://github.com/waydabber/BetterDisplay/wiki/XDR-and-HDR-brightness-upscaling), including up to 1600 nits on supported Apple XDR displays. Available methods depend on your Mac, display, and macOS version. \*
- **Brightness, volume, and color control:** Adjust displays through software controls, DDC, sliders, and keyboard shortcuts, including software dimming down to black.
- **Display groups and brightness syncing:** Synchronize brightness and image controls across displays, including normalized brightness matching in nits and automatic UI scale matching. Advanced synchronization features require Pro.
- **Display connection management:** Disconnect and reconnect displays without unplugging them, automatically disconnect the built-in screen when an external display is connected on Apple Silicon, and quickly switch between one display and the rest of your setup. \*
- **Layout and configuration protection:** Preserve display arrangements, resolution, refresh rate or VRR settings, rotation, and color profiles. Use adaptive layout anchors to maintain natural pointer movement between screens. \*
- **Virtual screens:** Create virtual displays with custom resolutions and aspect ratios, including HiDPI desktops for headless Macs and remote access. HDR and high-refresh-rate virtual screens are available on compatible Macs. Advanced virtual-screen capabilities require Pro.
- **Picture-in-picture and local streaming:** View a physical or virtual display in a PIP window, stream its contents to another display, and apply video filters. Supports workflows such as [portrait Sidecar](https://github.com/waydabber/BetterDisplay/wiki/Rotated-Sidecar) and [teleprompter displays](https://github.com/waydabber/BetterDisplay/wiki/DIY-teleprompter-flipped-screen). \*
- **Custom resolutions and display overrides:** Create custom HiDPI resolutions and adjust system display parameters. EDID overrides are supported on both Apple Silicon and Intel Macs. EDID overrides require Pro.
- **Color modes and HDR controls:** Select available RGB or YCbCr modes, chroma subsampling, HDMI range, and additional refresh rates on supported Apple Silicon configurations. Forced HDR switching is available for supported displays and requires Pro.
- **Color profiles and XDR presets:** Select color profiles and XDR presets from the app menu. Automatic profile switching between SDR and HDR modes requires Pro.
- **DDC hardware control:** Automatically detect supported DDC capabilities and control brightness, volume, and input selection on compatible displays, including through supported built-in HDMI ports.
- **Network device control:** Control supported LG webOS, Samsung Tizen, and Philips Android TVs, as well as Yamaha AV receivers.
- **Resolution and shortcut controls:** Change resolution with a slider and access refresh rate and rotation settings from the menu bar. Favorite resolutions and advanced keyboard shortcuts require Pro.
- **Custom on-screen displays:** Choose modern or traditional OSD presentation for brightness and audio controls, with styling and placement adapted to macOS.
- **Integration and scripting:** Use [CLI and app integration features](https://github.com/waydabber/BetterDisplay/wiki/Integration-features,-CLI), including [betterdisplaycli](https://github.com/waydabber/betterdisplaycli), custom URL schemes, HTTP, notifications, and macOS Shortcuts. Control integration through shell scripts and URLs requires Pro.

_Features marked with an asterisk (\*) require a [Pro license](https://github.com/waydabber/BetterDisplay/wiki/Getting-a-Pro-License). Hardware and macOS requirements vary by feature._

[Compare free and Pro features](https://github.com/waydabber/BetterDisplay/wiki/List-of-free-and-Pro-features) · [View planned enhancements](https://github.com/waydabber/BetterDisplay/issues?q=is%3Aissue+is%3Aopen+sort%3Aupdated-desc+label%3Aenhancement)

## BetterDisplay Pro

Unlock all features and support development by **[purchasing a Pro license at betterdisplay.pro](https://betterdisplay.pro)**, the official website. Pricing is $21.99 / €19.99; price, currency, and taxes may vary by country or state. You can also purchase a license in the app under **Settings > Pro > Buy BetterDisplay Pro**.

A Pro license provides access to the current major version and previous versions where needed for compatibility. Your purchase includes at least one year of updates, including major upgrades released during that period. The license is **perpetual, not a subscription**: you can continue using the versions covered by your license.

<div align="center">
<a href="https://betterdisplay.pro/#buy"><img width="500" src="https://github.com/waydabber/BetterDisplay/assets/37590873/6a732657-1e72-4b98-91e6-7a56abb716d3" alt="Purchase BetterDisplay Pro"/></a>
</div>

Many features are available free for non-business use. A **14-day trial** lets you evaluate all Pro features before purchasing.

- [Purchasing Pro and supported payment methods](https://github.com/waydabber/BetterDisplay/wiki/Getting-a-Pro-License)
- [BetterDisplay 5 upgrade eligibility and outdated licenses](https://github.com/waydabber/BetterDisplay/discussions/5632)
- [License terms, refunds, and privacy policy](https://github.com/waydabber/BetterDisplay/discussions/739)

## Installation

### Manual installation

1. Download the [release appropriate for your macOS version](https://github.com/waydabber/BetterDisplay/releases).
2. Open the `.dmg` file and drag BetterDisplay to the `/Applications` folder.
3. Open BetterDisplay from Applications or Spotlight.
4. Click the BetterDisplay icon in the menu bar to access its controls.

### Homebrew

Install [Homebrew](https://brew.sh/), then run:

```bash
brew install --cask betterdisplay
```

To install a specific release candidate, use the manual download above.

## Using the App

Most features include explanations in **Settings**, accessible through the gear icon in the app menu. The [BetterDisplay wiki](https://github.com/waydabber/BetterDisplay/wiki) provides additional guides and configuration examples.

For help, search [GitHub Discussions](https://github.com/waydabber/BetterDisplay/discussions) or the [BetterDisplay Discord community](https://discord.gg/aKe5yCWXSp). If you cannot find an answer, start a new discussion or Discord forum thread.

## Compatibility

### macOS versions

- **BetterDisplay 5:** Apple Silicon and Intel Macs running **macOS 26 Tahoe (26.3 or later)**, with full support for **macOS 27 Golden Gate**.
- **BetterDisplay 4:** Macs running **macOS Ventura (13.2 or later)**, Sonoma, Sequoia, Tahoe, or Golden Gate.
- **BetterDisplay 3.5.6:** macOS Ventura (13.2 or later), Sonoma, and Sequoia.
- **BetterDisplay 2.3.9:** macOS Monterey (12.4 or later), Ventura, and Sonoma.
- **BetterDisplay 1.4.15:** Available for older systems, including macOS Mojave, Catalina, and Big Sur.

### Hardware and feature requirements

- **XDR/HDR brightness upscaling** requires a compatible Apple XDR display or a natively connected external HDR display. VESA DisplayHDR 600 or higher is recommended for external HDR displays.
- **Display disconnection** is supported on Apple Silicon and Intel Macs. Intel support is experimental. Putting an external display to sleep when disconnected is available on Apple Silicon; Intel configurations may use dimming or supported backlight controls instead.
- **Flexible scaling** requires a natively connected display. On Apple Silicon, it requires macOS Monterey 12.4 or later; use a compatible older BetterDisplay release for macOS versions predating the current app’s minimum requirements.
- **Maximum scaling resolutions** depend on your GPU and display capabilities.
- **Hardware brightness, volume, and input control** require a compatible Apple display or a DDC-capable display and connection. Some docks and adapters do not pass DDC commands.
- **HDMI-CEC control** requires a compatible HDMI port or adapter and a CEC-capable device.
- **Headless Macs** are supported through virtual screens with custom resolutions for remote access.

### Third-party OSD integrations

The following apps integrate with BetterDisplay through its [OSD integration API](https://github.com/waydabber/BetterDisplay/wiki/Integration-features,-CLI#osd-notification-dispatch-integration):

- [MediaMate](https://wouter01.github.io/MediaMate/)
- [DynamicLake](https://www.dynamiclake.com)
- [Alcove](https://tryalcove.com)
- [Atoll](https://getatoll.app)

See the [BoringNotch integration discussion](https://github.com/TheBoredTeam/boring.notch/issues/943) for that project’s implementation status.

### Raycast extension

The [BetterDisplay extension for Raycast](https://www.raycast.com/pascal_burkhard/betterdisplay) provides another way to access BetterDisplay controls.

## Localization

BetterDisplay includes 38 language and regional variants:

Arabic, Bulgarian, Catalan, Chinese (Simplified), Chinese (Traditional), Croatian, Czech, Danish, Dutch, English, English (British), Finnish, French, German, Greek, Hebrew, Hindi, Hungarian, Indonesian, Italian, Japanese, Korean, Malay, Norwegian Bokmål, Persian, Polish, Portuguese (Brazil), Portuguese (Portugal), Romanian, Russian, Slovak, Slovenian, Spanish, Swedish, Thai, Turkish, Ukrainian, and Vietnamese.

BetterDisplay 5 adds many new translations, improves existing localizations, and supports right-to-left layouts for Arabic, Hebrew, and Persian.

Thank you to everyone who contributes translations and improvements.

[View localization status and contribution information](https://github.com/waydabber/BetterDisplay/discussions/2165)

## Contact and Community

- **Official website:** [betterdisplay.pro](https://betterdisplay.pro)
- **Technical support and community:** [BetterDisplay Discord](https://discord.gg/aKe5yCWXSp)
- **Questions and feature discussions:** [GitHub Discussions](https://github.com/waydabber/BetterDisplay/discussions)
- **Purchase and payment support:** [Paddle Support](https://www.paddle.com)

BetterDisplay is developed by [@waydabber](https://github.com/waydabber) at [Kodeon Software](https://kodeonsoftware.com). Paddle is the app’s reseller.

For licensing inquiries, email <span>info<i>&#64;</i>kodeon</span>software<i>&#46;</i><span>com</span>. Please use Discord for technical support.

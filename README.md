# BetterDummy

Dummy Display for Apple Silicon Macs to achieve custom resolutions.

## About

M1 macs tend to have issues with custom resolutions. Notoriously they don't allow sub 4K resolution displays to have HiDPI ("Retina") resolutions even though for example a 24" QHD display would greatly benefit from having an 1920x1080 HiDPI "Retina" mode.

To fix this issue, many resort to buying a 4K HDMI dummy dongle to fool macOS into thinking that a 4K display is connected and then mirror the contents of this dummy display to the physical display in order to have HiDPI resolution. Others use the built in screens of their MacBooks to mirror to the external display. These approaches have obvious drawbacks and cannot solve all problems (for example HiDPI support for wide and ultrawide displays).

To fix this problem, BetterDummy creates a virtual dummy display which you can then utilize as a mirror main.

Advantages of BetterDummy over a physical 4K HDMI dummy plug:

- Your HDMI port will remain usable for an other display on the Mac Mini
- Does not suffer from issues that prevalent with the physical dummy (like jittery mouse cursor).
- Offers a much wider variety of HiDPI and standard resolutions.
- Works with all aspect ratios, does not depend on what resoluations are recorded in the dummy's EDID/firmware.
- Does not utilize graphics hardware in vain so it is somewhat faster.
- Available instantly + it is free. :)

## Usage

1. Start the app
1. In the app menu choose `Create New Dummy` and select your desired aspect ratio
<br/>
<div align="center">
<img src=".github/menu.png" width="430"/>
</div>
<br/>
  
3. In `System Preferences` -> `Displays` you'll see the new Dummy display (for example `Dummy 16:9`)
4. Activate mirroring. The `Main` display should be the Dummy display
5. Set the Dummy display as `Optimize for`
6. Set `Resolution` as `Scaled` - you might have to hold the `Option` key to see a detailed list of available resolutions
7. You can also click `Show all resolutions` for even more resolutions

<div align="center">
<img src=".github/displayprefs.png" width="500"/>
</div>

9. Select the desired mode.

Notes:

- For most configurations, you'll see HiDPI 'Retina' resolutions in the list by default and see and additional non-HiDPI resolutions marked with a `(low resolution)` tag in the resolution list if `Show all resolutions` is toggled. On some configurations however, you might see HiDPI (high resolution) display modes marked with a `(HiDPI)` tag and standard resolutions _without a tag_.
- You might have to fight a bit with macOS Monterey's new `Displays` tab in Preferences as the `Optimize for` setting tends to reset at random times to the physical display for unknown reasons during changing settings. If this happens, you can set it back to the Dummy.

The app saves the dummy display configuratio and automatically restores it upon next restart.

## Installation

- Download the [latest release](https://github.com/waydabber/BetterDummy/releases)
- Move the app to Applications
- Start the app
- Use the app menu bar item to interact.

## Compatibility

The app should be compatible with all M1 class machines (MacBook Air, Mini, 2020 and 2021 MacBook Pros) running Monterey.

## How can I help?

Some of the options:

- You can contribute to the code (via Pull Requests)
- If you like the app, [you can support the developer](https://opencollective.com/betterdummy/donate). :)
- Don't forget to star the GitHub page!
- Spread the word.

Thank you for your help, it is really appreciated! :)

## Don't forget to check out

**If you like this app, you'll like [MonitorControl](https://monitorcontrol.app) as well!** Control the brightness, volume of your external display like it would be a native Apple display!

## Discord channel

You can join the (mostly self help) discussion on the new [BetterDummy discord channel](https://discord.gg/aKe5yCWXSp).

## Special Thanks

Some of the original code was adapted from [FluffyDisplay](https://github.com/tml1024/FluffyDisplay). Thanks to [@tml1024](https://github.com/tml1024)!

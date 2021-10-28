# BetterDummy

Dummy Display for Apple Silicon Macs to achieve custom resolutions.

## About

M1 macs tend to have issues with custom resolutions. Notoriously they don't allow sub 4K resolution displays to have HiDPI ("Retina") resolutions even though a 22" - 24" QHD display would greatly benefit from having an 1920x1080 HiDPI mode.

To fix this issue, many resort to buying a 4K HDMI dummy dongle to fool macOS into thinking that a 4K display is connected and then mirror the contents of this dummy display to the physical lower-res display in order to have HDMI resolution. This approach has obvious drawbacks (you need to buy a dummy, you render your HDMI port useless etc.)

To alleviate this problem, DummyDisplay creates a virtual dummy display for you which you can then utilize as a mirror main.

Advantages of BetterDummy over a physical 4K HDMI dummy plug:

- Your HDMI port will remain usable for an other display.
- Does not suffer from issues that prevalent with the physical dummy route (like jittery mouse cursor).
- Offers a much wideer variety of HiDPI and standard resolutions.
- Works with all aspect ratios, does not depend on what resoluations are recorded in the dummy's EDID/firmware.
- Does not utilize graphics hardware in vain so it is somewhat faster.
- Available instantly + totally free. :)

## Usage

1. Start the app
1. In the app menu choose `Connect Dummy` and select your desired aspect ratio
<br/>
<div align="center">
<img src=".github/menu.png" width="430"/>
</div>
<br/>
  
3. In `System Preferences` -> `Displays` you'll see the new screen (for example `Dummy 16:9`)
4. Activate mirroring with main display being the Dummy display
5. Set the dummy display as `Optimize for`
6. Set `Resolution` as `Scaled`
7. Click `Show all resolutions`

<div align="center">
<img src=".github/displayprefs.png" width="500"/>
</div>

9. You'll see a long list of available resolutions. 

**Important:** depending on configration, you might see HiDPI (high resolution) display modes listed with a `(HiDPI)` tag _OR_ you might see HiDPI resolutions without a tag and non-HiDPI resolutions with a `(low resolution)` tag in the list. It is adviced to choose always choose the high resolution option.

NOTES:

- HiDPI resolutions are followed by non-HiDPI resolutions so **don't forget to scroll down**, it's a long list!
- You might have to fight with the `Displays` tab in Preferences sometimes as (at least on Monterey) the `Optimize for` setting tends to reset at random times to the physical display for unknown reasons while changing the settings (the `Displays` tab appears to be rather buggy in general).

The app saves the dummy display configuratio and automatically restore it upon next restart.

## Compatibility

The app and instructions were tested on an M1 MBA and mini running Monterey but according to reports works on Big Sur as well.

## Build and Installation

You'll need to build the app in XCode:

- Clone the app
- Open the project in XCode
- Change signing settings to suit your configuration
- Build & Run

An unsigned beta release is [also provided](https://github.com/waydabber/BetterDummy/releases/tag/v1.0.0-beta1).

## Don't forget to check out

**If you like this app, you'll like [MonitorControl](https://monitorcontrol.app) even more!** Control the brightness, volume of your external display like it would be a native Apple display!

## How to help

You can contribute to the code. [You can now also donate](https://opencollective.com/betterdummy/donate).

Thank you for your care and help, really appreciated! :)

## Discord channel

You can join the (mostly self help) discussion on the new [BetterDummy discord channel](https://discord.gg/aKe5yCWXSp).

## Special Thanks

The basic idea and some of the code was adapted from [FluffyDisplay](https://github.com/tml1024/FluffyDisplay). Thanks to [@tml1024](https://github.com/tml1024)!

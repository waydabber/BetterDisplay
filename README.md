# BetterDummy

Dummy Display for Apple Silicon Macs to achieve custom resolutions.

## About

M1 macs tend to have issues with custom resolutions. Notoriously they don't allow sub 4K resolution displays to have HiDPI ("Retina") resolutions even though a 22" - 24" QHD display would greatly benefit from having an 1920x1080 HiDPI mode.

To fix this issue, many resort to buying a 4K HDMI dummy dongle to fool macOS into thinking that a 4K display is connected and then mirror the contents of this dummy display to the physical lower-res display in order to have HDMI resolution. This approach has obvious drawbacks (you need to buy a dummy, you render your HDMI port useless etc.)

To alleviate this problem, DummyDisplay creates a virtual dummy display for you which you can then utilize as a mirror main.

More info about the problem in the [MacRumors thread](https://forums.macrumors.com/threads/solution-quadhd-monitor-with-hidpi-and-mac-mini-m1.2303291/)

If you like this app, you'll like [MonitorControl](https://monitorcontrol.app) even more!

## Usage

- Start the app
- In the menu choose `Connect Dummy` and select your desired aspect ratio
- In `System Preferences` -> `Displays` you'll see the new screen (for example `Dummy 16:9`)
- Activate mirroring
- Set the dummy display as `Optimize for`
- Set `Resolution` as `Scaled`
- Click `Show all resolutions`
- You'll see a long list of available resolutions (normal resolutions followed by HiDPI resolutions) - select the desired resolution

The app saves the dummy display configuratio and automatically restore it upon next restart.

The app and instructions was tested on Monterey.

## TODOs

The app is being actively developed. Here are some things I plan to do:

- Improve serial number, vendor and product id settings
- Add sleep detection and virtual screen disconnect during sleep
- Add autostart option
- Nicer app icon
- Update [MonitorControl](https://monitorcontrol.app) to interoperate seamlessly with this (MC will not attempt to control displays with 'Dummy' name in them).
- Add releases

## Known issues

- Sleep mode has issues with some configurations (the virtual screen prevents the display from turning off). This is being investigated.

## Installation

You'll need to build the app in XCode. Releases will be provided later.

## Special Thanks

Some of the code and the basic technique was taken from [FluffyDisplay](https://github.com/tml1024/FluffyDisplay). Thanks to [@tml1024](https://github.com/tml1024)!

## How to help

You can contribute to the code. If you want to donate or buy me a lunch, please let me know!

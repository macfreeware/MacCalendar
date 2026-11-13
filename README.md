<p align="center">
  <img src="AppIconPreview.png" width="128" alt="MacCalendar icon">
</p>

<h1 align="center">MacCalendar</h1>

<p align="center">
  A free, open-source <b>menu bar calendar</b> for macOS with a <b>dual world clock</b> and country flags (<code>🇹🇷 20:04   🇯🇵 02:04</code>).<br>
  Written in Swift with AppKit and SwiftUI; no Electron and no third-party libraries.
</p>

<p align="center">
  A free alternative to <b>Itsycal</b>, <b>Dato</b> and <b>Clocker</b>: a month calendar and a second time zone right in the menu bar.
</p>

<p align="center">
  <b>🇬🇧 English</b> · <a href="README.tr.md">🇹🇷 Türkçe</a>
</p>

<p align="center">
  <a href="https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.pkg"><img src="docs/download-button.png" width="341" alt="Download MacCalendar for macOS"></a>
</p>

<p align="center">
  <a href="https://macfreeware.github.io/maccalendar/">Website</a> · <a href="https://gitlab.com/freeware2/maccalendar/-/releases">All releases</a> · <a href="#download-and-install">Installation steps</a> · The interface is in English and Turkish
</p>

> [!warning] The first time you open the installer, macOS blocks it. This is expected.
> MacCalendar is free and not notarized by Apple, so when you double-click the downloaded `MacCalendar-<version>.pkg` for the first time, macOS says it *could not verify* the package and does not open it. You only need to allow it once:
>
> 1. In the warning, click **Done**. Do **not** click *Move to Trash*.
> 2. Open **System Settings ▸ Privacy & Security** and scroll down to **Security**.
> 3. Next to *"MacCalendar-&lt;version&gt;.pkg" was blocked to protect your Mac*, click **Open Anyway** and confirm with your password or Touch ID. The installer opens.
>
> Prefer Terminal? Run `xattr -d com.apple.quarantine ~/Downloads/MacCalendar-*.pkg`, then double-click the package.

## Screenshots

The date and both clocks in the menu bar, the calendar that opens with a click, and the same window with Settings open.

<p align="center"><img src="docs/screenshots/menu-bar.png" width="338" alt="Menu bar: calendar icon with the day, the date, Turkey 00:54 and Japan 06:54"></p>

<p align="center">
  <img src="docs/screenshots/calendar.png" width="330" alt="Calendar window: local time with flag, Tokyo as the second clock, the month grid and the quick note field">
  &nbsp;
  <img src="docs/screenshots/settings.png" width="330" alt="Settings panel: second clock city, custom label, language, flag style, date format, seconds, week start and launch at login">
</p>

## Features

### Menu bar

- **Date and time formats:** `30 Oct Fri`, `30.10.2026`, `30 October`, a small calendar icon with today's day number, or the time alone; seconds are optional.
- **Dual clock (on or off):** show only the local time (`🇹🇷 20:04`) or the local time next to a second city (`🇹🇷 20:04   🇯🇵 02:04`).
  Seven layouts: flags before the time, after the time, in the middle, second flag only, flag with a city code, flags with both codes, or codes without flags (`IST 20:04   TYO 02:04`).
- **Local time on the right:** keep your own time in the top-right corner, after the second city (`🇯🇵 02:04   🇹🇷 20:04`).

### Calendar flyout

- **Header:** your country's flag (from the system time zone and region), a large live clock with seconds and the full date.
  With the second clock on, a card shows the other city's flag, name, time difference (e.g. `+6 hrs`) and live time.
- **Month grid:** weekends in color, days of the previous and next month dimmed, today and the selected day highlighted.
- **Today** button to jump back from any month or year; click the month title to pick a month and year.
- Week starts on Monday or Sunday, as you choose.

### Quick notes for a day

- Click any day to add a short note or reminder.
- Days with notes get a dot on the grid; notes are listed and deleted per day.

### 400+ world cities and time zones

- Presets for major cities (Tokyo, London, New York, Berlin, Paris, Seoul, Dubai, Singapore, Los Angeles, Beijing, Sydney, Baku and more).
- Search more than 400 cities to use any time zone as the second clock, with an optional custom label (`TYO`, `Office`, `HQ`).

### Language, login and quit

- **English, Turkish or the system language**, switched in Settings without restarting: labels, menu bar formats, month and weekday names change at once.
- **Launch at login** through macOS `ServiceManagement` (`SMAppService`).
- **Quit confirmation:** the power button asks first, so a stray click does not close the app.

## Download and install

The package runs on Apple Silicon and Intel Macs; macOS 13 or later is required.

1. Download the installer with the [download button](https://gitlab.com/freeware2/maccalendar/-/releases/permalink/latest/downloads/MacCalendar.pkg) at the top, or pick a version on the [Releases](https://gitlab.com/freeware2/maccalendar/-/releases) page.
2. Double-click `MacCalendar-<version>.pkg`. **The first time, macOS blocks it:** follow the steps below once.
3. Click through the installer. MacCalendar is installed in **Applications**, opens by itself and its icon appears in the menu bar, next to the system clock.
4. From then on MacCalendar starts whenever you log in. You can turn this off in its Settings (*Launch Automatically at Login*).

Prefer no installer? Each release also has a `MacCalendar.zip`: open it and drag `MacCalendar.app` to **Applications**.

### First launch: allow the installer once

> [!important] macOS blocks the installer the first time you open it. This is expected, not a fault.
> The package is not signed with an Apple developer ID and is not notarized by Apple, so macOS cannot verify it. Allow it once:
>
> 1. **Double-click the package.** macOS says Apple could not verify it and does not open it. Click **Done**. Do **not** click *Move to Trash*.
> 2. **Open System Settings ▸ Privacy & Security** and scroll down to the **Security** section.
> 3. **Click Open Anyway** on the line saying the package was blocked, then confirm with your Mac password or Touch ID. The installer opens.
>
> Don't see *Open Anyway*? Repeat step 1: the button only appears after an attempt to open the package. On macOS 13 and 14 you can also right-click the package in the Finder and choose **Open**.

> [!tip] Using Terminal? One command does the same.
> ```bash
> xattr -d com.apple.quarantine ~/Downloads/MacCalendar-*.pkg
> ```
> It removes the quarantine flag macOS puts on files downloaded from the internet. The package then opens with a double-click as usual.

### Verifying the download

Compare the package with the SHA-256 value in the release notes:

```bash
shasum -a 256 ~/Downloads/MacCalendar-1.3.0.pkg
```

## Building from source

Requires the Xcode command line tools (macOS 13 or later).

```bash
./build_app.sh          # builds MacCalendar.app (universal: arm64 + x86_64)
./build_app.sh --zip    # also build/release/MacCalendar.zip and its SHA-256
scripts/build_pkg.sh    # installer: build/release/MacCalendar-<version>.pkg and its SHA-256
```

## FAQ

### Is MacCalendar free?

Yes. MacCalendar is free and open source under the GPL-3.0 license, with no ads, no accounts and no in-app purchases.

### How do I show a calendar in the Mac menu bar?

The macOS menu bar clock has no month view. Install MacCalendar and click the date in the menu bar: a month calendar opens with today highlighted, a **Today** button and quick notes for any day.

### How do I add a second time zone or world clock to the Mac menu bar?

Turn on the dual clock in MacCalendar's Settings and pick any of more than 400 cities. The menu bar then shows both times with country flags, for example `🇹🇷 20:04   🇯🇵 02:04`, and the calendar shows the time difference.

### Does it show my Apple Calendar events?

No. MacCalendar shows the month grid and its own quick notes for each day; it does not read events from the Calendar app.

### Which Macs does it run on?

Apple Silicon and Intel Macs with macOS 13 Ventura or later.

### How does it update, and does it connect to the internet?

MacCalendar updates itself from 1.2.0 on. Once a day it asks GitLab for the latest version; that request sends nothing about you or your notes, and it is the only internet connection the app makes. If there is a new version, it asks first: **Update Now**, **Later** or **Skip This Version**. The download is checked (SHA-256, app identity, version and signature) before it replaces the app. Turn the daily check off in Settings (*Check for Updates Automatically*), or check by hand with **Check for Updates…** in About.

The installer hands the app to the user who installed it, the same as dragging it to Applications; without that it could not update itself. On a Mac with several users, a copy that belongs to someone else opens the download page instead.

### Why does macOS block it the first time?

MacCalendar is not notarized by Apple, which needs a paid developer account. Allow it once in **System Settings ▸ Privacy & Security ▸ Open Anyway**; see [First launch](#first-launch-allow-the-installer-once).

<sub>Itsycal, Dato and Clocker are named only for comparison; MacCalendar is not affiliated with them.</sub>

## License

Copyright © 2026 Rafet SAPANCI

MacCalendar is free software: you can use, change and redistribute it under the [GNU General Public License](LICENSE), version 3 or (at your option) any later version (GPL-3.0-or-later). If you distribute changed versions, you must offer their source code under the same license. The program comes with **no warranty**; see [LICENSE](LICENSE) for details.

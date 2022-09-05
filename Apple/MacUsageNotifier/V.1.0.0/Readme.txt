Hello,

This is the script just for showing macOS notification with basic macOS stats in choosen time interval (default set to 60s).
Shown information:
- uptime,
- CPU usage,
- RAM used,
- RAM Free,
- Swap usage.

You can see the does the notification looks in image.png file.

Installation:
1. Download MacUserNotifier.zip to Downloads folder,
2. Extract,
3. Run Install.command,

Uninstallation:
1. Open Finder and go to /Users/Shared/Scripts/Kurpios,
2. Run Uninstall.command

Change interval of notification:
1. Open terminal,
2. Type:
  open ~/Library/LaunchAgents/com.kurpios.MacUsageNotifier.Schedule.plist
  some textedit app should open.
3. Change the value of StartInterval (in seconds) and save file,
4. Open Finder and go to /Users/Shared/Scripts/Kurpios,
5. Run ReloadSettings.command


Since 04 Sept 2022 This tool is free for personal use. For commercial use please contact kontakt@kurpios.it.

After installation please fill the survery :)
https://forms.office.com/r/84PH80r5TU

If you really like my script you can donate to me here:
https://www.paypal.com/donate/?hosted_button_id=Z8USXRAD2QQ3C
:)

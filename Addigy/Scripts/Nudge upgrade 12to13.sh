#!/bin/sh

#Deploy Nudge config (remove old policy if exists)

POLICYPATH="/Library/Preferences/com.github.macadmins.Nudge.json"

if [ -f "$POLICYPATH" ]; then
    echo "Removing old config"
rm $POLICYPATH
fi

cat > "$POLICYPATH" <<EOF
{
    "optionalFeatures": {
      "acceptableApplicationBundleIDs": [],
      "acceptableAssertionUsage": false,
      "acceptableCameraUsage": true,
      "acceptableScreenSharingUsage": false,
      "aggressiveUserExperience": true,
      "aggressiveUserFullScreenExperience": true,
      "asynchronousSoftwareUpdate": true,
      "attemptToBlockApplicationLaunches": false,
      "attemptToFetchMajorUpgrade": true,
      "blockedApplicationBundleIDs": [],
      "enforceMinorUpdates": true,
      "terminateApplicationsOnLaunch": false
    },
    "osVersionRequirements": [
      {
        "aboutUpdateURL_disabled": "https://support.apple.com/en-us/HT213532#macos131",
        "aboutUpdateURLs": [
          {
            "_language": "en",
            "aboutUpdateURL": "https://support.apple.com/en-us/HT213532#macos131"
          },
          {
            "_language": "es",
            "aboutUpdateURL": "https://support.apple.com/es-es/HT213532"
          },
          {
            "_language": "fr",
            "aboutUpdateURL": "https://support.apple.com/fr-fr/HT213532"
          },
          {
            "_language": "de",
            "aboutUpdateURL": "https://support.apple.com/de-de/HT213532"
          }
        ],
        "requiredInstallationDate": "2023-01-19T00:00:00Z",
        "requiredMinimumOSVersion": "13",
        "targetedOSVersionsRule": "12"
      }
    ],
    "userExperience": {
      "allowGracePeriods": true,
      "allowLaterDeferralButton": true,
      "allowUserQuitDeferrals": true,
      "allowedDeferrals": 5,
      "allowedDeferralsUntilForcedSecondaryQuitButton": 3,
      "approachingRefreshCycle": 3600,
      "approachingWindowTime": 72,
      "elapsedRefreshCycle": 1800,
      "nudgeRefreshCycle": 60,
      "gracePeriodInstallDelay": 24,
      "gracePeriodLaunchDelay": 4,
      "randomDelay": false
    },
    "userInterface": {
      "actionButtonPath":"open https://{tenant}.sharepoint.com/sites/IT/SitePages/How-to-upgrade-your-Macbook-to-m.aspx",
      "fallbackLanguage": "en",
      "forceFallbackLanguage": false,
      "forceScreenShotIcon": false,
      "iconDarkPath": "/Library/Preferences/tenant_Logo.png",
      "iconLightPath": "/Library/Preferences/tenant_Logo.png",
      "showDeferralCount": true,
      "simpleMode": false,
      "singleQuitButton": false,
      "updateElements": [
        {
          "_language": "en",
          "actionButtonText": "Update Device",
          "customDeferralButtonText": "Custom",
          "customDeferralDropdownText": "Defer",
          "informationButtonText": "More Info",
          "mainContentHeader": "Your device will restart during this update",
          "mainContentNote": "Important Notes",
          "mainContentSubHeader": "Updates can take around 30 minutes to complete",
          "mainContentText": "A fully up-to-date device is required to ensure that IT can accurately protect your device.\n\nIf you do not update your device, you may lose access to some items necessary for your day-to-day tasks.\n\nTo begin the update, simply click on the Update Device button and follow the provided steps.",
          "mainHeader": "Your device requires a security update",
          "oneDayDeferralButtonText": "One Day",
          "oneHourDeferralButtonText": "One Hour",
          "primaryQuitButtonText": "Later",
          "secondaryQuitButtonText": "I understand",
          "subHeader": "A friendly reminder from your local IT team"
        },
        {
          "_language": "es",
          "actionButtonText": "Actualizar dispositivo",
          "informationButtonText": "Más información",
          "mainContentHeader": "Su dispositivo se reiniciará durante esta actualización",
          "mainContentNote": "Notas importantes",
          "mainContentSubHeader": "Las actualizaciones pueden tardar unos 30 minutos en completarse",
          "mainContentText": "Se requiere un dispositivo completamente actualizado para garantizar que IT pueda proteger su dispositivo con precisión.\n\nSi no actualiza su dispositivo, es posible que pierda el acceso a algunos elementos necesarios para sus tareas diarias.\n\nPara comenzar la actualización, simplemente haga clic en el botón Actualizar dispositivo y siga los pasos proporcionados.",
          "mainHeader": "Tu dispositivo requiere una actualización de seguridad",
          "primaryQuitButtonText": "Más tarde",
          "secondaryQuitButtonText": "Entiendo",
          "subHeader": "Un recordatorio amistoso de su equipo de IT local"
        },
        {
          "_language": "fr",
          "actionButtonText": "Mettre à jour l'appareil",
          "informationButtonText": "Plus d'informations",
          "mainContentHeader": "Votre appareil redémarrera pendant cette mise à jour",
          "mainContentNote": "Notes Importantes",
          "mainContentSubHeader": "Les mises à jour peuvent prendre environ 30 minutes.",
          "mainContentText": "Un appareil entièrement à jour est nécessaire pour garantir que le service informatique puisse protéger votre appareil efficacement.\n\n Si vous ne mettez pas à jour votre appareil, vous risquez de perdre l'accès à certains outils nécessaires à vos tâches quotidiennes.\n\nPour commencer la mise à jour, cliquez simplement sur le bouton Mettre à jour le périphérique et suivez les étapes fournies.",
          "mainHeader": "Votre appareil nécessite une mise à jour de sécurité.",
          "primaryQuitButtonText": "Plus tard",
          "secondaryQuitButtonText": "Je comprends",
          "subHeader": "Un rappel amical de votre équipe informatique locale"
        },
        {
          "_language": "de",
          "actionButtonText": "Gerät aktualisieren",
          "informationButtonText": "Mehr Informationen",
          "mainContentHeader": "Ihr Gerät wird während dieses Updates neu gestartet",
          "mainContentNote": "Wichtige Hinweise",
          "mainContentSubHeader": "Aktualisierungen können ca. 30 Minuten dauern.",
          "mainContentText": "Ein vollständig aktualisiertes Gerät ist erforderlich, um sicherzustellen, dass die IT-Abteilung Ihr Gerät effektiv schützen kann.\n\nWenn Sie Ihr Gerät nicht aktualisieren, verlieren Sie möglicherweise den Zugriff auf einige Werkzeuge, die Sie für Ihre täglichen Aufgaben benötigen.\n\nUm das Update zu starten, klicken Sie auf die Schaltfläche Gerät aktualisieren und befolgen Sie die angegebenen Schritte.",
          "mainHeader": "Ihr Gerät benötigt ein Sicherheitsupdate",
          "primaryQuitButtonText": "Später",
          "secondaryQuitButtonText": "Ich verstehe",
          "subHeader": "Eine freundliche Erinnerung von Ihrem IT-Team"
        }
      ]
    }
  } 
EOF


#Deploy Nudge LaunchAgent

POLICYPATH="/Library/LaunchAgents/com.github.macadmins.Nudge.plist"

if [ -f "$POLICYPATH" ]; then
    echo "Removing old LaunchAgent file"
rm $POLICYPATH
fi

cat > "$POLICYPATH" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AssociatedBundleIdentifiers</key>
	<array>
		<string>com.github.macadmins.Nudge</string>
	</array>
	<key>Label</key>
	<string>com.github.macadmins.Nudge</string>
	<key>LimitLoadToSessionType</key>
	<array>
		<string>Aqua</string>
	</array>
	<key>ProgramArguments</key>
	<array>
		<string>/Applications/Utilities/Nudge.app/Contents/MacOS/Nudge</string>
		<!-- <string>-json-url</string> -->
		<!-- <string>https://raw.githubusercontent.com/macadmins/nudge/main/Nudge/example.json</string> -->
		<!-- <string>-demo-mode</string> -->
	</array>
	<key>RunAtLoad</key>
	<true/>
	<key>StartCalendarInterval</key>
	<array>
		<dict>
			<key>hour</key>
			<integer>8</integer>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
		<dict>
			<key>hour</key>
			<integer>10</integer>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
		<dict>
			<key>hour</key>
			<integer>12</integer>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
		<dict>
			<key>hour</key>
			<integer>14</integer>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
		<dict>
			<key>hour</key>
			<integer>16</integer>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
		<dict>
			<key>hour</key>
			<integer>18</integer>
			<key>Minute</key>
			<integer>0</integer>
		</dict>
	</array>
</dict>
</plist> 
EOF

# Display the application version on the application settings
## Overview

On macOS, the default "About App" window displays the version of the application for you.

On other systems, a habit is to display the version on the application page in the Settings app.

## Guidelines

Initialise it in your  `AppDelegate`:
```swift
   @AppStorage("version") var version = Bundle.main.displayedVersion
```

Create a `Settings.bundle` file if your app doesn't have one yet and add this property list:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>StringsTable</key>
   <string>Version</string>
   <key>PreferenceSpecifiers</key>
   <array>
       <dict>
           <key>Type</key>
           <string>PSTitleValueSpecifier</string>
           <key>DefaultValue</key>
           <string></string>
           <key>Title</key>
           <string>Version</string>
           <key>Key</key>
           <string>version</string>
       </dict>
   </array>
</dict>
</plist>

```

That's all!

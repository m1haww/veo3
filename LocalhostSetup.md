# Localhost Setup for iOS

To allow your iOS app to connect to localhost during development, you need to add the following to your Info.plist:

## Add to Info.plist

1. Open your project in Xcode
2. Select the Info.plist file
3. Add a new key: `App Transport Security Settings` (NSAppTransportSecurity)
4. Under it, add: `Allow Arbitrary Loads` (NSAllowsArbitraryLoads) = YES

OR add this XML directly to Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>localhost</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

## For Production

Remember to:
1. Deploy your Flask backend to a server with HTTPS
2. Update `BackendService.swift` with your production URL
3. Remove the localhost exception from Info.plist
import Foundation

struct SystemAppFilter {
    // List of system processes that should be hidden from tracking
    static let systemProcesses: Set<String> = [
        "loginwindow",
        "WindowServer",
        "kernel_task",
        "launchd",
        "UserEventAgent",
        "cfprefsd",
        "distnoted",
        "mds",
        "mds_stores",
        "mdworker",
        "Spotlight",
        "coreservicesd",
        "lsd",
        "userinitd",
        "Dock",
        "SystemUIServer",
        "ControlCenter",
        "NotificationCenter",
        "Siri",
        "FaceTime",
        "PhotoBooth",
        "Calculator",
        "Stickies",
        "Grapher",
        "Audio MIDI Setup",
        "ColorSync Utility",
        "Digital Color Meter",
        "Keychain Access",
        "Activity Monitor",
        "Console",
        "System Information",
        "Disk Utility",
        "Network Utility",
        "Bluetooth File Exchange",
        "VoiceOver Utility",
        "AppleScript Editor",
        "Automator",
        "QuickTime Player",
        "Image Capture",
        "Preview",
        "TextEdit",
        "Dictionary",
        "Chess",
        "Mission Control",
        "Dashboard",
        "Time Machine",
        "Boot Camp Assistant",
        "Migration Assistant",
        "AirPort Utility",
        "Remote Desktop",
        "Screen Sharing",
        "FileMerge",
        "Icon Composer",
        "PackageMaker",
        "Property List Editor",
        "Xcode",
        "Instruments",
        "Dashcode",
        "Interface Builder"
    ]
    
    // List of system bundle identifiers
    static let systemBundleIds: Set<String> = [
        "com.apple.loginwindow",
        "com.apple.WindowManager",
        "com.apple.Dock",
        "com.apple.systemuiserver",
        "com.apple.controlcenter",
        "com.apple.notificationcenterui",
        "com.apple.Siri",
        "com.apple.FaceTime",
        "com.apple.PhotoBooth",
        "com.apple.calculator",
        "com.apple.Stickies",
        "com.apple.Grapher",
        "com.apple.AudioMIDISetup",
        "com.apple.ColorSyncUtility",
        "com.apple.DigitalColorMeter",
        "com.apple.keychainaccess",
        "com.apple.ActivityMonitor",
        "com.apple.Console",
        "com.apple.SystemInformation",
        "com.apple.DiskUtility",
        "com.apple.NetworkUtility",
        "com.apple.BluetoothFileExchange",
        "com.apple.VoiceOverUtility",
        "com.apple.AppScriptEditor",
        "com.apple.Automator",
        "com.apple.QuickTimePlayerX",
        "com.apple.ImageCapture",
        "com.apple.Preview",
        "com.apple.TextEdit",
        "com.apple.Dictionary",
        "com.apple.Chess",
        "com.apple.exposé",
        "com.apple.dashboard",
        "com.apple.TimeMachine",
        "com.apple.BootCampAssistant",
        "com.apple.MigrationAssistant",
        "com.apple.airport.airportutility",
        "com.apple.RemoteDesktop",
        "com.apple.ScreenSharing",
        "com.apple.FileMerge",
        "com.apple.IconComposer",
        "com.apple.PackageMaker",
        "com.apple.PropertyListEditor",
        "com.apple.dt.Xcode",
        "com.apple.dt.Instruments",
        "com.apple.Dashcode",
        "com.apple.InterfaceBuilder"
    ]
    
    static func shouldHide(_ bundleIdentifier: String) -> Bool {
        // Check if it's a system bundle ID
        if systemBundleIds.contains(bundleIdentifier) {
            return true
        }
        
        // Check if it starts with com.apple. (except user apps)
        if bundleIdentifier.hasPrefix("com.apple.") {
            // Allow some Apple apps that users commonly use
            let allowedAppleApps = [
                "com.apple.Safari",
                "com.apple.mail",
                "com.apple.iCal",
                "com.apple.AddressBook",
                "com.apple.iChat",
                "com.apple.Maps",
                "com.apple.Music",
                "com.apple.TV",
                "com.apple.Podcasts",
                "com.apple.Books",
                "com.apple.Notes",
                "com.apple.Reminders",
                "com.apple.VoiceMemos",
                "com.apple.Photos",
                "com.apple.camera",
                "com.apple.weather",
                "com.apple.stocks",
                "com.apple.home",
                "com.apple.news",
                "com.apple.freeform",
                "com.apple.findmy",
                "com.apple.shortcuts",
                "com.apple.VoiceMemos",
                "com.apple.compass",
                "com.apple.measure",
                "com.apple.calculator"
            ]
            
            if !allowedAppleApps.contains(bundleIdentifier) {
                return true
            }
        }
        
        return false
    }
    
    static func shouldHideProcess(_ processName: String) -> Bool {
        return systemProcesses.contains(processName)
    }
}

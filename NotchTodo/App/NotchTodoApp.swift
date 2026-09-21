import AppKit
import SwiftUI

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowManager: NotchWindowManager?
    
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        _ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Ensure app runs as an unobtrusive accessory without dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize Notch window manager
        windowManager = NotchWindowManager()
    }
}

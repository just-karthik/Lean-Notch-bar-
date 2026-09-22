import AppKit
import Foundation

struct NotchDimensions {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let hasHardwareNotch: Bool
    
    static func current(for screen: NSScreen = NSScreen.main ?? NSScreen.screens.first!) -> NotchDimensions {
        if let left = screen.auxiliaryTopLeftArea,
           let right = screen.auxiliaryTopRightArea,
           right.minX > left.maxX {
            let width = right.minX - left.maxX
            let height = screen.safeAreaInsets.top
            return NotchDimensions(notchWidth: width, notchHeight: height, hasHardwareNotch: true)
        }
        
        // Fallback for displays without physical notch (external monitors, older Macs)
        if screen.safeAreaInsets.top > 0 {
            return NotchDimensions(notchWidth: 180, notchHeight: screen.safeAreaInsets.top, hasHardwareNotch: true)
        }
        
        return NotchDimensions(notchWidth: 170, notchHeight: 30, hasHardwareNotch: false)
    }
}

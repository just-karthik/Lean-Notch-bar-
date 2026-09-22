import AppKit
import Foundation

@MainActor
struct NotchDimensions {
    let notchWidth: CGFloat
    let notchHeight: CGFloat
    let hasHardwareNotch: Bool
    
    static func current(for screen: NSScreen? = nil) -> NotchDimensions {
        let activeScreen = screen ?? NSScreen.main ?? NSScreen.screens.first
        guard let s = activeScreen else {
            return NotchDimensions(notchWidth: 180, notchHeight: 32, hasHardwareNotch: false)
        }
        
        if let left = s.auxiliaryTopLeftArea,
           let right = s.auxiliaryTopRightArea,
           right.minX > left.maxX {
            let width = right.minX - left.maxX
            let height = s.safeAreaInsets.top
            return NotchDimensions(notchWidth: width, notchHeight: height, hasHardwareNotch: true)
        }
        
        // Fallback for displays without physical notch (external monitors, older Macs)
        if s.safeAreaInsets.top > 0 {
            return NotchDimensions(notchWidth: 180, notchHeight: s.safeAreaInsets.top, hasHardwareNotch: true)
        }
        
        return NotchDimensions(notchWidth: 170, notchHeight: 30, hasHardwareNotch: false)
    }
}

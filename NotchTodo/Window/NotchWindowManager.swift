import AppKit
import SwiftUI
import Combine

@MainActor
final class NotchWindowManager: ObservableObject {
    @Published var isExpanded: Bool = false {
        didSet {
            updateWindowFrame(animated: true)
            if isExpanded {
                startOutsideClickMonitor()
                panel?.makeKey()
            } else {
                stopOutsideClickMonitor()
            }
        }
    }
    
    @Published var notchHeight: CGFloat = 32
    @Published var notchWidth: CGFloat = 180
    
    let store = TodoStore()
    private var panel: NotchPanel?
    private var globalClickMonitor: Any?
    private var localKeyMonitor: Any?
    
    init() {
        refreshDimensions()
        setupPanel()
        setupNotifications()
    }
    
    private func refreshDimensions() {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        let dims = NotchDimensions.current(for: screen)
        self.notchHeight = dims.notchHeight
        self.notchWidth = dims.notchWidth
    }
    
    private func setupPanel() {
        let panel = NotchPanel(contentRect: .zero)
        self.panel = panel
        
        let rootView = RootNotchContainerView(manager: self, store: store)
        let hostingView = NSHostingView(rootView: rootView)
        panel.contentView = hostingView
        
        updateWindowFrame(animated: false)
        panel.orderFrontRegardless()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshDimensions()
            self?.updateWindowFrame(animated: false)
        }
    }
    
    func toggle() {
        isExpanded.toggle()
    }
    
    func collapse() {
        if isExpanded {
            isExpanded = false
        }
    }
    
    func expand() {
        if !isExpanded {
            isExpanded = true
        }
    }
    
    func quit() {
        NSApp.terminate(nil)
    }
    
    private func updateWindowFrame(animated: Bool) {
        guard let panel = panel, let screen = NSScreen.main ?? NSScreen.screens.first else { return }
        
        let screenFrame = screen.frame
        
        // Exact notch sizes
        let targetWidth: CGFloat = isExpanded ? 500 : max(notchWidth + 20, 200)
        let targetHeight: CGFloat = isExpanded ? 350 : (notchHeight + 10)
        
        // Anchored flush to top center of screen
        let x = screenFrame.minX + (screenFrame.width - targetWidth) / 2
        let y = screenFrame.maxY - targetHeight
        
        let targetFrame = NSRect(x: x, y: y, width: targetWidth, height: targetHeight)
        
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.28
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                panel.animator().setFrame(targetFrame, display: true)
            }
        } else {
            panel.setFrame(targetFrame, display: true)
        }
    }
    
    private func startOutsideClickMonitor() {
        stopOutsideClickMonitor()
        
        // Monitor mouse clicks outside this panel
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                self?.collapse()
            }
        }
        
        // Monitor Escape key
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC key
                Task { @MainActor in
                    self?.collapse()
                }
                return nil
            }
            return event
        }
    }
    
    private func stopOutsideClickMonitor() {
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
            globalClickMonitor = nil
        }
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
    }
}

// Container view handling animated transitions between collapsed and expanded states
struct RootNotchContainerView: View {
    @ObservedObject var manager: NotchWindowManager
    @ObservedObject var store: TodoStore
    
    var body: some View {
        ZStack(alignment: .top) {
            if manager.isExpanded {
                ExpandedNotchView(
                    store: store,
                    notchHeight: manager.notchHeight,
                    onCollapse: {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            manager.collapse()
                        }
                    },
                    onQuit: {
                        manager.quit()
                    }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95, anchor: .top)),
                    removal: .opacity.combined(with: .scale(scale: 0.95, anchor: .top))
                ))
            } else {
                CollapsedNotchView(
                    store: store,
                    notchHeight: manager.notchHeight,
                    onExpand: {
                        withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                            manager.expand()
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

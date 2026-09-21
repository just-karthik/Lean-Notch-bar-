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
    
    let store = TodoStore()
    private var panel: NotchPanel?
    private var globalClickMonitor: Any?
    private var localKeyMonitor: Any?
    
    init() {
        setupPanel()
        setupNotifications()
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
        let notchHeight = screen.safeAreaInsets.top > 0 ? screen.safeAreaInsets.top : 32
        
        let width: CGFloat = isExpanded ? 380 : 200
        let height: CGFloat = isExpanded ? 360 : (notchHeight > 0 ? notchHeight + 4 : 36)
        let x = screenFrame.minX + (screenFrame.width - width) / 2
        let y = screenFrame.maxY - height
        
        let targetFrame = NSRect(x: x, y: y, width: width, height: height)
        
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.22
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                panel.animator().setFrame(targetFrame, display: true)
            }
        } else {
            panel.setFrame(targetFrame, display: true)
        }
    }
    
    private func startOutsideClickMonitor() {
        stopOutsideClickMonitor()
        
        // Monitor global clicks outside our app
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            Task { @MainActor in
                self?.collapse()
            }
        }
        
        // Monitor Escape key press locally
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

// Container view switching between collapsed and expanded modes
struct RootNotchContainerView: View {
    @ObservedObject var manager: NotchWindowManager
    @ObservedObject var store: TodoStore
    
    var body: some View {
        ZStack(alignment: .top) {
            if manager.isExpanded {
                ExpandedNotchView(
                    store: store,
                    onCollapse: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            manager.collapse()
                        }
                    },
                    onQuit: {
                        manager.quit()
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.95, anchor: .top).combined(with: .opacity),
                    removal: .scale(scale: 0.95, anchor: .top).combined(with: .opacity)
                ))
            } else {
                CollapsedNotchView(
                    store: store,
                    onExpand: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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

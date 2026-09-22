import SwiftUI

struct CollapsedNotchView: View {
    @ObservedObject var store: TodoStore
    let notchHeight: CGFloat
    let onExpand: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onExpand) {
            ZStack(alignment: .bottom) {
                // True Notch Shape background
                NotchShape(topCornerRadius: 6, bottomCornerRadius: 14)
                    .fill(Color.black)
                    .overlay(
                        NotchShape(topCornerRadius: 6, bottomCornerRadius: 14)
                            .stroke(Color.white.opacity(isHovering ? 0.3 : 0.12), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
                
                // Content positioned along the notch chin
                HStack(spacing: 8) {
                    Image(systemName: store.pendingCount == 0 ? "checkmark.circle.fill" : "checklist")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(store.pendingCount == 0 ? .green : .blue)
                    
                    if store.pendingCount == 0 {
                        Text("All done")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    } else {
                        Text("\(store.pendingCount) \(store.pendingCount == 1 ? "task" : "tasks")")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if let next = store.nextReminder, let due = next.formattedDueDate {
                        HStack(spacing: 3) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.orange)
                            Text(due)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.white.opacity(0.12)))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

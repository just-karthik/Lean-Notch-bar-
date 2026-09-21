import SwiftUI

struct CollapsedNotchView: View {
    @ObservedObject var store: TodoStore
    let onExpand: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: onExpand) {
            HStack(spacing: 8) {
                // Left status icon
                Image(systemName: store.pendingCount == 0 ? "checkmark.circle.fill" : "checklist")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(store.pendingCount == 0 ? .green : .blue)
                
                // Active count label
                if store.pendingCount == 0 {
                    Text("All done")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                } else {
                    Text("\(store.pendingCount) \(store.pendingCount == 1 ? "task" : "tasks")")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Next upcoming reminder if one exists
                if let next = store.nextReminder, let due = next.formattedDueDate {
                    HStack(spacing: 3) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.orange)
                        Text(due)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color.white.opacity(0.12)))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.black)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(isHovering ? 0.25 : 0.1), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovering = hovering
            }
        }
    }
}

import SwiftUI

struct ExpandedNotchView: View {
    @ObservedObject var store: TodoStore
    let notchHeight: CGFloat
    let onCollapse: () -> Void
    let onQuit: () -> Void
    
    @State private var newTaskTitle: String = ""
    @State private var showDatePicker: Bool = false
    @State private var reminderDate: Date = Date().addingTimeInterval(3600)
    @State private var filter: TaskFilter = .all
    @FocusState private var isInputFocused: Bool
    
    var filteredItems: [TodoItem] {
        switch filter {
        case .all:
            return store.items
        case .pending:
            return store.pendingItems
        case .completed:
            return store.completedItems
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // True Notch Shape background
            NotchShape(topCornerRadius: 14, bottomCornerRadius: 24)
                .fill(Color.black)
                .overlay(
                    NotchShape(topCornerRadius: 14, bottomCornerRadius: 24)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.7), radius: 18, x: 0, y: 10)
            
            // Content padded safely below the hardware camera notch
            VStack(spacing: 12) {
                // Top Header (placed right below the camera)
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "checklist")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.blue)
                        Text("Notch Tasks")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("(\(store.pendingCount))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    Button(action: onCollapse) {
                        Image(systemName: "chevron.up.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .buttonStyle(.plain)
                    .help("Collapse (Esc)")
                }
                .padding(.horizontal, 24)
                .padding(.top, notchHeight + 6)
                
                // Input Bar
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.5))
                        
                        TextField("Add a task... (Press Return)", text: $newTaskTitle)
                            .textFieldStyle(.plain)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .focused($isInputFocused)
                            .onSubmit {
                                submitNewTask()
                            }
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showDatePicker.toggle()
                            }
                        }) {
                            Image(systemName: showDatePicker ? "bell.fill" : "bell")
                                .font(.system(size: 13))
                                .foregroundColor(showDatePicker ? .orange : .white.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .help("Set reminder")
                        
                        if !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Button(action: submitNewTask) {
                                Text("Add")
                                    .font(.system(size: 11, weight: .semibold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Capsule().fill(Color.blue))
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.08))
                    )
                    
                    // Reminder Date Picker
                    if showDatePicker {
                        HStack(spacing: 8) {
                            Text("Reminder:")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                            
                            DatePicker("", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .colorInvert()
                                .colorMultiply(.white)
                            
                            Spacer()
                            
                            Button("Clear") {
                                withAnimation {
                                    showDatePicker = false
                                }
                            }
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.05)))
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(.horizontal, 22)
                
                // Tasks List
                ScrollView {
                    LazyVStack(spacing: 2) {
                        if filteredItems.isEmpty {
                            VStack(spacing: 6) {
                                Image(systemName: "tray")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white.opacity(0.3))
                                    .padding(.top, 14)
                                Text(emptyStateText)
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        } else {
                            ForEach(filteredItems) { item in
                                TaskRowView(
                                    item: item,
                                    onToggle: {
                                        store.toggleCompleted(id: item.id)
                                    },
                                    onDelete: {
                                        store.deleteItem(id: item.id)
                                    }
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                }
                
                Divider()
                    .background(Color.white.opacity(0.12))
                
                // Footer
                HStack {
                    Picker("", selection: $filter) {
                        ForEach(TaskFilter.allCases, id: \.self) { f in
                            Text(f.rawValue).tag(f)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 170)
                    
                    Spacer()
                    
                    if !store.completedItems.isEmpty {
                        Button("Clear Done") {
                            store.clearCompleted()
                        }
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                        .buttonStyle(.plain)
                    }
                    
                    Button(action: onQuit) {
                        Image(systemName: "power")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                    .help("Quit Notch To-Do")
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 14)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isInputFocused = true
            NotificationManager.shared.requestAuthorization()
        }
    }
    
    private var emptyStateText: String {
        switch filter {
        case .all: return "No tasks yet. Add one above!"
        case .pending: return "All tasks completed! 🎉"
        case .completed: return "No completed tasks yet."
        }
    }
    
    private func submitNewTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let due: Date? = showDatePicker ? reminderDate : nil
        store.addItem(title: trimmed, dueDate: due)
        
        newTaskTitle = ""
        showDatePicker = false
        reminderDate = Date().addingTimeInterval(3600)
    }
}

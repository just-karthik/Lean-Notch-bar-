import Foundation
import Combine

@MainActor
final class TodoStore: ObservableObject {
    @Published var items: [TodoItem] = [] {
        didSet {
            save()
        }
    }
    
    private let fileURL: URL
    
    init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appFolder = appSupport.appendingPathComponent("NotchTodo", isDirectory: true)
        
        if !fileManager.fileExists(atPath: appFolder.path) {
            try? fileManager.createDirectory(at: appFolder, withIntermediateDirectories: true)
        }
        
        self.fileURL = appFolder.appendingPathComponent("tasks.json")
        load()
    }
    
    var pendingItems: [TodoItem] {
        items.filter { !$0.isCompleted }
    }
    
    var completedItems: [TodoItem] {
        items.filter { $0.isCompleted }
    }
    
    var pendingCount: Int {
        pendingItems.count
    }
    
    var nextReminder: TodoItem? {
        pendingItems
            .filter { $0.dueDate != nil && $0.dueDate! > Date() }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            .first
    }
    
    func addItem(title: String, dueDate: Date? = nil) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        let newItem = TodoItem(title: trimmed, dueDate: dueDate)
        items.insert(newItem, at: 0)
        
        if dueDate != nil {
            NotificationManager.shared.scheduleNotification(for: newItem)
        }
    }
    
    func toggleCompleted(id: UUID) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].isCompleted.toggle()
        
        if items[index].isCompleted {
            NotificationManager.shared.cancelNotification(for: id)
        } else if let _ = items[index].dueDate {
            NotificationManager.shared.scheduleNotification(for: items[index])
        }
    }
    
    func deleteItem(id: UUID) {
        NotificationManager.shared.cancelNotification(for: id)
        items.removeAll { $0.id == id }
    }
    
    func clearCompleted() {
        for item in completedItems {
            NotificationManager.shared.cancelNotification(for: item.id)
        }
        items.removeAll { $0.isCompleted }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save tasks: \(error.localizedDescription)")
        }
    }
    
    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            // Seed a helpful sample welcome task on very first run
            items = [
                TodoItem(title: "Click the notch to view tasks 👋", isCompleted: false)
            ]
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            items = try JSONDecoder().decode([TodoItem].self, from: data)
        } catch {
            print("Failed to load tasks: \(error.localizedDescription)")
            items = []
        }
    }
}

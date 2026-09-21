import Foundation

struct TodoItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var title: String
    var isCompleted: Bool = false
    var dueDate: Date? = nil
    var createdAt: Date = Date()
    
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }
    
    var formattedDueDate: String? {
        guard let dueDate = dueDate else { return nil }
        let calendar = Calendar.current
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        let timeStr = timeFormatter.string(from: dueDate)
        
        if calendar.isDateInToday(dueDate) {
            return "Today \(timeStr)"
        } else if calendar.isDateInTomorrow(dueDate) {
            return "Tomorrow \(timeStr)"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, h:mm a"
            return dateFormatter.string(from: dueDate)
        }
    }
}

import Foundation

struct Meeting: Identifiable, Codable {
    let id: Int
    let name: String
    let weekday: Int
    let startTime: String
    let locationName: String
    let street: String
    let city: String
    let zip: String
    let virtualLink: String?
    let formats: [String]
    let serviceBodyId: Int

    var isWheelchairAccessible: Bool {
        formats.contains(where: { ["WC","WCAB","HC"].contains($0) })
    }

    var weekdayName: String {
        let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        guard weekday >= 1 && weekday <= 7 else { return "?" }
        return days[weekday - 1]
    }

    var formattedTime: String {
        let parts = startTime.split(separator: ":").map { String($0) }
        guard parts.count >= 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]) else { return startTime }
        let period = hour >= 12 ? "PM" : "AM"
        let h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", h, minute, period)
    }
}

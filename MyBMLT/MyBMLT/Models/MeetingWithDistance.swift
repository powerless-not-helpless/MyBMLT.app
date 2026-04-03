import Foundation

struct MeetingWithDistance: Identifiable {
    let meeting: Meeting
    let minutesUntil: Int      // negative = in-progress (within 10-min grace window)
    let distanceMiles: Double? // nil for virtual-only meetings

    var id: Int { meeting.id }

    var timeLabel: String {
        if minutesUntil <= 0 { return "In progress" }
        if minutesUntil < 60 { return "in \(minutesUntil) min" }
        let h = minutesUntil / 60, m = minutesUntil % 60
        return m == 0 ? "in \(h) hr" : "in \(h) hr \(m) min"
    }

    var distanceLabel: String? {
        guard let d = distanceMiles else { return nil }
        return String(format: "%.1f mi", d)
    }
}

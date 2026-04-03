import Foundation
import Combine

class NewMeetingsService: ObservableObject {

    private let key = "seenMeetingIDs"

    /// IDs that have been explicitly marked as seen by the user.
    private var seenIDs: Set<Int> {
        get {
            let stored = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
            return Set(stored)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: key)
        }
    }

    /// Returns meetings whose IDs have never been seen before.
    func newMeetings(from meetings: [Meeting]) -> [Meeting] {
        let seen = seenIDs
        return meetings.filter { !seen.contains($0.id) }
            .sorted {
                if $0.weekday != $1.weekday { return $0.weekday < $1.weekday }
                return $0.startTime < $1.startTime
            }
    }

    /// Call when user taps "Mark All Seen". Adds all current IDs to the seen set.
    func markAllSeen(_ meetings: [Meeting]) {
        var seen = seenIDs
        meetings.forEach { seen.insert($0.id) }
        seenIDs = seen
        objectWillChange.send()
    }

    /// Seed on first launch so existing meetings don't appear as "new".
    private func seedAll(_ meetings: [Meeting]) {
        var seen = seenIDs
        meetings.forEach { seen.insert($0.id) }
        seenIDs = seen
    }
}

import Foundation
import Combine

class VisitListService: ObservableObject {

    @Published var targetIDs: Set<Int> = []

    private var cacheURL: URL {
        let support = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MyBMLT", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: support, withIntermediateDirectories: true)
        return support.appendingPathComponent("visitlist_cache.json")
    }

    init() { load() }

    func isTarget(_ meeting: Meeting) -> Bool {
        targetIDs.contains(meeting.id)
    }

    func toggle(_ meeting: Meeting) {
        if targetIDs.contains(meeting.id) {
            targetIDs.remove(meeting.id)
        } else {
            targetIDs.insert(meeting.id)
        }
        save()
    }

    func copyText(from meetings: [Meeting]) -> String {
        let targets = meetings
            .filter { targetIDs.contains($0.id) }
            .sorted {
                if $0.weekday != $1.weekday { return $0.weekday < $1.weekday }
                return $0.startTime < $1.startTime
            }

        var lines: [String] = []
        var lastDay = -1
        for m in targets {
            if m.weekday != lastDay {
                if !lines.isEmpty { lines.append("") }
                lines.append(m.weekdayName.uppercased())
                lastDay = m.weekday
            }
            var parts = ["\(m.name) — \(m.formattedTime)"]
            let addr = [m.locationName, m.street, m.city, m.zip]
                .filter { !$0.isEmpty }.joined(separator: ", ")
            if !addr.isEmpty { parts.append(addr) }
            if !m.formats.isEmpty { parts.append("Formats: \(m.formats.joined(separator: ", "))") }
            lines.append("  " + parts.joined(separator: " | "))
        }
        return lines.joined(separator: "\n")
    }

    private func save() {
        if let data = try? JSONEncoder().encode(Array(targetIDs)) {
            try? data.write(to: cacheURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: cacheURL),
              let ids = try? JSONDecoder().decode([Int].self, from: data)
        else { return }
        targetIDs = Set(ids)
    }
}

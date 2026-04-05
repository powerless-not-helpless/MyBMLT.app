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

        var blocks: [String] = []
        for m in targets {
            var entry: [String] = []
            entry.append("\(m.weekdayName) at \(m.formattedTime)")
            entry.append(m.name)
            let addr = [m.locationName, m.street, m.city, m.zip]
                .filter { !$0.isEmpty }.joined(separator: ", ")
            if !addr.isEmpty { entry.append(addr) }
            if let link = m.virtualLink, !link.isEmpty {
                entry.append(link.replacingOccurrences(of: " ", with: ""))
            }
            if let password = m.passwordValue { entry.append("Password: \(password)") }
            if !m.formats.isEmpty { entry.append("Formats: \(m.formats.joined(separator: ", "))") }
            blocks.append(entry.joined(separator: "\n"))
        }
        return blocks.joined(separator: "\n\n")
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

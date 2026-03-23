import Foundation
import Combine

class SearchHistoryService: ObservableObject {

    @Published var history: [String] = []
    private let maxItems = 10

    private var cacheURL: URL {
        let support = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MyBMLT", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: support, withIntermediateDirectories: true)
        return support.appendingPathComponent("search_history.json")
    }

    init() {
        load()
    }

    func add(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        history.removeAll { $0.lowercased() == trimmed.lowercased() }
        history.insert(trimmed, at: 0)
        if history.count > maxItems {
            history = Array(history.prefix(maxItems))
        }
        save()
    }

    func clear() {
        history = []
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: cacheURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: cacheURL),
              let items = try? JSONDecoder().decode([String].self, from: data)
        else { return }
        history = items
    }
}


import Foundation
import Combine

class FavoritesService: ObservableObject {

    @Published var favoriteIDs: Set<Int> = []

    private var cacheURL: URL {
        let support = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MyBMLT", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: support, withIntermediateDirectories: true)
        return support.appendingPathComponent("favorites_cache.json")
    }

    init() {
        load()
    }

    func isFavorite(_ meeting: Meeting) -> Bool {
        favoriteIDs.contains(meeting.id)
    }

    func toggle(_ meeting: Meeting) {
        if favoriteIDs.contains(meeting.id) {
            favoriteIDs.remove(meeting.id)
        } else {
            favoriteIDs.insert(meeting.id)
        }
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(Array(favoriteIDs)) {
            try? data.write(to: cacheURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: cacheURL),
              let ids = try? JSONDecoder().decode([Int].self, from: data)
        else { return }
        favoriteIDs = Set(ids)
    }
}

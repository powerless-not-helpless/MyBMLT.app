import Foundation
import Combine

class BMLTService: ObservableObject {

    static let rootServer  = "https://bmlt.wszf.org/main_server"
    static let serviceBody = 1155

    @Published var meetings: [Meeting] = []
    @Published var isLoading = false
    @Published var error: String?
    @Published var lastUpdated: Date?

    private var cacheURL: URL {
        let support = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MyBMLT", isDirectory: true)
        try? FileManager.default.createDirectory(
            at: support, withIntermediateDirectories: true)
        return support.appendingPathComponent("meetings_cache.json")
    }

    func loadMeetings() async {
        if let cached = loadFromCache() {
            await MainActor.run {
                self.meetings = cached.meetings
                self.lastUpdated = cached.date
            }
        }
        await fetchFromNetwork()
    }

    func refresh() async {
        await fetchFromNetwork()
    }

    private func fetchFromNetwork() async {
        let urlString = Self.rootServer + "/client_interface/json/"
            + "?switcher=GetSearchResults"
            + "&get_used_formats=1"
            + "&lang_enum=en"
            + "&services[]=" + String(Self.serviceBody)
            + "&recursive=1"

        guard let url = URL(string: urlString) else { return }

        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(BMLTResponse.self, from: data)
            let mapped = response.meetings.compactMap { $0.toMeeting() }
            saveToCache(mapped)
            await MainActor.run {
                self.meetings = mapped
                self.lastUpdated = Date()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    private struct CachePayload: Codable {
        let date: Date
        let meetings: [Meeting]
    }

    private func saveToCache(_ meetings: [Meeting]) {
        let payload = CachePayload(date: Date(), meetings: meetings)
        if let data = try? JSONEncoder().encode(payload) {
            try? data.write(to: cacheURL)
        }
    }

    private func loadFromCache() -> CachePayload? {
        guard let data = try? Data(contentsOf: cacheURL) else { return nil }
        return try? JSONDecoder().decode(CachePayload.self, from: data)
    }
}

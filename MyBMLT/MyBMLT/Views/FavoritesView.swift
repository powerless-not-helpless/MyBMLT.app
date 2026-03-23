import SwiftUI
import MapKit

struct FavoritesView: View {
    @EnvironmentObject var favoritesService: FavoritesService
    let meetings: [Meeting]
    @State private var selectedMeeting: Meeting? = nil

    var favoriteMeetings: [Meeting] {
        meetings
            .filter { favoritesService.isFavorite($0) }
            .sorted {
                if $0.weekday != $1.weekday { return $0.weekday < $1.weekday }
                return $0.startTime < $1.startTime
            }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                if favoriteMeetings.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "star")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No Favorites Yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Tap the star on any meeting to add it here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(favoriteMeetings, selection: $selectedMeeting) { meeting in
                        MeetingRow(meeting: meeting)
                            .tag(meeting)
                    }
                    .listStyle(.plain)
                }

                HStack {
                    Text("\(favoriteMeetings.count) Favorites")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(.bar)
            }
            .navigationTitle("Favorites")

        } detail: {
            if let meeting = selectedMeeting {
                MeetingDetailView(meeting: meeting)
            } else {
                Text("Select a meeting")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

import SwiftUI

struct NewMeetingsView: View {
    @EnvironmentObject var newMeetingsService: NewMeetingsService
    let meetings: [Meeting]
    @State private var selectedMeeting: Meeting? = nil

    var newMeetings: [Meeting] {
        newMeetingsService.newMeetings(from: meetings)
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                if newMeetings.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No New Meetings")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("New meetings added to the regional server will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(newMeetings, selection: $selectedMeeting) { meeting in
                        MeetingRow(meeting: meeting)
                            .tag(meeting)
                    }
                    .listStyle(.plain)
                }

                HStack {
                    Text(newMeetings.isEmpty ? "Up to date" : "\(newMeetings.count) new meeting\(newMeetings.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !newMeetings.isEmpty {
                        Button("Mark All Seen") {
                            newMeetingsService.markAllSeen(meetings)
                            selectedMeeting = nil
                        }
                        .font(.caption)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(.bar)
            }
            .navigationTitle("New Meetings")

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

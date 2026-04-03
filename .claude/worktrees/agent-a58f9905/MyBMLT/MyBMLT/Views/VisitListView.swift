import SwiftUI

struct VisitListView: View {
    @EnvironmentObject var visitListService: VisitListService
    let meetings: [Meeting]
    @State private var selectedMeeting: Meeting? = nil
    @State private var copied = false

    var targets: [Meeting] {
        meetings
            .filter { visitListService.isTarget($0) }
            .sorted {
                if $0.weekday != $1.weekday { return $0.weekday < $1.weekday }
                return $0.startTime < $1.startTime
            }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                if targets.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No Visit Targets")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("Tap the pin icon on any meeting to add it to your visit list.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(targets, selection: $selectedMeeting) { meeting in
                        HStack {
                            MeetingRow(meeting: meeting)
                            Spacer()
                            Button {
                                visitListService.toggle(meeting)
                            } label: {
                                Image(systemName: "mappin.slash")
                                    .foregroundStyle(.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                        .tag(meeting)
                    }
                    .listStyle(.plain)
                }

                HStack {
                    Text("\(targets.count) target\(targets.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !targets.isEmpty {
                        Button {
                            let text = visitListService.copyText(from: meetings)
                            #if os(macOS)
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(text, forType: .string)
                            #else
                            UIPasteboard.general.string = text
                            #endif
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                        } label: {
                            Label(copied ? "Copied!" : "Copy All", systemImage: copied ? "checkmark" : "doc.on.doc")
                        }
                        .font(.caption)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(.bar)
            }
            .navigationTitle("Visit List")

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

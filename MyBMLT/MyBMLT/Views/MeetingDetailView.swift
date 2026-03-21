import SwiftUI
import MapKit

struct MeetingDetailView: View {
    let meeting: Meeting
    @State private var copied = false

    var clipboardText: String {
        var lines: [String] = []
        lines.append(meeting.weekdayName)
        lines.append("\(meeting.name) at \(meeting.formattedTime)")

        if meeting.venueType != 2 {
            let addressParts = [meeting.street, meeting.city, meeting.zip]
                .filter { !$0.isEmpty }
            if !addressParts.isEmpty {
                lines.append(addressParts.joined(separator: ", "))
            }
        }

        if meeting.venueType == 2 || meeting.venueType == 3 {
            if let link = meeting.virtualLink, !link.isEmpty {
                let cleanedLink = (link.components(separatedBy: "?pwd=").first ?? link)
                    .replacingOccurrences(of: " ", with: "")
                lines.append(cleanedLink)
            }
        }

        if !meeting.formats.isEmpty {
            lines.append("Formats: \(meeting.formats.joined(separator: ", "))")
        }

        return lines.joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Name + time + copy button
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(meeting.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("\(meeting.weekdayName) \(meeting.formattedTime) · \(meeting.formattedDuration)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(clipboardText, forType: .string)
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    } label: {
                        Label(copied ? "Copied!" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                }

                Divider()

                // Venue + Area
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(meeting.venueLabel)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(venueBadgeColor(meeting.venueType).opacity(0.2))
                            .foregroundStyle(venueBadgeColor(meeting.venueType))
                            .clipShape(Capsule())
                        if meeting.isWheelchairAccessible {
                            Label("Wheelchair Accessible", systemImage: "figure.roll")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    Text(meeting.areaName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                // Location (in-person / hybrid)
                if meeting.venueType != 2 {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Location", systemImage: "mappin.circle")
                            .font(.headline)

                        if !meeting.locationName.isEmpty {
                            Text(meeting.locationName)
                                .font(.subheadline)
                        }

                        let addressParts = [meeting.street, meeting.city, meeting.zip]
                            .filter { !$0.isEmpty }
                        if !addressParts.isEmpty {
                            Text(addressParts.joined(separator: ", "))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if let lat = meeting.latitude, let lon = meeting.longitude {
                            Button {
                                openInMaps(lat: lat, lon: lon, name: meeting.name)
                            } label: {
                                Label("Open in Maps", systemImage: "map")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                            .padding(.top, 2)
                        }
                    }
                    Divider()
                }

                // Virtual link (virtual / hybrid)
                if meeting.venueType == 2 || meeting.venueType == 3 {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Online Meeting", systemImage: "video.circle")
                            .font(.headline)

                        if let link = meeting.virtualLink, !link.isEmpty {
                            Button {
                                openZoom(link: link)
                            } label: {
                                Label("Join Meeting", systemImage: "video.fill")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.borderedProminent)

                            Text(
                                (link.components(separatedBy: "?pwd=").first ?? link)
                                    .replacingOccurrences(of: " ", with: "")
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                        }

                        if let info = meeting.virtualInfo,
                           !info.isEmpty,
                           !info.lowercased().contains("no password") {
                            HStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                Text(info)
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                    Divider()
                }

                // Formats
                if !meeting.formats.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Meeting Formats", systemImage: "list.bullet")
                            .font(.headline)
                        FlowLayout(meeting.formats)
                    }
                    Divider()
                }
            }
            .padding()
        }
        .navigationTitle(meeting.name)
    }

    private func venueBadgeColor(_ type: Int) -> Color {
        switch type {
        case 1: return .green
        case 2: return .blue
        case 3: return .orange
        default: return .secondary
        }
    }

    private func openInMaps(lat: Double, lon: Double, name: String) {
        let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "maps://?q=\(encoded)&ll=\(lat),\(lon)"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    private func openZoom(link: String) {
        let cleaned = link.replacingOccurrences(of: " ", with: "")
        guard let webURL = URL(string: cleaned) else { return }

        let path = webURL.path
        let meetingId = path.components(separatedBy: "/").last ?? ""
        let queryItems = URLComponents(url: webURL, resolvingAgainstBaseURL: false)?
            .queryItems ?? []
        let pwd = queryItems.first(where: { $0.name == "pwd" })?.value

        var zoomString = "zoommtg://zoom.us/join?confno=\(meetingId)"
        if let pwd = pwd {
            zoomString += "&pwd=\(pwd)"
        }

        if let zoomURL = URL(string: zoomString),
           NSWorkspace.shared.open(zoomURL) {
        } else {
            NSWorkspace.shared.open(webURL)
        }
    }
}

struct FlowLayout: View {
    let items: [String]

    init(_ items: [String]) {
        self.items = items
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], alignment: .leading) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}

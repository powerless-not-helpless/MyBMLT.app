import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var service = BMLTService()
    @State private var searchText = ""
    @State private var selectedDay: Int? = nil
    @State private var selectedArea: Int = -1
    @State private var selectedVenue: Int = -1

    var filteredMeetings: [Meeting] {
        service.meetings.filter { meeting in
            let matchesDay    = selectedDay   == nil || meeting.weekday        == selectedDay
            let matchesArea   = selectedArea  == -1  || meeting.serviceBodyId  == selectedArea
            let matchesVenue  = selectedVenue == -1  || meeting.venueType      == selectedVenue
            let matchesSearch = searchText.isEmpty ||
                meeting.name.localizedCaseInsensitiveContains(searchText) ||
                meeting.city.localizedCaseInsensitiveContains(searchText) ||
                meeting.street.localizedCaseInsensitiveContains(searchText) ||
                meeting.zip.localizedCaseInsensitiveContains(searchText)
            return matchesDay && matchesArea && matchesVenue && matchesSearch
        }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {

                // Area + Venue filter dropdowns
                HStack {
                    Picker("Area", selection: $selectedArea) {
                        Text("All Areas").tag(-1)
                        ForEach(ServiceArea.all) { area in
                            Text(area.shortName).tag(area.id)
                        }
                    }
                    .pickerStyle(.menu)

                    Spacer()

                    Picker("Venue", selection: $selectedVenue) {
                        Text("All").tag(-1)
                        Text("In-Person").tag(1)
                        Text("Virtual").tag(2)
                        Text("Hybrid").tag(3)
                    }
                    .pickerStyle(.menu)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // Day filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        DayChip(label: "All", tag: nil, selected: selectedDay)
                            .onTapGesture { selectedDay = nil }
                        ForEach(1...7, id: \.self) { day in
                            DayChip(label: dayName(day), tag: day, selected: selectedDay)
                                .onTapGesture { selectedDay = day }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }

                Divider()

                if service.isLoading && service.meetings.isEmpty {
                    ProgressView("Loading meetings...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = service.error, service.meetings.isEmpty {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                        Text(error)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            Task { await service.refresh() }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredMeetings) { meeting in
                        MeetingRow(meeting: meeting)
                    }
                    .listStyle(.plain)
                }

                if let lastUpdated = service.lastUpdated {
                    HStack {
                        Text("Found \(filteredMeetings.count) Meetings as of \(lastUpdated.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        if service.isLoading {
                            ProgressView().scaleEffect(0.6)
                        } else {
                            Button("Refresh") {
                                Task { await service.refresh() }
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(.bar)
                }
            }
            .searchable(text: $searchText, prompt: "Search meetings...")
            .navigationTitle("Meetings (\(filteredMeetings.count))")
            .task { await service.loadMeetings() }

        } detail: {
            Text("Select a meeting")
                .foregroundStyle(.secondary)
        }
    }

    private func dayName(_ day: Int) -> String {
        let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        guard day >= 1 && day <= 7 else { return "?" }
        return days[day - 1]
    }
}

struct DayChip: View {
    let label: String
    let tag: Int?
    let selected: Int?

    var isSelected: Bool { tag == selected }

    var body: some View {
        Text(label)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.15))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
    }
}

struct MeetingRow: View {
    let meeting: Meeting

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(meeting.name)
                    .font(.headline)
                Spacer()
                Text("\(meeting.weekdayName) \(meeting.formattedTime)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(meeting.venueLabel)
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(venueBadgeColor(meeting.venueType).opacity(0.2))
                .foregroundStyle(venueBadgeColor(meeting.venueType))
                .clipShape(Capsule())

            if meeting.venueType != 2 && !meeting.locationName.isEmpty {
                Text(meeting.locationName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if meeting.venueType != 2 {
                if !meeting.street.isEmpty || !meeting.city.isEmpty || !meeting.zip.isEmpty {
                    HStack {
                        Text([meeting.street, meeting.city, meeting.zip]
                            .filter { !$0.isEmpty }
                            .joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        if let lat = meeting.latitude, let lon = meeting.longitude {
                            Button {
                                openInMaps(lat: lat, lon: lon, name: meeting.name)
                            } label: {
                                Image(systemName: "map")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            if meeting.venueType == 2 || meeting.venueType == 3 {
                if let link = meeting.virtualLink, !link.isEmpty {
                    Text(link)
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            HStack {
                ForEach(meeting.formats.prefix(4), id: \.self) { format in
                    Text(format)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.15))
                        .clipShape(Capsule())
                }
                if meeting.isWheelchairAccessible {
                    Image(systemName: "figure.roll")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
        }
        .padding(.vertical, 4)
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
        let coords = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let placemark = MKPlacemark(coordinate: coords)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps()
    }
}

#Preview {
    ContentView()
}

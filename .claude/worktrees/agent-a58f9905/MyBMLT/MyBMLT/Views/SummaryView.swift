import SwiftUI

struct SummaryView: View {
    let meetings: [Meeting]
    let lastUpdated: Date?
    let selectedArea: Int

    private var filteredMeetings: [Meeting] {
        selectedArea == -1 ? meetings : meetings.filter { $0.serviceBodyId == selectedArea }
    }

    private var areaTitle: String {
        if selectedArea == -1 { return "All Areas" }
        return ServiceArea.all.first(where: { $0.id == selectedArea })?.fullName ?? "Unknown"
    }

    private var byVenue: [(label: String, count: Int, color: Color)] {
        [
            ("In-Person", filteredMeetings.filter { $0.venueType == 1 }.count, .green),
            ("Virtual",   filteredMeetings.filter { $0.venueType == 2 }.count, .blue),
            ("Hybrid",    filteredMeetings.filter { $0.venueType == 3 }.count, .orange),
        ]
    }

    private var byDay: [(label: String, count: Int)] {
        let days = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
        return (1...7).map { day in
            (days[day - 1], filteredMeetings.filter { $0.weekday == day }.count)
        }
    }

    private var byArea: [(label: String, count: Int)] {
        ServiceArea.all.compactMap { area in
            let count = meetings.filter { $0.serviceBodyId == area.id }.count
            return count > 0 ? (area.shortName, count) : nil
        }.sorted { $0.count > $1.count }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Total
                VStack(alignment: .leading, spacing: 4) {
                    Text(areaTitle)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("\(filteredMeetings.count)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                    Text("meetings")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let lastUpdated = lastUpdated {
                        Text("as of \(lastUpdated.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // By Venue
                VStack(alignment: .leading, spacing: 8) {
                    Text("By Venue Type")
                        .font(.headline)
                    ForEach(byVenue, id: \.label) { item in
                        HStack {
                            Text(item.label)
                                .font(.subheadline)
                                .frame(width: 90, alignment: .leading)
                            Text("\(item.count)")
                                .font(.subheadline)
                                .foregroundStyle(item.color)
                                .fontWeight(.semibold)
                        }
                    }
                }

                Divider()

                // By Day
                VStack(alignment: .leading, spacing: 8) {
                    Text("By Day of Week")
                        .font(.headline)
                    ForEach(byDay, id: \.label) { item in
                        HStack {
                            Text(item.label)
                                .font(.subheadline)
                                .frame(width: 40, alignment: .leading)
                            Text("\(item.count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // By Area — only show when All Areas selected
                if selectedArea == -1 {
                    Divider()
                    VStack(alignment: .leading, spacing: 8) {
                        Text("By Area")
                            .font(.headline)
                        ForEach(byArea, id: \.label) { item in
                            HStack {
                                Text(item.label)
                                    .font(.subheadline)
                                    .frame(width: 130, alignment: .leading)
                                Text("\(item.count)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Summary")
    }
}

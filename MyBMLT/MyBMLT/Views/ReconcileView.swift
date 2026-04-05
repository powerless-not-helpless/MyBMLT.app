import SwiftUI

struct ReconcileView: View {
    let meetings: [Meeting]

    private let centralID = 1157
    @State private var copied = false

    struct Entry {
        let areaName: String
        let weekdayName: String
        let startTime: String
        let formattedTime: String
        let street: String
        let city: String
        let zip: String

        var address: String {
            [street, city, zip].filter { !$0.isEmpty }.joined(separator: ", ")
        }
    }

    struct DualListing: Identifiable {
        let id = UUID()
        let name: String
        let weekday: Int
        let entries: [Entry]   // Central always first

        var primary: Entry { entries[0] }

        var timesMatch: Bool {
            entries.dropFirst().allSatisfy { $0.startTime == entries[0].startTime }
        }
    }

    var dualListings: [DualListing] {
        let grouped = Dictionary(grouping: meetings, by: { $0.name })
        var results: [DualListing] = []
        for (name, group) in grouped {
            guard group.count >= 2,
                  let central = group.first(where: { $0.serviceBodyId == centralID }),
                  group.contains(where: { $0.serviceBodyId != centralID })
            else { continue }
            let others = group
                .filter { $0.serviceBodyId != centralID }
                .sorted { $0.areaName < $1.areaName }
            let allMembers = [central] + others
            let entries = allMembers.map { m in
                Entry(areaName: m.areaName,
                      weekdayName: m.weekdayName,
                      startTime: m.startTime,
                      formattedTime: m.formattedTime,
                      street: m.street,
                      city: m.city,
                      zip: m.zip)
            }
            results.append(DualListing(name: name, weekday: central.weekday, entries: entries))
        }
        return results.sorted {
            if $0.weekday != $1.weekday { return $0.weekday < $1.weekday }
            return $0.entries[0].startTime < $1.entries[0].startTime
        }
    }

    var copyText: String {
        dualListings.map { listing in
            if listing.timesMatch {
                let e = listing.primary
                let areas = listing.entries.map { $0.areaName }.joined(separator: " · ")
                return "\(listing.name), \(e.weekdayName) at \(e.formattedTime), \(e.street), \(e.zip) — \(areas)"
            } else {
                return listing.entries.map { e in
                    "\(listing.name), \(e.weekdayName) at \(e.formattedTime), \(e.street), \(e.zip)"
                }.joined(separator: "\n")
            }
        }.joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if dualListings.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("No Dual Listings")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("No meetings are listed in both Central and another area.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(dualListings) { listing in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(listing.primary.weekdayName) at \(listing.primary.formattedTime)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(listing.name)
                                .font(.headline)
                            if !listing.primary.address.isEmpty {
                                Text(listing.primary.address)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Text(listing.entries.map { $0.areaName }.joined(separator: " · "))
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }

                HStack {
                    Text("\(dualListings.count) dual listing\(dualListings.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if !dualListings.isEmpty {
                        Button {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(copyText, forType: .string)
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                        } label: {
                            Label(copied ? "Copied!" : "Copy All",
                                  systemImage: copied ? "checkmark" : "doc.on.doc")
                        }
                        .font(.caption)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(.bar)
            }
            .navigationTitle("Reconcile")
        }
    }
}

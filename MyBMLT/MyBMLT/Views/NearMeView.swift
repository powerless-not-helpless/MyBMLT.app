import SwiftUI
import MapKit
import CoreLocation

struct NearMeView: View {
    let meetings: [Meeting]
    @EnvironmentObject var locationService: LocationService
    @StateObject private var viewModel = NearMeViewModel()

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                switch locationService.authStatus {
                case .denied, .restricted:
                    deniedView
                default:
                    if locationService.currentLocation == nil {
                        loadingView
                    } else if viewModel.nearMeetings.isEmpty {
                        emptyView
                    } else {
                        meetingsView
                    }
                }
            }
            .navigationTitle("Near Me")
            .onAppear {
                locationService.requestLocation()
                viewModel.recompute(meetings: meetings, location: locationService.currentLocation)
            }
            .onChange(of: meetings) { _, newMeetings in
                viewModel.recompute(meetings: newMeetings, location: locationService.currentLocation)
            }
            .onReceive(locationService.$currentLocation) { newLocation in
                viewModel.recompute(meetings: meetings, location: newLocation)
            }
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                viewModel.recompute(meetings: meetings, location: locationService.currentLocation)
            }
        } detail: {
            Text("Select a meeting")
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - States

    private var deniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "location.slash")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("Location Access Needed")
                .font(.headline)
            Text("Enable location in System Settings to find meetings near you.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Open Settings") {
                #if os(macOS)
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_LocationServices")!)
                #else
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                #endif
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("Finding your location…")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No meetings in the next 3 hours")
                .font(.headline)
            Text("Check back later or browse all meetings.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var meetingsView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Mini-map
                Map(coordinateRegion: $viewModel.mapRegion, showsUserLocation: true, annotationItems: mapAnnotationItems) { item in
                    MapAnnotation(coordinate: item.coordinate) {
                        VStack(spacing: 2) {
                            Text(item.name)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(item.color)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(item.color)
                                .offset(y: -3)
                        }
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding([.horizontal, .top])
                .padding(.bottom, 4)

                // Cards
                VStack(spacing: 10) {
                    ForEach(viewModel.nearMeetings) { item in
                        NearMeetingCard(item: item)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)

                // Footer
                HStack {
                    Text("Updated just now")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Refresh") {
                        locationService.requestLocation()
                    }
                    .font(.caption)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
    }

    // Only in-person and hybrid meetings with coordinates appear on the map
    private var mapAnnotationItems: [NearMeAnnotation] {
        viewModel.nearMeetings.compactMap { item in
            guard item.meeting.venueType != 2,
                  let lat = item.meeting.latitude,
                  let lon = item.meeting.longitude else { return nil }
            return NearMeAnnotation(
                id: item.meeting.id,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                name: item.meeting.name,
                color: item.meeting.venueType == 3 ? .orange : .green
            )
        }
    }
}

struct NearMeetingCard: View {
    let item: MeetingWithDistance

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(item.meeting.name)
                    .font(.headline)
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(item.timeLabel)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(timeLabelColor)
                    Text(item.meeting.formattedTime)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 6) {
                Text(item.meeting.venueLabel)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(venueBadgeColor(item.meeting.venueType).opacity(0.2))
                    .foregroundStyle(venueBadgeColor(item.meeting.venueType))
                    .clipShape(Capsule())

                if let dist = item.distanceLabel {
                    Text("\(dist) · \(item.meeting.locationName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else if item.meeting.venueType == 2,
                          let link = item.meeting.virtualLink, !link.isEmpty {
                    Text(link)
                        .font(.caption)
                        .foregroundStyle(.blue)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            if item.meeting.venueType != 2,
               !item.meeting.street.isEmpty || !item.meeting.city.isEmpty {
                Text([item.meeting.street, item.meeting.city]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", "))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(item.minutesUntil <= 0 ? Color.orange.opacity(0.4) : Color.clear, lineWidth: 2)
        )
    }

    private var timeLabelColor: Color {
        if item.minutesUntil <= 0 { return .orange }
        if item.minutesUntil <= 30 { return .blue }
        return .secondary
    }

    private func venueBadgeColor(_ type: Int) -> Color {
        switch type {
        case 1: return .green
        case 2: return .blue
        case 3: return .orange
        default: return .secondary
        }
    }
}

struct NearMeAnnotation: Identifiable {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    let name: String
    let color: Color
}

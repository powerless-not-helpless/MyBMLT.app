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
        Text("Meetings found — cards coming in next task")
    }
}

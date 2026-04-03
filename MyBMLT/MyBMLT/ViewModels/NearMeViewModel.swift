import Foundation
import Combine
import CoreLocation
import MapKit

// MARK: - ViewModel

class NearMeViewModel: ObservableObject {
    @Published var nearMeetings: [MeetingWithDistance] = []
    @Published var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    ))

    func recompute(meetings: [Meeting], location: CLLocation?) {
        let result = upcomingNearby(from: meetings, location: location)
        nearMeetings = result
        if let loc = location, !result.isEmpty {
            cameraPosition = .region(fitRegion(meetings: result, userLocation: loc))
        }
    }
}

// MARK: - Pure filtering function (testable)

func upcomingNearby(
    from meetings: [Meeting],
    location: CLLocation?,
    now: Date = Date()
) -> [MeetingWithDistance] {
    let cal = Calendar.current
    let comps = cal.dateComponents([.weekday, .hour, .minute], from: now)
    guard let nowWeekday = comps.weekday,
          let nowHour = comps.hour,
          let nowMinute = comps.minute else { return [] }

    let nowMinutes = nowHour * 60 + nowMinute

    return meetings.compactMap { meeting -> MeetingWithDistance? in
        let parts = meeting.startTime.split(separator: ":").map { String($0) }
        guard parts.count >= 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]) else { return nil }
        let meetingMinutes = h * 60 + m

        let dayDelta = meeting.weekday - nowWeekday
        var rawDelta = dayDelta * 1440 + meetingMinutes - nowMinutes

        // Advance to the next occurrence not more than 10 min in the past
        while rawDelta < -10 { rawDelta += 10080 }

        guard rawDelta <= 180 else { return nil }

        var distanceMiles: Double? = nil
        if meeting.venueType != 2,
           let lat = meeting.latitude,
           let lon = meeting.longitude,
           let userLoc = location {
            distanceMiles = userLoc.distance(from: CLLocation(latitude: lat, longitude: lon)) / 1609.34
        }

        return MeetingWithDistance(meeting: meeting, minutesUntil: rawDelta, distanceMiles: distanceMiles)
    }
    .sorted { $0.minutesUntil < $1.minutesUntil }
    .prefix(3)
    .map { $0 }
}

// MARK: - Map region helper

func fitRegion(meetings: [MeetingWithDistance], userLocation: CLLocation) -> MKCoordinateRegion {
    let coords = meetings.compactMap { m -> CLLocationCoordinate2D? in
        guard let lat = m.meeting.latitude, let lon = m.meeting.longitude else { return nil }
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    } + [userLocation.coordinate]

    let minLat = coords.map(\.latitude).min()!
    let maxLat = coords.map(\.latitude).max()!
    let minLon = coords.map(\.longitude).min()!
    let maxLon = coords.map(\.longitude).max()!

    let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2,
                                        longitude: (minLon + maxLon) / 2)
    let span = MKCoordinateSpan(
        latitudeDelta: max((maxLat - minLat) * 1.4, 0.01),
        longitudeDelta: max((maxLon - minLon) * 1.4, 0.01)
    )
    return MKCoordinateRegion(center: center, span: span)
}

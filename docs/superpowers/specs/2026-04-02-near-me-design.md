# Near Me — Design Spec
**Date:** 2026-04-02  
**Status:** Approved

## Overview

A new "Near Me" tab that shows the next 3 upcoming meetings within the next 3 hours, sorted by start time, with distance displayed as secondary info. Designed for macOS first with an iOS port in mind.

## Use Case

> "I'm somewhere and want to know what meetings I can get to in the next 3 hours."

The user opens the Near Me tab, the app requests their GPS location, and immediately shows up to 3 meetings sorted soonest-first. No radius cutoff — distance is informational only.

---

## New Files

### `Services/LocationService.swift`
- `ObservableObject` owning a `CLLocationManager`
- `@Published currentLocation: CLLocation?`
- `@Published authStatus: CLAuthorizationStatus`
- Location permission requested on first `requestLocation()` call — not at app launch
- **macOS:** `requestLocation()` — one-shot, called on tab appear and on manual refresh
- **iOS:** `startUpdatingLocation()` with `desiredAccuracy = kCLLocationAccuracyHundredMeters` — continuous while tab is visible

### `Models/MeetingWithDistance.swift`
Ephemeral wrapper created fresh on each recompute. Not Codable — not persisted.

```swift
struct MeetingWithDistance: Identifiable {
    let meeting: Meeting
    let minutesUntil: Int      // negative = in-progress (within grace window)
    let distanceMiles: Double? // nil for virtual-only meetings

    var id: Int { meeting.id }

    var timeLabel: String {
        if minutesUntil <= 0 { return "In progress" }
        if minutesUntil < 60 { return "in \(minutesUntil) min" }
        let h = minutesUntil / 60, m = minutesUntil % 60
        return m == 0 ? "in \(h) hr" : "in \(h) hr \(m) min"
    }

    var distanceLabel: String? {
        guard let d = distanceMiles else { return nil }
        return String(format: "%.1f mi", d)
    }
}
```

### `ViewModels/NearMeViewModel.swift`
- `ObservableObject`
- Initialized with references to `BMLTService` and `LocationService`
- `@Published nearMeetings: [MeetingWithDistance]` — max 3 items
- Subscribes to `LocationService.$currentLocation` via Combine — triggers recompute on location change
- **macOS:** additionally runs a `Timer.publish(every: 60, ...)` to recompute as the clock advances
- **iOS:** location-driven recompute is sufficient; no separate timer needed

### `Views/NearMeView.swift`
- Pure display layer — observes `NearMeViewModel`
- `onAppear` calls `LocationService.requestLocation()`
- Renders one of four states (see UI States below)
- When meetings are found: shows mini-map above the card list (see Mini-Map below)

---

## Modified Files

### `MyBMLTApp.swift`
Add `@StateObject var locationService = LocationService()` and inject into the SwiftUI environment.

### `ContentView.swift`
Add Near Me tab with `Label("Near Me", systemImage: "location.circle")`. Pass `locationService` as `@EnvironmentObject` to `NearMeView`.

---

## Filtering & Sorting Logic

```
nowMinutes     = currentHour * 60 + currentMinute
meetingMinutes = meeting startTime hour * 60 + minute
dayDelta       = meeting.weekday - currentWeekday

rawDelta = dayDelta * 1440 + meetingMinutes - nowMinutes

// advance to the next occurrence not more than 10 min in the past
while rawDelta < -10: rawDelta += 10080   // 10080 = one week in minutes

include if rawDelta <= 180   // within next 3 hours (or in grace window)
```

Sort by `rawDelta` ascending. Take first 3.

**Notes:**
- All venue types included (in-person, hybrid, virtual). Virtual meetings have `distanceMiles = nil`.
- Distance computed as: `userLocation.distance(from: CLLocation(latitude: lat, longitude: lon)) / 1609.34`
- BMLT provides no cancellation data — list reflects the scheduled recurring meeting schedule only.

---

## UI States

| State | Trigger | Display |
|---|---|---|
| Loading | `authStatus == .authorizedWhenInUse`, no location yet | "Finding your location…" + progress bar |
| Permission denied | `authStatus == .denied` or `.restricted` | Icon + message + "Open Settings" link |
| No meetings | Location known, `nearMeetings.isEmpty` | "No meetings in the next 3 hours" |
| Meetings found | `nearMeetings` has 1–3 items | Cards + footer |

## Meeting Card Layout

- **Meeting name** — headline, left-aligned
- **Time-until** — prominent, blue (urgent ≤30 min), gray (>1 hr), orange accent + "In progress" for grace-window
- **Clock time** — secondary, below time-until
- **Venue badge** — In-Person (green), Hybrid (orange), Virtual (blue)
- **Distance** — `X.X mi · Location Name` (omitted for virtual)
- **Address** — tertiary, gray
- **Virtual link** — shown in place of distance/address for virtual meetings

## Mini-Map

Shown above the meeting cards when `nearMeetings` is non-empty. Read-only — no tap interaction on pins.

- Fixed height (~180pt), full width, rounded corners
- SwiftUI `Map` view with:
  - **User location dot** — via `showsUserLocation: true` (no custom annotation needed)
  - **Meeting pins** — one `MapAnnotation` per in-person or hybrid meeting with coordinates; virtual-only meetings are excluded
  - **Region** — auto-fit to bounding box of all visible pins + user location, with ~20% padding
- Region is recomputed whenever `nearMeetings` or `currentLocation` changes
- No tap handling on pins in v1 — pins are display-only

```swift
// Region fitting helper (in NearMeViewModel or a free function)
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
    let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4,
                                longitudeDelta: (maxLon - minLon) * 1.4)
    return MKCoordinateRegion(center: center, span: span)
}
```

## Footer
- Left: "Updated just now · [City, State]" (from reverse geocode or last known location label)
- Right: "Refresh" button → triggers new one-shot location request

---

## Platform Notes (iOS Port)

- Replace `NSWorkspace.shared.open` in `openInMaps` with a `#if os(macOS)` / `#if os(iOS)` branch using `UIApplication.shared.open`
- `LocationService` handles platform differences internally via `#if os(iOS)` — callers are unaffected
- `NavigationSplitView` in `ContentView` collapses to stack navigation on iOS automatically
- No timer in `NearMeViewModel` on iOS — location updates drive all recomputation

---

## Out of Scope

- Saved/home location fallback
- Radius filter or distance cutoff
- Cancellation/schedule exception data

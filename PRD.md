# MyBMLT — Product Requirements Document

**Version:** 1.0  
**Date:** 2026-04-05  
**Platform:** iOS 17+ / macOS 14+ (Universal)  
**Language:** Swift / SwiftUI

---

## 1. Overview

MyBMLT is a native Swift/SwiftUI meeting finder for the San Diego area, powered by the [BMLT (Basic Meeting List Toolkit)](https://bmlt.app) regional server. It enables members to browse, filter, and navigate to in-person, virtual, and hybrid 12-step meetings across nine San Diego service areas.

The app is distributed as a Universal binary (iPhone, iPad, Mac via Mac Catalyst or native) and is intended for direct distribution — not the App Store.

---

## 2. Goals

- Give San Diego area members a fast, offline-capable meeting list
- Surface nearby upcoming meetings using device location
- Allow personal curation (Favorites, Visit List)
- Detect newly added meetings between sessions
- Help service workers identify meetings dual-listed across areas (Reconcile)

---

## 3. Non-Goals

- Not a general-purpose BMLT client (hardcoded to service body 1155)
- No user accounts, login, or server-side data writes
- No push notifications
- No editing or submitting meetings to the server

---

## 4. Data Source

| Field | Value |
|---|---|
| BMLT Root Server | `https://bmlt.wszf.org/main_server` |
| Service Body ID | `1155` |
| API Endpoint | `/client_interface/json/?switcher=GetSearchResults` |
| Query Params | `get_used_formats=1`, `lang_enum=en`, `services[]=1155`, `recursive=1` |
| Format | JSON — `BMLTMeetingRaw` → `Meeting` model |

---

## 5. Service Areas

Nine service areas under service body 1155:

| ID | Short Name | Full Name |
|---|---|---|
| (dynamic) | Beach | Beach Area |
| (dynamic) | Central | Central Area |
| (dynamic) | Hispana | Habla Hispana Area |
| (dynamic) | Imperial Valley | Imperial Valley Area |
| (dynamic) | N. Coastal | North Coastal Area |
| (dynamic) | N. County Inland | North County Inland Area |
| (dynamic) | SEBANA | South East Barrio Area |
| (dynamic) | South Bay | South Bay Area |
| (dynamic) | UEC | United East County Area |

Service area IDs are defined statically in `ServiceArea.swift`.

---

## 6. Data Model

### `Meeting`

| Field | Type | Notes |
|---|---|---|
| `id` | `Int` | BMLT meeting ID |
| `name` | `String` | Meeting name |
| `weekday` | `Int` | 1 = Sunday … 7 = Saturday |
| `startTime` | `String` | `HH:MM:SS` |
| `duration` | `String` | `HH:MM:SS` |
| `locationName` | `String` | Venue name |
| `street` | `String` | Street address |
| `city` | `String` | City |
| `zip` | `String` | ZIP code |
| `virtualLink` | `String?` | Zoom / meeting URL |
| `virtualInfo` | `String?` | Password field (raw, may need stripping) |
| `formats` | `[String]` | Format codes (e.g. OD, BB, SP, W) |
| `serviceBodyId` | `Int` | Maps to `ServiceArea` |
| `venueType` | `Int` | 1 = In-Person, 2 = Virtual, 3 = Hybrid |
| `latitude` | `Double?` | GPS coordinate |
| `longitude` | `Double?` | GPS coordinate |

**Computed properties:** `isWheelchairAccessible` (formats contain WC/WCAB/HC), `weekdayName`, `formattedTime`, `formattedDuration`, `venueLabel`, `areaName`, `passwordValue` (strips label prefixes from `virtualInfo`).

---

## 7. Caching

- On launch, `BMLTService` loads the previous JSON cache from `ApplicationSupport/MyBMLT/meetings_cache.json` immediately, then fetches fresh data from the network in the background.
- Cache payload includes a `date` timestamp and the full `[Meeting]` array.
- Displayed data is always the freshest available (cache → network update).
- A manual **Refresh** button forces a new network fetch.

---

## 8. Features

### 8.1 Meetings Tab

- Displays all meetings for the selected filters in a scrollable list
- **Filters:**
  - Area picker (All Areas + 9 service areas)
  - Venue picker (All / In-Person / Virtual / Hybrid / Women)
    - Women filter matches meetings with format code `W`
  - Day chips (All + Sun–Sat)
- **Search:** name, city, street, or zip; case-insensitive; history saved via `SearchHistoryService`
- **List row:** name, day/time, venue badge, location name, address, format tags, wheelchair icon, map icon (in-person/hybrid), pin icon (Visit List), star icon (Favorites)
- **Detail panel (split view on iPad/Mac):** full meeting detail, Join Meeting button, Open in Maps button, Copy button, star toggle
- **Summary panel:** shown when no meeting is selected — total count, breakdown by venue type, by day, by area (when All Areas selected)
- **Status bar:** last updated timestamp, loading indicator, Refresh button

### 8.2 Near Me Tab

- Shows up to 3 upcoming in-person or hybrid meetings starting within the next 3 hours
- Includes meetings that started up to 10 minutes ago (labeled "In progress")
- Requires `When In Use` location authorization
- Sorted by proximity; distance shown in miles
- Mini map (MapKit) shows pins for nearby meetings and current user location; auto-fits region
  - Green pins = In-Person, Orange pins = Hybrid
- Time label colors: Orange (in progress), Blue (starting ≤ 30 min), Gray (> 30 min)
- Auto-refreshes every 60 seconds; manual Refresh button
- Tap card → Meeting Detail; Join Meeting button for virtual/hybrid; Map icon for in-person/hybrid

### 8.3 Favorites Tab

- Meetings starred by the user, persisted across sessions via `FavoritesService` (UserDefaults or file)
- Sorted by weekday then start time
- Tap to open Meeting Detail

### 8.4 New Meetings Tab

- Compares current server data to snapshot from previous launch via `NewMeetingsService`
- Shows meetings added since last session
- Tab badge shows count of unseen new meetings
- **Mark All Seen** clears the list and resets badge

### 8.5 Visit List Tab

- Personal itinerary — separate from Favorites
- Meetings added/removed via pin icon in the Meetings list
- Sorted by weekday then start time; footer shows total count
- **Copy All** exports the list to clipboard as formatted plain text (grouped by day, with address or link and formats)

### 8.6 Reconcile Tab

- Shows meetings whose name appears in both Central Area and at least one other service area
- Row displays: day/time from Central listing, address from Central listing, area badges (all areas, Central first)
- **Copy All** exports dual-listed meetings to clipboard
  - Same time across areas → one combined line
  - Different times → separate lines per area

---

## 9. Platform Behavior

### Maps Integration

- In-person and hybrid meetings show a map icon that opens Apple Maps (iOS: `UIApplication.shared.open`, macOS: `NSWorkspace.shared.open`) using `maps://?q=<name>&ll=<lat>,<lon>`

### Zoom Integration

- Virtual and hybrid meetings show a **Join Meeting** button
- Attempts to open the Zoom deep link (`zoomus://`); falls back to the meeting URL in the default browser if Zoom is not installed
- Password, if present, is included in the deep link automatically

### Location

- `LocationService` wraps `CLLocationManager`
- Requests `.authorizedWhenInUse`; provides a button to open System Settings if denied
- Distance calculations used only in Near Me tab

---

## 10. Architecture

```
MyBMLTApp
└── ContentView (TabView)
    ├── Meetings Tab (NavigationSplitView)
    │   ├── MeetingRow
    │   ├── MeetingDetailView
    │   └── SummaryView
    ├── FavoritesView
    ├── NearMeView + NearMeViewModel
    ├── NewMeetingsView
    ├── VisitListView
    └── ReconcileView

Services (ObservableObject, injected via environmentObject or StateObject)
├── BMLTService        — network fetch + cache
├── FavoritesService   — starred meetings persistence
├── LocationService    — CLLocationManager wrapper
├── NewMeetingsService — new-meeting detection
├── SearchHistoryService — recent search persistence
└── VisitListService   — visit list persistence

Models
├── Meeting            — core domain type (Codable, Hashable)
├── MeetingWithDistance — Meeting + computed distance
├── BMLTMeetingRaw     — raw BMLT JSON shape → toMeeting()
└── ServiceArea        — static area definitions
```

---

## 11. Distribution

- Universal binary supporting iPhone, iPad, and Mac
- Distributed via direct install (`.dmg` / `.ipa`), not through the App Store
- macOS installer built to `dist/macos/`

---

## 12. Open Items / Future Considerations

- Service area IDs are currently hardcoded; could be fetched from the BMLT server dynamically
- Favorites and Visit List persistence mechanism (currently implied UserDefaults/file) could be made more robust
- No unit test coverage currently in `MyBMLTTests/` — test suite is present but empty
- Reconcile tab is scoped to Central vs. other areas; could generalize to any two areas
- No localization; app is English-only (Spanish meetings exist in the data but UI is English)

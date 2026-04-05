# Plan: MyBMLT User Guide

## Context
MyBMLT is an iOS app for finding NA/AA meetings in the San Diego region via the BMLT server. There is no existing user-facing documentation. This plan creates a `USER_GUIDE.md` at the project root covering all 5 tabs and key interactions.

---

## Output
**File:** `/Users/jj/Projects/MyBMLT/UserGuide.html` — single self-contained HTML file with inline CSS, no external dependencies

---

## Structure

### 1. Overview
- What the app is and who it's for
- Data source: BMLT San Diego regional server

### 2. Meetings Tab
- Browsing the full meeting list
- Day-of-week chip filters (All, Sun–Sat)
- Service Area dropdown (9 regions)
- Venue Type dropdown (All, In-Person, Virtual, Hybrid)
- Search bar (name, city, street, zip) + recent search history
- Star icon → Favorites, Pin icon → Visit List
- "Open in Maps" for in-person meetings
- Tapping a meeting opens detail view
- Refresh button + last-synced timestamp

### 3. Near Me Tab
- Location permission prompt on first open
- Shows up to 3 upcoming meetings in the next 3 hours
- Mini-map with pins for user location and meeting locations
- Distance shown for in-person/hybrid meetings
- Color-coded urgency: orange = in progress, blue = within 30 min, gray = later
- "Join Meeting" button for virtual/hybrid (opens Zoom)
- "Open in Maps" to navigate to physical location

### 4. Favorites Tab
- How to star/unstar a meeting
- Persists between sessions
- Sorted by day then start time

### 5. New Meetings Tab
- Shows meetings added to the server since last app use
- "Mark All Seen" clears the list
- Useful for staying aware of new local meetings

### 6. Visit List Tab
- Pin icon adds/removes meetings
- Meetings grouped by day of week
- "Copy All" exports formatted text to clipboard (day, name, time, location, formats)

### 7. Meeting Detail View
- All fields: name, day/time, duration, venue badge, accessibility, service area
- Location + "Open in Maps"
- Virtual link + "Join Meeting"
- Formats list
- Copy details button

### 8. Tips & Troubleshooting
- Refresh if data looks stale
- Location permission needed for Near Me
- Virtual meetings open Zoom if installed, otherwise browser

---

## Critical Files (read before writing)
- `/Users/jj/Projects/MyBMLT/MyBMLT/Views/ContentView.swift` — filters, search, meetings tab
- `/Users/jj/Projects/MyBMLT/MyBMLT/Views/NearMeView.swift` — Near Me tab
- `/Users/jj/Projects/MyBMLT/MyBMLT/Views/MeetingDetailView.swift` — detail view fields
- `/Users/jj/Projects/MyBMLT/MyBMLT/Views/VisitListView.swift` — visit list + copy export
- `/Users/jj/Projects/MyBMLT/MyBMLT/Views/NewMeetingsView.swift` — new meetings tab
- `/Users/jj/Projects/MyBMLT/MyBMLT/Views/FavoritesView.swift` — favorites tab

---

## Verification
- Read each view file to confirm UI labels, button names, and behavior match what's written
- Confirm service area names match `ServiceArea` model
- Confirm grace window (10 min) and lookahead (3 hours) values from `NearMeViewModel`

# MyBMLT

**User Guide — San Diego Area Meeting Finder**

---

## Contents

1. [Overview](#overview)
2. [Meetings Tab — Browse & Filter](#meetings-tab--browse--filter)
3. [Meeting Detail](#meeting-detail)
4. [Near Me Tab — Find Upcoming Meetings](#near-me-tab--find-upcoming-meetings)
5. [Favorites Tab](#favorites-tab)
6. [New Meetings Tab](#new-meetings-tab)
7. [Visit List Tab](#visit-list-tab)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**What MyBMLT is and how it works**

**MyBMLT** is a meeting finder for the San Diego area, powered by the [BMLT (Basic Meeting List Toolkit)](https://bmlt.app) regional server. It lets you browse, search, and filter hundreds of in-person, virtual, and hybrid meetings across nine service areas.

The app has five tabs:

- **Meetings** — full searchable meeting list with filters
- **Near Me** — the next 3 meetings starting near you in the next 3 hours
- **Favorites** — meetings you've starred for quick access
- **New** — recently added meetings on the server
- **Visit List** — a personal itinerary you can copy and share

> **💡 Tip:** Meeting data is fetched live from the BMLT server and cached locally. The app always shows the most recent data it has while it fetches a fresh copy in the background.

---

## Meetings Tab — Browse & Filter

**Browse, search, and filter all meetings in the San Diego area**

### Filters

Three filter controls sit above the meeting list:

**Area** (dropdown) — narrow results to one of nine service areas, or leave on *All Areas*:

| Short Name | Full Name |
|---|---|
| Beach | Beach Area |
| Central | Central Area |
| Hispana | Habla Hispana Area |
| Imperial Valley | Imperial Valley Area |
| N. Coastal | North Coastal Area |
| N. County Inland | North County Inland Area |
| SEBANA | South East Barrio Area |
| South Bay | South Bay Area |
| UEC | United East County Area |

**Venue** (dropdown) — show only in-person, virtual, or hybrid meetings:

- All
- In-Person
- Virtual
- Hybrid

**Day chips** — tap a day to show only meetings on that day: All, Sun, Mon, Tue, Wed, Thu, Fri, Sat

### Search

Use the search bar at the top to find meetings by **name**, **city**, **street**, or **zip code**. Previous searches are saved and shown as suggestions when you tap the search bar while the field is empty. Tap *Clear* to remove search history.

### Meeting List

Each row shows the meeting name, day and start time, venue badge, location name, and address. Format tags (e.g. *OD*, *BB*) and a wheelchair icon appear at the bottom of each row when applicable.

Two quick-action icons appear on the right of every row:

- **Pin icon** (📌) — add or remove the meeting from your [Visit List](#visit-list-tab). Filled red pin = on the list.
- **Star icon** (⭐) — add or remove the meeting from [Favorites](#favorites-tab). Filled yellow star = favorited.

For in-person or hybrid meetings, a small **map icon** opens Apple Maps (or the Maps application on macOS) directly to the meeting location.

### Refresh

A status bar at the bottom of the list shows the last time data was updated and a **Refresh** button. Tap it to force a fresh fetch from the server.

### Summary View

When no meeting is selected, the right panel (or detail area on iPhone) shows a statistics summary: total meeting count, breakdown by venue type, by day of week, and — when *All Areas* is selected — a per-area breakdown.

---

## Meeting Detail

**All information about a single meeting**

Tap any meeting to open its detail view. It contains:

- **Name, day, time, and duration**
- **Venue badge** — In-Person / Virtual / Hybrid
- **Wheelchair accessible** indicator (blue wheelchair icon), when applicable
- **Service area** name
- **Location section** (in-person and hybrid) — venue name, full address, and an *Open in Maps* button
- **Online Meeting section** (virtual and hybrid) — a *Join Meeting* button that opens Zoom directly if installed, otherwise opens the link in a browser. Meeting password is displayed with a lock icon if one is required.
- **Meeting Formats** — all format codes for the meeting (e.g. OD, BB, SP)

Two action buttons appear in the top-right corner:

- **Star button** — toggle the meeting in/out of Favorites
- **Copy button** — copies meeting details (name, time, address or link, formats) to the clipboard as plain text. The button briefly shows "Copied!" as confirmation.

> **ℹ️ Note:** For Zoom meetings, the app tries to launch the Zoom app directly using a deep link. If Zoom is not installed, it falls back to opening the meeting URL in your default browser.

---

## Near Me Tab — Find Upcoming Meetings

**Find the next upcoming meetings closest to your current location**

### How it works

The Near Me tab shows up to **3 meetings** that start within the **next 3 hours**. It includes meetings that started up to **10 minutes ago** (these are marked as "In progress").

The list updates automatically every 60 seconds. Tap **Refresh** at the bottom to update immediately.

### Location Permission

The first time you open this tab, the app will request permission to use your location. Grant *While Using the App* for the best experience. Distance to in-person and hybrid meetings is shown in miles.

If location access is denied, tap **Open Settings** to enable it in System Settings → Privacy & Security → Location Services.

### Map

A mini-map at the top shows pins for all nearby in-person and hybrid meetings, plus your current location. The map region automatically fits to include all visible meetings.

- Green pins = In-Person meetings
- Orange pins = Hybrid meetings

### Time Urgency Colors

The time label on each card is color-coded:

| Color | Status | Meaning |
|---|---|---|
| Orange | In progress | Started within last 10 min |
| Blue | Starting soon | Within 30 minutes |
| Gray | Later | More than 30 min away |

### Actions on each card

- **Join Meeting** — appears for virtual and hybrid meetings; opens Zoom or browser.
- **Map icon** — appears for in-person and hybrid meetings; opens Apple Maps.
- Tap anywhere on the card to open the full [Meeting Detail](#meeting-detail) view.

> **💡 Tip:** The Near Me tab looks ahead only 3 hours. If no meetings appear, check the [Meetings tab](#meetings-tab--browse--filter) to see all upcoming meetings for the week.

---

## Favorites Tab

**Your saved meetings for quick access**

Tap the **star icon** on any meeting — in the list row, or in the detail view — to add it to Favorites. Tap again to remove it.

Favorites are **saved between sessions**. The Favorites tab shows all starred meetings sorted by day of week, then start time. Tapping a meeting opens its [detail view](#meeting-detail).

> **ℹ️ Note:** The star icon is yellow when a meeting is favorited and gray when it is not.

---

## New Meetings Tab

**Stay aware of meetings recently added to the server**

Each time the app loads fresh data, it compares the current meeting list to what it saw on the previous launch. Any meetings that are **new since your last visit** appear in this tab.

1. Open the **New** tab to see recently added meetings.
2. Tap any meeting to view its details.
3. When you've reviewed everything, tap **Mark All Seen** to clear the list.

> **💡 Tip:** The tab badge count shows how many unseen new meetings exist. Once you tap *Mark All Seen*, the count resets to zero.

---

## Visit List Tab

**Build a personal meeting itinerary and share it**

The Visit List is a curated list of meetings you plan to attend. It's separate from Favorites — use it to plan a schedule or share a list of recommended meetings.

### Adding and removing meetings

- Tap the **pin icon** on any meeting row in the Meetings tab to add it to the Visit List. A filled red pin means it's on the list.
- To remove a meeting while in the Visit List tab, tap the **red pin-slash icon** on the right side of the row.

### Viewing your list

Meetings are sorted by day of week, then start time. The footer shows the total count. Tap any meeting to open its [detail view](#meeting-detail).

### Copying your list

Tap **Copy All** in the bottom bar to copy the entire Visit List to the clipboard as formatted plain text, organized by day. You can paste it into a message, note, or email to share with others.

Example clipboard output:

```
Sunday
  Serenity Group at 8:00 AM
  1234 Ocean Blvd, San Diego, 92109
  Formats: OD, BB

Monday
  Monday Night Live at 7:30 PM
  https://zoom.us/j/123456789
  Formats: SP, D
```

> **💡 Tip:** The *Copy All* button briefly shows "Copied!" for 2 seconds to confirm.

---

## Troubleshooting

**Common questions and solutions**

**The meeting list is empty or shows old data**
Tap **Refresh** at the bottom of the Meetings tab. If the error icon appears, tap **Retry**. Check your internet connection if the problem persists.

**Near Me shows "No meetings in the next 3 hours"**
There are no meetings starting within 3 hours of now in the area. Browse the **Meetings** tab to see all scheduled meetings this week.

**Near Me says location access is needed**
Tap **Open Settings** and enable location access for MyBMLT under Privacy & Security → Location Services. Choose *While Using the App*.

**Tapping "Join Meeting" opens a browser instead of Zoom**
The Zoom app must be installed on your device. If it's not installed, the meeting link opens in your default browser instead, which also works.

**A meeting shows a lock icon with password info**
That meeting requires a Zoom password. The password is shown next to the lock icon in the detail view. The *Join Meeting* button includes the password in the Zoom deep link automatically.

**My favorites or visit list disappeared**
Both lists are stored in the app's local cache. They persist across launches but are tied to the app installation. Reinstalling the app will clear them.

**I don't see a meeting I know exists**
Check your current filters — day chip, area, and venue type. Tap **All** on the day chips and set the area and venue dropdowns back to *All Areas* / *All*. Also try a fresh **Refresh**.

---

*MyBMLT — Data sourced from the BMLT regional server. Meeting information may change; always verify with your local service area.*

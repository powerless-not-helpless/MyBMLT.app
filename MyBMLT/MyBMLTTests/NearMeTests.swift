import XCTest
import CoreLocation
@testable import MyBMLT

final class NearMeTests: XCTestCase {

    // MARK: - MeetingWithDistance

    func testTimeLabel_inProgress() {
        let m = MeetingWithDistance(meeting: .fixture(), minutesUntil: -5, distanceMiles: 1.2)
        XCTAssertEqual(m.timeLabel, "In progress")
    }

    func testTimeLabel_zero() {
        let m = MeetingWithDistance(meeting: .fixture(), minutesUntil: 0, distanceMiles: nil)
        XCTAssertEqual(m.timeLabel, "In progress")
    }

    func testTimeLabel_underAnHour() {
        let m = MeetingWithDistance(meeting: .fixture(), minutesUntil: 44, distanceMiles: nil)
        XCTAssertEqual(m.timeLabel, "in 44 min")
    }

    func testTimeLabel_exactHour() {
        let m = MeetingWithDistance(meeting: .fixture(), minutesUntil: 60, distanceMiles: nil)
        XCTAssertEqual(m.timeLabel, "in 1 hr")
    }

    func testTimeLabel_hoursAndMinutes() {
        let m = MeetingWithDistance(meeting: .fixture(), minutesUntil: 74, distanceMiles: nil)
        XCTAssertEqual(m.timeLabel, "in 1 hr 14 min")
    }

    func testDistanceLabel_nil() {
        let m = MeetingWithDistance(meeting: .fixture(), minutesUntil: 30, distanceMiles: nil)
        XCTAssertNil(m.distanceLabel)
    }

    func testDistanceLabel_formatted() {
        let m = MeetingWithDistance(meeting: .fixture(), minutesUntil: 30, distanceMiles: 2.834)
        XCTAssertEqual(m.distanceLabel, "2.8 mi")
    }

    // MARK: - upcomingNearby

    // Helper: build a fixed Date for a given weekday/hour/minute
    // weekday: 1=Sun, 2=Mon, ..., 7=Sat (Calendar convention)
    private func makeDate(weekday: Int, hour: Int, minute: Int) -> Date {
        var comps = DateComponents()
        comps.weekday = weekday
        comps.hour = hour
        comps.minute = minute
        comps.second = 0
        // Use a fixed reference: 2026-03-29 is a Sunday (weekday=1)
        comps.year = 2026
        comps.month = 3
        comps.day = 28 + weekday  // Sun=29, Mon=30, ..., Sat=4 Apr
        return Calendar.current.date(from: comps)!
    }

    func testUpcomingNearby_returnsMatchingMeeting() {
        // Meeting on Monday at 7:30 PM, now is Monday 7:00 PM → 30 min away
        let now = makeDate(weekday: 2, hour: 19, minute: 0)
        let meeting = Meeting.fixture(weekday: 2, startTime: "19:30:00", venueType: 1)
        let result = upcomingNearby(from: [meeting], location: nil, now: now)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].minutesUntil, 30)
    }

    func testUpcomingNearby_excludesMeetingBeyond3Hours() {
        // Meeting at 7 PM, now is 3 PM → 4 hours away → excluded
        let now = makeDate(weekday: 2, hour: 15, minute: 0)
        let meeting = Meeting.fixture(weekday: 2, startTime: "19:00:00", venueType: 1)
        let result = upcomingNearby(from: [meeting], location: nil, now: now)
        XCTAssertTrue(result.isEmpty)
    }

    func testUpcomingNearby_graceWindow_included() {
        // Meeting started 8 minutes ago → within 10-min grace → included as "in progress"
        let now = makeDate(weekday: 2, hour: 19, minute: 8)
        let meeting = Meeting.fixture(weekday: 2, startTime: "19:00:00", venueType: 1)
        let result = upcomingNearby(from: [meeting], location: nil, now: now)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].minutesUntil, -8)
    }

    func testUpcomingNearby_outsideGrace_excluded() {
        // Meeting started 11 minutes ago → outside 10-min grace → excluded (next week)
        let now = makeDate(weekday: 2, hour: 19, minute: 11)
        let meeting = Meeting.fixture(weekday: 2, startTime: "19:00:00", venueType: 1)
        let result = upcomingNearby(from: [meeting], location: nil, now: now)
        XCTAssertTrue(result.isEmpty)
    }

    func testUpcomingNearby_sortedSoonestFirst() {
        let now = makeDate(weekday: 2, hour: 19, minute: 0)
        let m1 = Meeting.fixture(id: 1, weekday: 2, startTime: "21:00:00")  // 2 hrs away
        let m2 = Meeting.fixture(id: 2, weekday: 2, startTime: "19:30:00")  // 30 min away
        let m3 = Meeting.fixture(id: 3, weekday: 2, startTime: "20:00:00")  // 1 hr away
        let result = upcomingNearby(from: [m1, m2, m3], location: nil, now: now)
        XCTAssertEqual(result.map(\.id), [2, 3, 1])
    }

    func testUpcomingNearby_maxThreeResults() {
        let now = makeDate(weekday: 2, hour: 18, minute: 0)
        let meetings = (1...5).map { i in
            Meeting.fixture(id: i, weekday: 2, startTime: "19:0\(i):00")
        }
        let result = upcomingNearby(from: meetings, location: nil, now: now)
        XCTAssertEqual(result.count, 3)
    }

    func testUpcomingNearby_virtualHasNilDistance() {
        let now = makeDate(weekday: 2, hour: 19, minute: 0)
        let virtual = Meeting.fixture(weekday: 2, startTime: "19:30:00", venueType: 2,
                                      latitude: 45.5, longitude: -122.6)
        let location = CLLocation(latitude: 45.52, longitude: -122.67)
        let result = upcomingNearby(from: [virtual], location: location, now: now)
        XCTAssertEqual(result.count, 1)
        XCTAssertNil(result[0].distanceMiles)
    }

    func testUpcomingNearby_inPersonHasDistance() {
        let now = makeDate(weekday: 2, hour: 19, minute: 0)
        let meeting = Meeting.fixture(weekday: 2, startTime: "19:30:00", venueType: 1,
                                      latitude: 45.5231, longitude: -122.6765)
        let userLoc = CLLocation(latitude: 45.5051, longitude: -122.6750)
        let result = upcomingNearby(from: [meeting], location: userLoc, now: now)
        XCTAssertEqual(result.count, 1)
        XCTAssertNotNil(result[0].distanceMiles)
    }
}

// MARK: - Fixture helper

extension Meeting {
    static func fixture(
        id: Int = 1,
        weekday: Int = 2,
        startTime: String = "19:00:00",
        venueType: Int = 1,
        latitude: Double? = 45.5231,
        longitude: Double? = -122.6765
    ) -> Meeting {
        Meeting(
            id: id,
            name: "Test Meeting",
            weekday: weekday,
            startTime: startTime,
            duration: "01:00:00",
            locationName: "Test Location",
            street: "123 Main St",
            city: "Portland",
            zip: "97201",
            virtualLink: nil,
            virtualInfo: nil,
            formats: [],
            serviceBodyId: 1155,
            venueType: venueType,
            latitude: latitude,
            longitude: longitude
        )
    }
}

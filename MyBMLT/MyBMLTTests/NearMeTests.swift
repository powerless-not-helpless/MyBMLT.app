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

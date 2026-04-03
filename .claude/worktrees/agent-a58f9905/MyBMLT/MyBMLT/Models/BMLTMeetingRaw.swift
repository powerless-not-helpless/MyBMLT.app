import Foundation

struct BMLTResponse: Codable {
    let meetings: [BMLTMeetingRaw]
}

struct BMLTMeetingRaw: Codable {
    let id_bigint: String?
    let meeting_name: String?
    let weekday_tinyint: String?
    let start_time: String?
    let duration_time: String?
    let location_text: String?
    let location_street: String?
    let location_municipality: String?
    let location_postal_code_1: String?
    let virtual_meeting_link: String?
    let virtual_meeting_additional_info: String?
    let service_body_bigint: String?
    let formats: String?
    let venue_type: String?
    let latitude: String?
    let longitude: String?

    func toMeeting() -> Meeting? {
        guard
            let idStr = id_bigint,
            let id    = Int(idStr),
            let name  = meeting_name, !name.isEmpty,
            let wdStr = weekday_tinyint,
            let wd    = Int(wdStr)
        else { return nil }

        let formatList = formats?
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) } ?? []

        return Meeting(
            id:                   id,
            name:                 name,
            weekday:              wd,
            startTime:            start_time ?? "",
            duration:             duration_time ?? "",
            locationName:         location_text ?? "",
            street:               location_street ?? "",
            city:                 location_municipality ?? "",
            zip:                  location_postal_code_1 ?? "",
            virtualLink:          virtual_meeting_link,
            virtualInfo:          virtual_meeting_additional_info,
            formats:              formatList,
            serviceBodyId:        Int(service_body_bigint ?? "") ?? 0,
            venueType:            Int(venue_type ?? "") ?? 1,
            latitude:             Double(latitude ?? ""),
            longitude:            Double(longitude ?? "")
        )
    }
}

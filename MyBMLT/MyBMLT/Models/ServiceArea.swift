import Foundation

struct ServiceArea: Identifiable, Hashable {
    let id: Int
    let fullName: String
    let shortName: String

    static let all: [ServiceArea] = [
        ServiceArea(id: 1156, fullName: "Beach Area",               shortName: "Beach"),
        ServiceArea(id: 1157, fullName: "Central Area",             shortName: "Central"),
        ServiceArea(id: 1158, fullName: "Habla Hispana Area",       shortName: "Hispana"),
        ServiceArea(id: 1159, fullName: "Imperial Valley Area",     shortName: "Imperial Valley"),
        ServiceArea(id: 1161, fullName: "North Coastal Area",       shortName: "N. Coastal"),
        ServiceArea(id: 1162, fullName: "North County Inland Area", shortName: "N. County Inland"),
        ServiceArea(id: 1163, fullName: "South East Barrio Area",   shortName: "SEBANA"),
        ServiceArea(id: 1164, fullName: "South Bay Area",           shortName: "South Bay"),
        ServiceArea(id: 1165, fullName: "United East County Area",  shortName: "UEC"),
    ]
}

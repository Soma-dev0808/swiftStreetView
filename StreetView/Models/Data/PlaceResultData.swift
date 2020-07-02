
import Foundation

struct PlaceResultData: Decodable {
    let results: [Results]
    
    struct Results: Decodable {
        let business_status: String?
        let geometry: Location
        let icon: String?
        let name: String?
        let place_id: String?
        let plus_code: Plus_code?
        var distance: Double?
    }
    
    struct Location: Decodable {
        let location: LatLng?
    }
    
    struct LatLng: Decodable {
        let lat : Double?
        let lng : Double?
    }
    
    struct Plus_code: Decodable {
        let compound_code: String?
        let global_code: String?
    }
}

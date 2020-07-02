import Foundation
import RealmSwift
import GoogleMaps

class FavoritePlace: Object {
    @objc dynamic var country: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var placeId: String = ""
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var dateCreated: Date?
}

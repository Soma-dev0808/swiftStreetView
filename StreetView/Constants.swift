
struct NameConst {
    static let transportation: [String] = [ "Airport", "Train Station", "Bus Station" ]
    static let joySpot: [String] = [ "Cafe", "Bar", "Restaurant", "Shopping Mall" ]
    
    static let lang_trans: [String: String] = ["title": "Find near transportation", "message" : "Choose prefer transportation"]
    static let lang_joy: [String: String] = ["title": "Find near spot", "message" : "Choose prefer spot type"]
    
    static let searchKeyDict: [String: String] = [
        "Airport": "airport",
        "Train Station" : "train_station",
        "Bus Station": "bus_station",
        "Cafe": "cafe",
        "Bar" : "bar",
        "Restaurant": "restaurant",
        "Shopping Mall": "shopping_mall"
    ]
 
    static let cancel: String = "Cancel"
}

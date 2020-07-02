import UIKit
import GoogleMaps

struct BottomMenu {
    private let isTransportation: Bool
    private let optionArray: [String]
    private let lang: [String: String]
    private let action: (_ coordinate:CLLocationCoordinate2D, _ searchKey: String) -> ()
    private let coordinate: CLLocationCoordinate2D
    
    init(isTransportation: Bool,
         coordinate: CLLocationCoordinate2D,
         action: @escaping (_ coordinate:CLLocationCoordinate2D, _ searchKey: String) -> ()) {
        self.isTransportation = isTransportation
        self.lang = isTransportation ? NameConst.lang_trans : NameConst.lang_joy
        self.optionArray = isTransportation ? NameConst.transportation : NameConst.joySpot
        self.action = action
        self.coordinate = coordinate
    }
        
    func createAlert() -> UIAlertController {
        
        let alert = UIAlertController(title: lang["title"], message: lang["message"], preferredStyle: .actionSheet)
                
        for option in optionArray {
            let menuAction = UIAlertAction(title: option, style: .default) { (a) in
                self.action(self.coordinate, option)
            }
            alert.addAction(menuAction)
        }
        
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (a) in
            return
        }

        alert.addAction(cancel)


        return alert
    }
}

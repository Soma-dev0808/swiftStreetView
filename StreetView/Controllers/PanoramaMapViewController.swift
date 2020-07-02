import UIKit
import GoogleMaps
import RealmSwift

protocol PanoramaMapViewDelegate {
    func set2DMapCoordinate(_ panoramaMapViewController: PanoramaMapViewController, selected2DCoordinate: CLLocationCoordinate2D)
}

class PanoramaMapViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var panoramaView: GMSPanoramaView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var transButton: UIButton!
    @IBOutlet weak var joySpotButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    let realm = try! Realm()
    
    var delegate: PanoramaMapViewDelegate?
    
    var coordinate: CLLocationCoordinate2D?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        panoramaView.delegate = self

        laodMap()
        loadButtonUI()
        
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: createBackButton())
    }
        
    //MARK: - move view to selected coordinate
    func laodMap() {
        guard let locationCordinate = coordinate else { fatalError("Cordinate is nill") }
                
        panoramaView.moveNearCoordinate(locationCordinate)

        // Create a marker at the selected location
        let position = locationCordinate
        addmarker(at: position)
    }
    
    //MARK: - Add marker to the usr's current location when user access to this page
    func addmarker(at position: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: position)
        marker.panoramaView = panoramaView
    }
    
    //MARK: - Button UI
    func loadButtonUI() {
        
        favButton.layer.cornerRadius = 0.5 * transButton.bounds.size.width
        favButton.layer.shadowColor = UIColor.black.cgColor
        favButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        favButton.layer.shadowRadius = 5
        favButton.layer.shadowOpacity = 0.6
        
        transButton.layer.cornerRadius = 0.5 * transButton.bounds.size.width
        transButton.layer.shadowColor = UIColor.black.cgColor
        transButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        transButton.layer.shadowRadius = 5
        transButton.layer.shadowOpacity = 0.6
        
        joySpotButton.layer.cornerRadius = 0.5 * joySpotButton.bounds.size.width
        joySpotButton.layer.shadowColor = UIColor.black.cgColor
        joySpotButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        joySpotButton.layer.shadowRadius = 5
        joySpotButton.layer.shadowOpacity = 0.6

        addButton.layer.cornerRadius = 0.5 * addButton.bounds.size.width
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        addButton.layer.shadowRadius = 5
        addButton.layer.shadowOpacity = 0.6
        
        favButton.isHidden = true
        transButton.isHidden = true
        joySpotButton.isHidden = true
        addButton.isHidden = true
    }
    
    //MARK: - Create back button
    func createBackButton() -> UIButton{
        let backButtonImage = UIImage(named: "backArrow")
        let backButton = UIButton(type: .custom)
        backButton.setImage(backButtonImage, for: .normal)
        backButton.titleLabel?.text = "test"
        backButton.addTarget(self, action: #selector(self.backButtonPressed), for: .touchUpInside)
        return backButton
    }
    
    @objc func backButtonPressed() {
        self.delegate?.set2DMapCoordinate(self, selected2DCoordinate: coordinate!)
        navigationController?.popViewController(animated: true)
    }
        
    //MARK: - Button to display modal
    @IBAction func transButtonPressed(_ sender: UIButton) {
        
        guard let safecoordinate = coordinate else { fatalError("Coordinate is nil") }
        
        let bottomMenu = BottomMenu(isTransportation: true, coordinate: safecoordinate) { (coordinate, searchKey) in
            
            let placeSuggestViewController = PlaceSuggestViewController(targetCoordinate: coordinate, searchKey: NameConst.searchKeyDict[searchKey]!)
            
            placeSuggestViewController.delegate = self
            
            self.presentPanModal(placeSuggestViewController)
        }
        
        present(bottomMenu.createAlert(), animated: true, completion: nil)
    }
    
    // Button to display modal
    @IBAction func joySpotButtonPressed(_ sender: UIButton) {
        
        guard let safecoordinate = coordinate else { fatalError("Coordinate is nil") }

        let bottomMenu = BottomMenu(isTransportation: false, coordinate: safecoordinate) { (coordinate, searchKey) in
            
            let placeSuggestViewController = PlaceSuggestViewController(targetCoordinate: coordinate, searchKey: NameConst.searchKeyDict[searchKey]!)
            
            placeSuggestViewController.delegate = self
            
            self.presentPanModal(placeSuggestViewController)
        }
        
        present(bottomMenu.createAlert(), animated: true, completion: nil)
    }
    
    //MARK: - Show hidden button
    @IBAction func addButtonPressed(_ sender: UIButton) {
        toggleButtons()
    }
    
    // animation for showing hidden button
    func toggleButtons() {
        
        joySpotButton.isHidden = !joySpotButton.isHidden

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.transButton.isHidden = !self.transButton.isHidden
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.favButton.isHidden = !self.favButton.isHidden
        }
    }
    
    //MARK: - add location to favorite places list
    @IBAction func favButtonPressed(_ sender: UIButton) {
        if let saveCoordinate = coordinate {
            let geoCoder = GMSGeocoder()
            
            // Converting coordinate into address or something place information
            geoCoder.reverseGeocodeCoordinate(saveCoordinate) { (response, error) in
                if let e = error { print(e) }
                
                guard let res = response?.firstResult(),
                let country = res.country,
                let address = res.lines
                else {fatalError("Couldn't convert place info")}

                let favPlace = FavoritePlace()
                favPlace.country = country
                favPlace.address = address.joined(separator: "\n")
                favPlace.latitude = saveCoordinate.latitude
                favPlace.longitude = saveCoordinate.longitude
                favPlace.placeId = Helper.randomString(length: 8)
                favPlace.dateCreated = Date()
                
                let alert = AlertModel(title: "Do favorite", message: "Do you want to save this place info?", buttonTitle: "Yes") {
                     do {
                         try self.realm.write {
                             self.realm.add(favPlace)
                         }
                     }
                     catch {
                         print("Error!!")
                     }
                 }
                
                self.present(alert.createAlert(withCancel: true), animated: true, completion: nil)
            }
        }
    }
    
}

//MARK: - GMSPanoramaViewDelegate
extension PanoramaMapViewController: GMSPanoramaViewDelegate {
    
    func panoramaViewDidFinishRendering(_ panoramaView: GMSPanoramaView) {
        addButton.isHidden = false
    }
        
    func panoramaView(_ view: GMSPanoramaView, didMoveTo panorama: GMSPanorama, nearCoordinate coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
    
    func panoramaView(_ view: GMSPanoramaView, error: Error, onMoveNearCoordinate coordinate: CLLocationCoordinate2D) {
        
        let invalidLocationAlert = AlertModel(
                                        title: "Location Error",
                                        message: "Seems your selected location is invalid",
                                        buttonTitle: "OK") {
                                            self.navigationController?.popViewController(animated: true)
                                        }
    
        present(invalidLocationAlert.createAlert(), animated: true, completion: nil)
    }
}

//MARK: - SuggestedPlaceDelegate
extension PanoramaMapViewController: SuggestedPlaceDelegate {
    
    func setSelectedLocationCoordinate(_ placeSuggestViewController: PlaceSuggestViewController, selectedCoordinate: CLLocationCoordinate2D) {
        self.delegate?.set2DMapCoordinate(self, selected2DCoordinate: selectedCoordinate)
        navigationController?.popViewController(animated: true)
    }
}

import UIKit
import GoogleMaps
import GooglePlaces

class Map2DViewController: UIViewController {

    @IBOutlet weak var labelParent: UIView!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var exploreButton: UIButton!
    @IBOutlet weak var loadingAddressIndicator: UIActivityIndicatorView!
    
    var coordinate: CLLocationCoordinate2D?
    var marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(false, animated: true)

        mapView.delegate = self
        locationManager.delegate = self

        adjustUI()
        // Move user to the selected location
        setMapDetail()
    }
        
    
    func adjustUI() {
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapFunction(_:)))
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector((longPressFunctin(_:))))
        
        addressLabel.isUserInteractionEnabled = true
        addressLabel.addGestureRecognizer(longPress)
        addressLabel.addGestureRecognizer(tap)
        
        addressLabel.numberOfLines = 0
        addressLabel.layer.masksToBounds = true
        addressLabel.layer.cornerRadius = 5
        
        labelParent.layer.cornerRadius = 5
        labelParent.layer.shadowColor = UIColor.black.cgColor
        labelParent.layer.shadowOffset = CGSize(width: 0, height: 5)
        labelParent.layer.shadowRadius = 5
        labelParent.layer.shadowOpacity = 0.3
        
        exploreButton.layer.cornerRadius = 5
        exploreButton.layer.shadowColor = UIColor.black.cgColor
        exploreButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        exploreButton.layer.shadowRadius = 5
        exploreButton.layer.shadowOpacity = 0.6
        
        let buttonHeight = self.exploreButton.frame.size.height
        let topInset = self.view.safeAreaInsets.top
        
        self.mapView.padding = UIEdgeInsets(
          top: topInset,
          left: 0,
          bottom: buttonHeight + 90,
          right: 0)
        
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    //MARK: - Setting up mapdetail
    func setMapDetail() {
        checkUserLocationService()
        setMarkerAtSelectedLocation()
    }
    
    func checkUserLocationService() {
        if CLLocationManager.locationServicesEnabled() {
          locationManager.requestLocation()
          mapView.isMyLocationEnabled = true
          mapView.settings.myLocationButton = true
        } else {
          locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setMarkerAtSelectedLocation() {
        
        guard let selectedLocation = coordinate else {
            fatalError("Coordinate is nil")
        }
        
        marker = GMSMarker(position: selectedLocation)
        marker.map = mapView
        mapView.camera = GMSCameraPosition(
          target: selectedLocation,
          zoom: 15,
          bearing: 0,
          viewingAngle: 0)
    }
    
    //MARK: - gestures
    
    // tap to open auto complete search modal
    @objc func tapFunction(_ gestureRecognizer: UITapGestureRecognizer) {
        addressLabel.becomeFirstResponder()

        let gacController = GMSAutocompleteViewController()
        gacController.delegate = self

        if self.traitCollection.userInterfaceStyle == .dark {
            gacController.tableCellBackgroundColor = .darkGray
        }
        present(gacController, animated: true, completion: nil)
    }

    // long press to copy current address
    @objc func longPressFunctin(_ gestureRecognizer: UILongPressGestureRecognizer) {
        addressLabel.becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            menu.showMenu(from: addressLabel, rect: addressLabel.bounds)
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = addressLabel.text
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    //MARK: - Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let destinationVC = segue.destination as! PanoramaMapViewController

        guard let currentCoordinate = coordinate else { fatalError("Coordinate is nil") }

        destinationVC.coordinate = currentCoordinate
        destinationVC.delegate = self
    }

    @IBAction func exploreButtonPressed(_ sender: UIButton) {
        
        guard let currentCoordinate = coordinate else { fatalError("Coordinate is nil") }

        if CLLocationCoordinate2DIsValid(currentCoordinate) {
            performSegue(withIdentifier: "goToPanprama", sender: self)
        }
        else {
            let invalidLocationAlert = AlertModel(
                                        title: "Invalid coordinate",
                                        message: "Your picked locaiton is invalid",
                                        buttonTitle: "Okay") { return }
            present(invalidLocationAlert.createAlert(), animated: true, completion: nil)
        }
    }
    
}

// MARK: - CLLocationManagerDelegate
extension Map2DViewController: CLLocationManagerDelegate {
    
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    guard status == .authorizedWhenInUse else { return }
    locationManager.requestLocation()
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    print("User location + \(location)")
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print(error)
  }
}

// MARK: - GMSMapViewDelegate
extension Map2DViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        // Update address label
        converToAddress(with: position.target)
        
        // update current position being focused
        coordinate = position.target
        
        // Update explore button ui
        exploreButton.isEnabled = true
        exploreButton.backgroundColor = UIColor(named: "CommonButtonColor")
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        // Update marker position at center
        marker.position = position.target
                
        // Update explore button ui
        exploreButton.isEnabled = false
        exploreButton.backgroundColor = UIColor(named: "CommonButtonColor")
        
        // Show loading indicator
        loadingAddressIndicator.isHidden = false
        addressLabel.text = ""
    }
    
    func converToAddress(with coordinate: CLLocationCoordinate2D) {
        
        let geoCoder = GMSGeocoder()
        
        geoCoder.reverseGeocodeCoordinate(coordinate) { (response, error) in
            if let e = error {print(e)}
            
            guard
                let address = response?.firstResult(),
                let lines = address.lines
                else {
                    let noCooordinateAlert = AlertModel(title: "Coordinate not found", message: "Sorry something wrong went with your pressed item, please try it again", buttonTitle: "OK") {
                        self.navigationController?.popViewController(animated: true)
                    }
                    return self.present(noCooordinateAlert.createAlert(), animated: true, completion: nil)
                }
            
            self.addressLabel.text = lines.joined(separator: "\n")
            self.loadingAddressIndicator.isHidden = true
        }
    }
    
}

//MARK: - PanoramaMapViewDelegate
extension Map2DViewController: PanoramaMapViewDelegate {
    func set2DMapCoordinate(_ panoramaMapViewController: PanoramaMapViewController, selected2DCoordinate: CLLocationCoordinate2D) {
        coordinate = selected2DCoordinate
        setMapDetail()
    }
    
    
}

//MARK: - GMSAutocompleteViewControllerDelegate
extension Map2DViewController: GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        coordinate = place.coordinate
        dismiss(animated: true, completion: nil)
        setMapDetail()
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}

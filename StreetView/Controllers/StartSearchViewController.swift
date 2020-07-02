
import UIKit
import GooglePlaces

class StartSearchViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var startSearchButton: UIButton!
    @IBOutlet weak var favLocationButton: UIButton!
    
    //Allow app to use user location
    let locationManager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined
        {
           locationManager.requestWhenInUseAuthorization()
        }
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        startSearchButton.layer.cornerRadius = 5
        startSearchButton.layer.shadowColor = UIColor.black.cgColor
        startSearchButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        startSearchButton.layer.shadowRadius = 5
        startSearchButton.layer.shadowOpacity = 0.3
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // Show search place modal
    @IBAction func searchLocation(_ sender: UIButton) {
        let gacController = GMSAutocompleteViewController()
        gacController.delegate = self
        if self.traitCollection.userInterfaceStyle == .dark {
            gacController.tableCellBackgroundColor = .darkGray
        }
        present(gacController, animated: true, completion: nil)
    }
    
    // Segue to favorite locations list
    @IBAction func favButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToFavList", sender: self)
    }
    
}

//MARK: - GMSAutocompleteViewControllerDelegate
extension StartSearchViewController: GMSAutocompleteViewControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goTo2DMap" {
            let destinationVC = segue.destination as! Map2DViewController
            destinationVC.coordinate = coordinate
        }
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        coordinate = place.coordinate
        dismiss(animated: true, completion: nil)
        performSegue(withIdentifier: "goTo2DMap", sender: self)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}


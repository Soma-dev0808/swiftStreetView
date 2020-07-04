

import UIKit
import GoogleMaps
import PanModal

// Data back to Panorama view controller
protocol SuggestedPlaceDelegate {
    func setSelectedLocationCoordinate(_ placeSuggestViewController: PlaceSuggestViewController, selectedCoordinate: CLLocationCoordinate2D)
}

class PlaceSuggestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private var tableView: UITableView = UITableView()
    private let headerView:UIView = UIView()
    private let label: UILabel = UILabel()
    private let spinner = SpinnerViewController()
    
    var targetCoordinate: CLLocationCoordinate2D?
    var searchKey: String?
    
    var delegate: SuggestedPlaceDelegate?
    
    var locationList: PlaceResultData? {
        didSet {
            loadTable()
        }
    }
    
    //MARK: -  Initialize VC using passed coordinate and searchkey which load near locations
    init(targetCoordinate: CLLocationCoordinate2D, searchKey: String) {
        self.targetCoordinate = targetCoordinate
        self.searchKey = searchKey
        super.init(nibName: nil, bundle: nil)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up table view manually
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 500)
        tableView.register(UINib(nibName: "SuggestedPlaceTableViewCell", bundle: nil), forCellReuseIdentifier: "suggestedCell")
        self.view.addSubview(tableView)

        // Do http request to fetch near locations using set coordinate and searchkey
        fetchPlaces()
        displaySpinner()
    }
    
    override func viewDidLayoutSubviews() {
        label.text = "Suggested Places"
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14)
        label.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        headerView.addSubview(label)
        headerView.backgroundColor = .white
        tableView.sectionHeaderHeight = 40
    }
    
    //MARK: -  Refresh table view
    func loadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.removeSpinner()
            
            // Handling the case when no lcation was found
            if self.locationList?.results.count ?? 0 <= 0 {
                let noLocationsAlert = AlertModel(title: "No location", message: "Oops.. no location found...", buttonTitle: "OK") {
                    self.dismiss(animated: true, completion: nil)
                }
                self.present(noLocationsAlert.createAlert(), animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - Fetch locations
    func fetchPlaces() {
        guard let coordinate = targetCoordinate, let key = searchKey else { fatalError("coordinate or search key are nil") }
        let fetchLocationModel = FetchLocationModel(coordinate: coordinate, searchKey: key)
        
        fetchLocationModel.fetchNearPlace { (result, error) in
            if let e = error { print(e) }
            else {
                if let res = result {
                    // Once data is set, table view will be updated
                    self.locationList = res
                }
            }
        }
    }
    
    //MARK: - Spinner
    func displaySpinner() {
         // add the spinner view controller
         addChild(spinner)
         spinner.view.frame = tableView.frame
         tableView.addSubview(spinner.view)
         spinner.didMove(toParent: self)
    }
    
    func removeSpinner() {
        // then remove the spinner view controller
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
        
    //MARK: - Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationList?.results.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // Add custom header
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // This cell is inherited by SuggestedPlaceTableViewCell(Use Xib)
        let cell = tableView.dequeueReusableCell(withIdentifier: "suggestedCell", for: indexPath) as! SuggestedPlaceTableViewCell
        if let fetchResult = locationList {
            let result = fetchResult.results[indexPath.row]
            cell.locationNameLabel.text = result.name
            cell.countryLabel.text = FetchLocationModel.convertCountryInfo(with: result)
            cell.businessStatusLabell.text =  result.business_status
            
            if let lat = result.geometry.location?.lat, let lng = result.geometry.location?.lng {
                
                let firstLocaiton = CLLocation(latitude: targetCoordinate!.latitude, longitude: targetCoordinate!.longitude)
                let secondLocaiton = CLLocation(latitude: lat, longitude: lng)
                let distance = DistanceCalculator().calDistance(firstLocation: firstLocaiton, secondLocaiton: secondLocaiton)
                cell.distanceLabel.text = DistanceCalculator().convertDistanceKm(distance: distance)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let fetchResult = locationList {
            
            let goToLocationAlert = AlertModel(title: "Check this location?", message: "Do you want to check this location?", buttonTitle: "Yes") {
                
                guard let latitude = fetchResult.results[indexPath.row].geometry.location?.lat, let longitude = fetchResult.results[indexPath.row].geometry.location?.lng else {return print("invalid lat or long")}
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                
                self.dismiss(animated: true) {
                    // At the completion of closing modal, set coordinate of the selected item
                    self.delegate?.setSelectedLocationCoordinate(self, selectedCoordinate: coordinate)
                }
            }
            
            present(goToLocationAlert.createAlert(withCancel: true), animated: true, completion: nil)
        }

    }

}

//MARK: - PanModalPresentable (Configuring panmodal)
extension PlaceSuggestViewController: PanModalPresentable {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var longFormHeight: PanModalHeight {
        return .contentHeight(500)
    }
    
    var anchorModalToLongForm: Bool {
        return false
    }
    
}

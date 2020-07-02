import UIKit
import GoogleMaps
import RealmSwift
import SwipeCellKit

// Custom cell
class FavPlaceCell: SwipeTableViewCell {
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
}

// This page is showing favorite locaitons user added
class FavoritePlaceTableViewController: UITableViewController, SwipeTableViewCellDelegate {

    let realm = try! Realm()
    
    var favPlace: Results<FavoritePlace>? {
        didSet {
            updateTable()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)

        favPlace = realm.objects(FavoritePlace.self)
    }
    
    // Checking if any data is stored. If no data set user will be redirect back to previous page
    func updateTable() {
        if favPlace?.count == 0 {
            let noFavPlaceAlert = AlertModel(title: "No favorite places found", message: "Please add favorite place in Panorama map page.", buttonTitle: "ok") {
                self.navigationController?.popViewController(animated: true)
            }
            present(noFavPlaceAlert.createAlert(), animated: true, completion: nil)
        }
        else {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favPlace?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "favPlaceCell", for: indexPath) as! FavPlaceCell
        
        cell.delegate = self

        cell.countryLabel.text = favPlace?[indexPath.row].country
        cell.countryLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
        cell.addressLabel?.text = favPlace?[indexPath.row].address
        cell.addressLabel?.font = UIFont(name:"HelveticaNeue", size: 13.0)
        cell.countryLabel.numberOfLines = 0
        cell.addressLabel?.numberOfLines = 0

        return cell
    }
    
    
    //MARK: - Setting up for swipe view
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        // Disable swipe from left to right
        guard orientation == .right else {return nil}
        
        // When user swipe right to left, try to delete swiped item
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            
            // Without this cell delete action automatically triggered
            action.fulfill(with: .reset)
            let alert = AlertModel(title: "Delete item?", message: "Do you want to delete this item?", buttonTitle: "Yes") {
                if let item = self.favPlace?[indexPath.row] {
                    do {
                        try self.realm.write {
                            self.realm.delete(item)
                            self.tableView.reloadData()
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            }
            self.present(alert.createAlert(withCancel: true), animated: true, completion: nil)
        }
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    
    //MARK: - segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! Map2DViewController
        
        if let saveData = favPlace, let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.coordinate = CLLocationCoordinate2D(latitude: saveData[indexPath.row].latitude, longitude: saveData[indexPath.row].longitude)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToMapFromFav", sender: self)
    }
}

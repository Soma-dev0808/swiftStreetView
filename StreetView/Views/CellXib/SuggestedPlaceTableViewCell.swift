import UIKit

class SuggestedPlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var businessStatusLabell: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        locationNameLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 15.0)
        locationNameLabel.text = ""
        
        countryLabel.text = ""
        countryLabel.font = UIFont(name:"HelveticaNeue", size: 13.0)
        
        businessStatusLabell.text = ""
        businessStatusLabell.font = UIFont(name:"HelveticaNeue", size: 13.0)
        
        distanceLabel.text = ""
        distanceLabel.font = UIFont(name:"HelveticaNeue", size: 13.0)

        locationNameLabel.numberOfLines = 0
        countryLabel.numberOfLines = 0
        businessStatusLabell.numberOfLines = 0
        distanceLabel.numberOfLines = 0
            
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

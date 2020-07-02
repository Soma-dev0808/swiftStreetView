import UIKit

struct AlertModel {
    private let title: String
    private let message: String
    private let buttonTitle: String
    private let action: () -> ()
    
    init(title: String, message: String,buttonTitle: String, action: @escaping () -> ()) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    func createAlert(withCancel cencel: Bool = false) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: buttonTitle, style: .cancel) { (a) in
            self.action()
        }
        
        if(cencel) {
            let cencelAction = UIAlertAction(title: "cancel", style: .default) { (a) in
                return
            }
            alert.addAction(cencelAction)
        }
        
        alert.addAction(alertAction)
        return alert
    }
}

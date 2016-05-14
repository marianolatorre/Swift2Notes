

import UIKit
import Stormpath

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func login(sender: AnyObject) {
        // Code when someone presses the login button
        Stormpath.sharedSession.login(emailTextField.text!, password: passwordTextField.text!, completionHandler: openNotes)
        
    }
    
    @IBAction func loginWithFacebook(sender: AnyObject) {
        // Code when someone presses the login with Facebook button
        
    }
    
    @IBAction func loginWithGoogle(sender: AnyObject) {
        // Code when someone presses the login with Google button
        
    }

    @IBAction func resetPassword(sender: AnyObject) {
        // Code when someone presses the reset password button
        
    }
    
    func openNotes(success: Bool, error: NSError?) {
        if let error = error {
            showAlert(withTitle: "Error", message: error.localizedDescription)
        }else{
            performSegueWithIdentifier("login", sender: self)
        }
    }
}

// Helper extension to display alerts easily.
extension UIViewController {
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}
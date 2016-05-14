

import UIKit
import Stormpath

class NotesViewController: UIViewController {
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .keyboardWasShown, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: .keyboardWillBeHidden, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showName()
        self.retrieveNotes()
    }
    
    func showName(){
        Stormpath.sharedSession.me {
            [unowned self]
            (account, error) -> Void in
            
            if let account = account {
                self.helloLabel.text = "Hello \(account.fullName)?"
            }
        }
    }
    
    func retrieveNotes () {
        let notesEndpoint = NSURL(string: "https://stormpathnotes.herokuapp.com/notes")!
        let request = NSMutableURLRequest(URL: notesEndpoint)
        request.setValue("Bearer \(Stormpath.sharedSession.accessToken!)", forHTTPHeaderField: "Authorization")
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            guard let data = data, json = try? NSJSONSerialization.JSONObjectWithData(data, options: []), notes = json["notes"] as? String else {
                return
            }
            dispatch_async(dispatch_get_main_queue(), {
                self.notesTextView.text = notes
            })
        }
        task.resume()
    
    }
    
    func saveNote(){
        let postBody = ["notes": notesTextView.text]
        
        let notesEndpoint = NSURL(string: "https://stormpathnotes.herokuapp.com/notes")!
        let request = NSMutableURLRequest(URL: notesEndpoint)
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(postBody, options: [])
        request.setValue("application/json" ?? "", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Stormpath.sharedSession.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request)
        task.resume()
    
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        Stormpath.sharedSession.logout()
        
        // Code when someone presses the logout button
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        if let keyboardRect = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
            notesTextView.contentInset = UIEdgeInsetsMake(0, 0, keyboardRect.size.height, 0)
            notesTextView.scrollIndicatorInsets = notesTextView.contentInset
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        notesTextView.contentInset = UIEdgeInsetsZero
        notesTextView.scrollIndicatorInsets = UIEdgeInsetsZero
    }
}

extension NotesViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        // Add a "Save" button to the navigation bar when we start editing the 
        // text field.
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: .stopEditing)
    }
    
    func stopEditing() {
        // Remove the "Save" button, and close the keyboard.
        navigationItem.rightBarButtonItem = nil
        notesTextView.resignFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        // Code when someone exits out of the text field
        
        self.saveNote()
    }
}

private extension Selector {
    static let keyboardWasShown = #selector(NotesViewController.keyboardWasShown(_:))
    static let keyboardWillBeHidden = #selector(NotesViewController.keyboardWillBeHidden(_:))
    static let stopEditing = #selector(NotesViewController.stopEditing)
}
//
//  ComposeController.swift
//  Book-Tracker
//
//  Created by Anders Berntsen on 28/05/2019.
//  Copyright © 2019 Anders Berntsen. All rights reserved.
//

import UIKit
import Firebase


class ComposeController: UIViewController {
    
    var ref: DatabaseReference!
    var UserID = UIDevice.current.identifierForVendor?.uuidString
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var authorField: UITextField!
    @IBOutlet weak var pagesField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initial setup
        self.navigationController?.navigationBar.tintColor = UIColor.black
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }
    
    //TextField funtions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.titleField.resignFirstResponder()
        self.authorField.resignFirstResponder()
        self.pagesField.resignFirstResponder()
        return true
    }
    
    @IBAction func post(_ sender: Any) {
        postToDatabase()
        self.dismiss(animated: true, completion: nil);
    }
    
    func postToDatabase() {
        
        //Sets the input fields as usable variables
        let title: String = titleField.text!
        let author: String = authorField.text!
        let pages: Int = Int(pagesField.text!)!
        
        //Posts the fields to the database
        self.ref.child(UserID!).child("MyBooks").childByAutoId().updateChildValues(["title": title, "author": author, "pages": pages, "isRead": false, "progress": 0])
        
        //Clears the text in the text fields
        titleField.text = ""
        authorField.text = ""
        pagesField.text = ""
        
        //show alert when posted to Database for better UX
        let alertController = UIAlertController(title: "", message: "Your book has been added", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            alertController.dismiss(animated: true, completion: nil)
        }
    }
}

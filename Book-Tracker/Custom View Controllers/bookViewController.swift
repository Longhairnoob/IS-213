//
//  bookViewController.swift
//  Book-Tracker
//
//  Created by Anders Berntsen on 28/05/2019.
//  Copyright © 2019 Anders Berntsen. All rights reserved.
//

import UIKit
import Firebase

class bookViewController: UIViewController, UITextFieldDelegate {
    
    var bookID: String?
    var ref:DatabaseReference!
    let UserID = UIDevice.current.identifierForVendor?.uuidString
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var totalTextField: UITextField!
    @IBOutlet weak var userInputTextField: UITextField!
    @IBOutlet weak var totalPages: UILabel!
    
    struct Book {
        var title: String
        var author: String
        var isRead: Bool
        var progress: Float
        var pages: Double
    }
    
    var currentBook: Book?
    var newProgress: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initial setup
        ref = Database.database().reference()
        userInputTextField.delegate = self
        
        //fetches the current book, and updates GUI elements with the correct information
        ref.child(UserID!).child("MyBooks").child(bookID!).observeSingleEvent(of: .value, with: { (snapshot) in
            var dictionary = snapshot.value as? [String: AnyObject] ?? [:]
            self.currentBook = Book.init(title: (dictionary["title"] as! String), author: (dictionary["author"] as! String), isRead: (dictionary["isRead"] as! Bool), progress: (dictionary["progress"] as! Float), pages: (dictionary["pages"] as! Double))
            
            self.navigationController?.title = self.currentBook?.title
            self.progressView.progress = (self.currentBook?.progress)!
            self.totalPages.text = "\(String(describing: (self.currentBook?.pages)!))"
            
        })
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateProgress()
        userInputTextField.resignFirstResponder()
        return true
    }
    
    func updateProgress() {
        if let userInput = Double(userInputTextField.text!) {
            print(userInput)
            print(self.currentBook?.pages)
            newProgress = userInput / (self.currentBook?.pages)!

            progressView.progress = Float(newProgress)
            ref.child(UserID!).child("MyBooks").child(bookID!).updateChildValues(["progress" : newProgress])
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
//  OverviewController.swift
//  Book-Tracker
//
//  Created by Anders Berntsen on 05/04/2019.
//  Copyright © 2019 Anders Berntsen. All rights reserved.
//

import UIKit
import Firebase

class OverviewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var bookArray = [Book]()
    let UserID = UIDevice.current.identifierForVendor?.uuidString
    
    struct Book {
        var title: String
        var author: String
        var isRead: Bool
        var progress: Double
        var bookKey: String
    }
    
    var ref:DatabaseReference!
    
    // sets up Pull to Refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //initiall delegation
        ref = Database.database().reference()
        tableView.delegate = self
        tableView.dataSource = self
        
        //GUI setup
        self.tableView.rowHeight = 100.0
        self.tableView.addSubview(self.refreshControl)
        self.navigationController?.navigationBar.tintColor = UIColor.black
        
        appendBooks()
        self.tableView.reloadData()
    }
    
    //database call to fetch added books
    func appendBooks() {
        self.ref.child(UserID!).child("MyBooks").observe(.childAdded) { (snapshot) in
            
            var dictionary = snapshot.value as? [String: AnyObject] ?? [:]
            let bookKey = snapshot.key
            self.bookArray.append(Book.init(title: (dictionary["title"] as! String), author: (dictionary["author"] as! String), isRead: (dictionary["isRead"] as! Bool), progress: (dictionary["progress"] as! Double), bookKey: bookKey))
        }
    }
    
    //tableview functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookCell", for: indexPath) as! BookCell
        
        cell.bookTitle.text = bookArray[indexPath.row].title
        cell.bookAuthor.text = bookArray[indexPath.row].author
        cell.bookProgress.progress = Float(bookArray[indexPath.row].progress)
        cell.bookImage.image = UIImage(named: "book")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //sets the book key value equal to the current key when selecting row
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! bookViewController
        vc.bookID = bookArray[self.tableView.indexPathForSelectedRow!.row].bookKey
    }
    
    //refresh function
    @objc func refresh() {
        
        let when = DispatchTime.now() + 0.2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.appendBooks()
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
}

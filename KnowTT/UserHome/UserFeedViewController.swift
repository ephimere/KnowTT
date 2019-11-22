//
//  feedView.swift
//  KnowTT
//
//  Created by CK on 26/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit

class UserFeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var myNoteList = ["Note 1", "Note 2","Note 3","Note 4","Note 5","Note 6","Note 7","Note 8","Note 9","Note 10","Note 11","Note 12","Note 13","Note 14"]
    

    
    var selectedNote = ""
    
    var noteRefresher: UIRefreshControl!
    
    @IBOutlet weak var PullUpToRefreshTabTitle: UINavigationItem!
    @IBOutlet weak var noteTable: UITableView!
    
    
    @IBOutlet var tabBarIconFeed: UITabBarItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarIconFeed.badgeValue = "\(myNoteList.count)"
        noteRefresher = UIRefreshControl()
        //noteRefresher.attributedTitle = NSAttributedString(string: "⬆️ Pull to refresh ⬆️")
        noteRefresher.addTarget(self , action: #selector(UserFeedViewController.populateTable), for: UIControl.Event.valueChanged)
        
        noteTable.addSubview(noteRefresher)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (myNoteList.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = myNoteList[indexPath.row]//Moving down array displaying our List
        return cell
    }
    
    //This function works when user selects a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = myNoteList[indexPath.row]
        performSegue(withIdentifier: "goToNoteDetailedView", sender: self)
    }

    
    
    //Function is called each time user edits tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete
        {
            myNoteList.remove(at: indexPath.row)
            noteTable.reloadData()
        }
    }
    
    //This function handles
    @objc func populateTable (){
        PullUpToRefreshTabTitle.title = "Loading Knowts"
        for i in 1...1000
        {
            myNoteList.append("\(i)")
        }
        PullUpToRefreshTabTitle.title = "Pull Up to Refresh"
        noteTable.reloadData()
        noteRefresher.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = myNoteList[indexPath.row]
    }
    
}

//
//  UserFeedViewControllerTableViewController.swift
//  KnowTT
//
//  Created by Cris Gomez Lopez on 22/11/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit

class UserFeedViewControllerTableViewController: UITableViewController {

    var notesArray:[Int] = [1,2,3]
    var refresher: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(UserFeedViewControllerTableViewController.populate), for: UIControl.Event.valueChanged)
        tableView.addSubview(refresher)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notesArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(notesArray[indexPath.row])
        return cell
    }
    
    @objc func populate(){
        for i in 1 ... 1000{
            notesArray.append(i)
        }
        
        tableView.reloadData()
        refresher.endRefreshing()
        
    }
}

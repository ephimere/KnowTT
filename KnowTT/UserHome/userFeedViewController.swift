//
//  userFeedViewController.swift
//  KnowTT
//
//  Created by Cris Gomez Lopez on 26/11/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit

class userFeedViewController: UIViewController {

    @IBOutlet weak var distanceSliderLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    var note = ["nota 1", "nota 2", "nota 3", "nota 4", "nota 5"]
    var user = ["user 1", "user 2", "user 3", "user 4", "user 5"]
    var distance = [1, 2, 3, 4, 5]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func distanceSliderValueChanged(_ sender: Any) {
        distanceSliderLabel.text = "Distance: \(Int(distanceSlider.value)) Km"
    }
}

extension userFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return note.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CellTableViewCell
        cell.user.text = user[indexPath.row]
        cell.noteContent.text = note[indexPath.row]
        cell.distance.text = "\(distance[indexPath.row]) Km away"
        return cell
    }
}

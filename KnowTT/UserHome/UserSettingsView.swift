//
//  UserSettingsView.swift
//  KnowTT
//
//  Created by CK on 27/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import SCLAlertView
import JGProgressHUD

class UserSettingsView: UIViewController {
    
    
    @IBOutlet weak var logOutButton: UIButton!

    
    override func viewDidLoad(){
        super.viewDidLoad()
        logOutButton.layer.cornerRadius = 15
    }
    
     @IBAction func logOutTapped(_ sender: Any) {
        //Loader
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Logging out..."
        hud.show(in: self.view)
        // Logout from Firebase
        try! Auth.auth().signOut()
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "startView")
            self.present(vc, animated: true, completion: nil)
        }
        hud.dismiss()
     }
    
    
}

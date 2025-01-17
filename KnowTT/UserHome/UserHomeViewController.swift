//
//  UserHomeViewController.swift
//  KnowTT
//
//  Created by CK on 17/02/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import MapKit
import SCLAlertView
import JGProgressHUD
import Geofirestore

struct GetNoteDecodedStruct: Codable {
    var creationTime: String
    var latitude: Double
    var longitude: Double
    var message: String
    var userId: String?
}

struct PostNoteDecodedStruct: Codable {
    var latitude: String
    var longitude: String
    var message: String
    var userId: String
}

struct ACKPostNoteDecodedStruct: Codable {
    var opCode: String
    var result: String
}

class UserHomeViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var tcpLog: UITextField!//This is for testing
    @IBOutlet weak var userLoggedInText: UILabel!
    @IBOutlet weak var userMap: MKMapView!
    
    //GET database reference
    let db = Firestore.firestore()
    
    //LOCATION MANAGER
    let coordinatesManager = CLLocationManager()
    
    var userMail = Auth.auth().currentUser!.email
    var userDefault = "user unknown"

    //Timer to call datbase every X seconds to retrieve nearby notes
    var myTimer = Timer()
    
    
    //Prepare to change status bar color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.style
    }
    var style:UIStatusBarStyle = .default
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
       self.style = .lightContent
    }
    override func viewDidLoad() {
        //Change status bar color
        self.style = .lightContent
        //Ask user to start tracking his position
        self.coordinatesManager.requestAlwaysAuthorization()
        //if the user allows, set the delegate to the same coordinatesManager
        if CLLocationManager.locationServicesEnabled(){
            coordinatesManager.delegate = self
            coordinatesManager.desiredAccuracy = kCLLocationAccuracyBest
            coordinatesManager.startUpdatingLocation()
        }

        //Change welcome message based on user name/email
        userLoggedInText.text = "Welcome \(userMail ?? userDefault) !"
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.tintColor = #colorLiteral(red: 0.9932168126, green: 0.6548400521, blue: 0.0002115537791, alpha: 1)
    }
    
    @IBAction func goToLogOut(_ sender: Any) {
        self.performSegue(withIdentifier: "goToLogOut", sender: self)
    }




    
    @IBAction func refreshNotes(_ sender: Any) {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Refreshing Notes..."
        hud.show(in: self.view)
        updateCloseByNotes()
        hud.dismiss()
    }
    
    @IBAction func addNoteTouched(_ sender: Any) {
        //Get locations from user
        let coordinate =  CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "LAT") as! CLLocationDegrees, longitude: UserDefaults.standard.value(forKey: "LON") as! CLLocationDegrees)
        let userLatitudeCoord = coordinate.latitude
        let userLongitudeCoord = coordinate.longitude
        let userLongitude = "\(userLongitudeCoord)"
        let userLatitude = "\(userLatitudeCoord)"
        //1. Create the alert controller.
        let alert = UIAlertController(title: "New KnowT", message: "Latitude: \(userLatitude)\nLongitude: \(userLongitude)", preferredStyle: .alert)
        //2. Add the text field
        alert.addTextField { (textField) in
            textField.placeholder = "Your note goes here"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler:{(action) in alert.dismiss(animated: true, completion: nil)}))
        // 3. Grab the value from the text field, and SEND IT TO SERVER
        
        // Add a new document with a generated ID
        
        
        
        alert.addAction(UIAlertAction(title: "Add Note", style: .default, handler:
        {
            
            [weak alert] (_) in
            let userInputForNote = alert?.textFields![0] // This is the user note
            if(userInputForNote == nil){
                SCLAlertView().showWarning("Could not post your note", subTitle: "Write something")
            }
            do {
                //save note under a collection dedicated for notes from posting user
                var ref: DocumentReference? = nil
                ref = self.db.collection("users").document("\(self.userMail!)").collection("notes").addDocument(data: [
                    "textNote": userInputForNote!.text!,
                    "Latitude": userLatitude,
                    "Longitude": userLongitude
                ])
                { err in
                    if err != nil {
                        SCLAlertView().showError("Could not post your note", subTitle: "Please try again in a few minutes")
                    } else {
                        //Give a geofireLocarion to our document using reference
                        let geoFirestoreRef = self.db.collection("users").document("\(self.userMail!)").collection("notes")
                        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
                        geoFirestore.setLocation(location: CLLocation(latitude: (self.coordinatesManager.location?.coordinate.latitude)!, longitude: (self.coordinatesManager.location?.coordinate.latitude)!), forDocumentWithID: "\(ref!.documentID)") { (error) in
                                if (error != nil) {
                                    print("An error occured: \(String(describing: error))")
                                } else {
                                    print("Saved location successfully!")
                                }
                            }
                        //save in collection of notes
                        let date = Date()
                        
                        var notesRef: DocumentReference? = nil
                        notesRef = self.db.collection("notes").addDocument(data: [
                            "user:": "\(self.userMail!)",
                            "textNote": userInputForNote!.text!,
                            "day": Calendar.current.component(.day, from: date),
                            "month": Calendar.current.component(.month, from: date),
                            "year": Calendar.current.component(.year, from: date),
                            "hour": Calendar.current.component(.hour, from: date),
                            "minute": Calendar.current.component(.minute, from: date),
                            "second": Calendar.current.component(.second, from: date)
                        ])
                        { err in
                            if err != nil {
                                SCLAlertView().showError("Could not post your note", subTitle: "Please try again in a few minutes")
                            } else {
                                //Give a geofireLocarion to our document
                                let geoFirestoreRef = self.db.collection("notes")
                                let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
                                geoFirestore.setLocation(location: CLLocation(latitude: (self.coordinatesManager.location?.coordinate.latitude)!, longitude: (self.coordinatesManager.location?.coordinate.longitude)!), forDocumentWithID: "\(notesRef!.documentID)") { (error) in
                                        if (error != nil) {
                                            print("An error occured: \(String(describing: error))")
                                        } else {
                                            print("succesfully added location to note in notes collection under home directory")
                                        }
                                    }
                                
                                SCLAlertView().showSuccess("Posted", subTitle: "ID: \(ref!.documentID)")
                            }
                        }
                    }
                }
            }
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
   /*
     func saveNoteUnderUser(underUser user:String, withNote note:String) -> String{
        var ref: DocumentReference? = nil
        ref = self.db.collection("users").document(user).collection("notes").addDocument(data: [
           "textNote": note
        ])
        return "\(ref!)"
    }
    
     func saveNoteUnderUserGeographically(underUser user:String, toCollection collection:String, atLocation loc:CLLocation, withNote note:String){
        let ref = saveNoteUnderUser(underUser: user, withNote: note)
        let geoFirestoreRef = self.db.collection("users").document("\(self.userMail!)").collection("notes")
        let geoFirestore = GeoFirestore(collectionRef: geoFirestoreRef)
        geoFirestore.setLocation(location: CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.latitude), forDocumentWithID: ref) { (error) in
                if (error != nil) {
                    print("An error occured: \(String(describing: error))")
                } else {
                    print("Saved location successfully!")
                }
            }
        
    }
    
     func saveNoteInCollectionNotesGeographically(toCollection collection:String, atLatitude latitude:CLLocation, atLongitude longitude:CLLocation){
        <#function body#>
    }*/
    
    private func pinNote(withText note:String,  inLatitude latitude: Double, inLongitud longitude: Double){
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = userMail
        annotation.subtitle = note
        userMap.addAnnotation(annotation)
    }

    //Track the user position in real time and display it on the map
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Update User Location
        let userLocation = locations.last
        let viewRegion = MKCoordinateRegion(center: (userLocation?.coordinate)!, latitudinalMeters: 100, longitudinalMeters: 100)
        self.userMap.setRegion(viewRegion, animated: true)
        self.userMap.showsUserLocation = true
        
        /* create a 3D Camera --UNCOMMENT THIS TO GET A 3D CAMERA VIEW
        let mapCamera = MKMapCamera()
        mapCamera.centerCoordinate = (locations.last?.coordinate)!
        mapCamera.pitch = 60
        mapCamera.altitude = 125 // example altitude
        mapCamera.heading = 0
        
        // set the camera property
        self.userMap.camera = mapCamera*/
        
        //Save current lat & long
        UserDefaults.standard.set(userLocation?.coordinate.latitude, forKey: "LAT")
        UserDefaults.standard.set(userLocation?.coordinate.longitude, forKey: "LON")
        UserDefaults().synchronize()
    
    }
    func scheduledTimerWithTimeInterval(){
              print("[SCHEDULED TIMER WITH INTERVAL]")
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        myTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(UserHomeViewController.updateCloseByNotes), userInfo: nil, repeats: true)
    }
    @objc func updateCloseByNotes(){
        print("[UPDATE CLOSE BY NOTES]")
        let number = Int.random(in: 0 ..< 100)
        
        //Request notes when user is moving
        //Get userId
        let userId = "\(userMail!)"
        
        //MARK-- Reload Notes when user is moving
        let noteRequest = UserNote()
        //Get location data
        let coordinate =  CLLocationCoordinate2D(latitude: UserDefaults.standard.value(forKey: "LAT") as! CLLocationDegrees, longitude: UserDefaults.standard.value(forKey: "LON") as! CLLocationDegrees)//Get last location saved.
        let userLatitudeCoord = coordinate.latitude
        let userLongitudeCoord = coordinate.longitude
        let userLongitude = "\(userLongitudeCoord)"
        let userLatitude = "\(userLatitudeCoord)"
        //1.Build  the note
        noteRequest.buildNote("GET", userId, userLatitude, userLongitude, "")
    }
    
    func pinNoteAndCheckForMore(fromStringJson json: String) -> Bool{
        
        //put json in required format for decoder
        let jsonData = Data(json.utf8)
        //create decoder
        let decoder = JSONDecoder()
        var moreNotes = true
        
        do {
            print("\t[pinNoteAndCheckForMore]")
            //Initialize Struct to save data
            let ackJsonDecoded = try decoder.decode(GetNoteDecodedStruct.self, from: jsonData)
            print("\t repsonse decoded")
            //Check if we have final end marking note
            if(ackJsonDecoded.message == "[END]"){
                print("\t [END] in get operation RECEIVED")
                moreNotes = false
            }else{//If there are more notes...
                //Get location from note
                
                self.pinNote(withText: ackJsonDecoded.message, inLatitude: ackJsonDecoded.latitude, inLongitud: ackJsonDecoded.longitude)
            }
        }catch {
            print(error.localizedDescription)
            moreNotes = false
            return moreNotes
        }
        return moreNotes
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToLogOut"){
            let userSettingsController  = segue.destination as?  UserSettingsView
        }
    }
}




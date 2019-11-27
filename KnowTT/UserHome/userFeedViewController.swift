//
//  userFeedViewController.swift
//  KnowTT
//
//  Created by Cris Gomez Lopez on 26/11/2019.
//  Copyright © 2019 CK. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import MapKit
import Firebase
import FirebaseDatabase
import Geofirestore

class userFeedViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var distanceSliderLabel: UILabel!
    @IBOutlet weak var distanceSlider: UISlider!
    
    //Variables to handle user location
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000
    //Variables to handle user queries to get nearby notes
    var db: Firestore!
    var dbRef: DatabaseReference!
    var notesRef: CollectionReference!
    var center: CLLocation!
    var geoFirestore: GeoFirestore!
    var keys: NSMutableDictionary = NSMutableDictionary()
    var lastlocation: CLLocation!
    //var noteDistances: Array<Note> = Array<Note>()
    
    
    
    //DELETE THIS AFTER RECEIVING NOTES
    var note = ["nota 1", "nota 2", "nota 3", "nota 4", "nota 5"]
    var user = ["user 1", "user 2", "user 3", "user 4", "user 5"]
    var distance = [1, 2, 3, 4, 5]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup of firebase and geofire
        db = Firestore.firestore()
        notesRef = db.collection("notes")
        geoFirestore = GeoFirestore(collectionRef: self.notesRef)
        dbRef = Database.database().reference()
        //Set up location manager services if allowed
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        #warning("Check location services(Look AroundHere code)")
    }

    @IBAction func distanceSliderValueChanged(_ sender: Any) {
        distanceSliderLabel.text = "Distance: \(Int(distanceSlider.value)) Km"
    }
    
    //this function is called everytime the user moves
    /*
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.lastlocation = locations.last
        if let userid = Auth.auth().currentUser {
            
            #warning("updating firebase with new location... maybe remove this?")
            //dbRef.child("notes").child(userid.uid).child("coordenates").updateChildValues(["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude])
            
            //creating a geopoint for the new location
            //var loc = GeoPoint.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            //Updating the current users location in the firestore database
            self.geoFirestore.setLocation(geopoint: GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), forDocumentWithID: (Auth.auth().currentUser?.email)!) { (error) in
                if (error != nil) {
                    print("An error occured")
                } else {
                    print("Saved location successfully!")
                    //center of the radious to search
                    self.center = CLLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    //query the database
                    self.keys.removeAllObjects()
                    let circleQuery = self.geoFirestore.query(withCenter: self.center, radius: 50)
                    _ = circleQuery.observeReady {
                        _ = circleQuery.observe(.documentEntered, with: { (key, location) in
                            print("The document with documentID '\(key)' ENTERED the search area and is at location '\(location)'")
                            self.keys.setValue(location as Any, forKey: key!)
                            self.noteDistances.removeAll()
                            self.noteDistances = self.noteDistances(keys: self.keys)
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    */
     #warning("Maybe delete")
    func centerUserInMap() {
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //Update User Location
        let userLocation = locations.last
        //Save current lat & long
        UserDefaults.standard.set(userLocation?.coordinate.latitude, forKey: "LAT")
        UserDefaults.standard.set(userLocation?.coordinate.longitude, forKey: "LON")
        UserDefaults().synchronize()
    }
    
    @IBAction func updateNearbyNotes(_ sender: Any) {
        print("Saved location successfully!")
        print("\(String(describing: self.locationManager.location?.coordinate.latitude))");
        //center of the radious to search
        
        self.center = CLLocation(latitude: (self.locationManager.location?.coordinate.latitude)!, longitude: (self.locationManager.location?.coordinate.longitude)!)
        //query the database
        //self.keys.removeAllObjects()
        // Create a GeoCollection reference
       let noteGeoLocationsRef = self.db.collection("users").document("\(Auth.auth().currentUser!.email!)").collection("notes")
    print("\(noteGeoLocationsRef)")
        print("\(Auth.auth().currentUser!.email!)")
       let noteGeoLocations = GeoFirestore(collectionRef: noteGeoLocationsRef)
       let circleQuery = noteGeoLocations.query(withCenter: center, radius: 10)    // Create a GeoQuery based on a location
       circleQuery.observeReady {
            print("All initial data has been loaded and events have been fired!")
            let queryHandle = circleQuery.observe(.documentEntered, with: { (key, location) in
                print("The document with documentID '\(key)' entered the search area and is at location '\(location)'")
            })
            print("After query handle")
        }
        
       
        
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

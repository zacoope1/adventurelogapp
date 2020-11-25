//
//  LocationDetailsViewController.swift
//  AdventureLog
//
//  Created by Zachary Cooper on 11/1/20.
//

import Foundation
import UIKit
import MapKit

class LocationDetailsViewController: UIViewController {

    // Constants for the ui
    let VISITED_MESSAGE = "You have visited here!";
    let NOT_VISITED_MESSAGE = "You haven't visited here!";
    let VISITED_BUTTON = "Mark As Visited";
    let NOT_VISITED_BUTTON = "Mark As Not Visited";
    
    var location: Location? = nil;
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var displayModeSwitch: UISwitch!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var photos: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var visitedLabel: UILabel!
    @IBOutlet weak var visitedButton: UIButton!
    @IBOutlet weak var notesArea: UITextView!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var unlikeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        switchMode(self);
        toggleLikeButton();
        self.photos.image = UIImage(named: "Food.jpeg");
        name.text = location?.name;
        address.text = location?.address;
        
        if location?.notes != nil{
            notesArea.text = location?.notes;
        }
        
        if location?.visited != nil {
            if location?.visited == "yes" {
                visitedLabel.text = VISITED_MESSAGE;
            }
            else {
                visitedLabel.text = NOT_VISITED_MESSAGE;
            }
        }
        else {
            visitedLabel.text = NOT_VISITED_MESSAGE;
        }
        
        handleGeo();
        
    }
    
    @IBAction func switchMode(_ sender: Any) {
        if displayModeSwitch.isOn{
            photos.isHidden = true;
            addPhotoButton.isHidden = true;
            map.isHidden = false;
            address.isHidden = false;
            copyButton.isHidden = false;
            
            
        }
        else {
            photos.isHidden = false;
            addPhotoButton.isHidden = false;
            map.isHidden = true;
            address.isHidden = true;
            copyButton.isHidden = true;
        }
    }
    @IBAction func copyToClipboard(_ sender: Any) {
        
        UIPasteboard.general.string = address.text;
        
    }
    
    @IBAction func changePhoto(){
        print("Change Photo");
    }
    
    @IBAction func addPhotoAction(_ sender: Any) {
        //TODO ADD POPUP
    }
    
    func toggleLikeButton(){
        if location?.liked == true {
            self.likeButton.isHidden = true;
            self.unlikeButton.isHidden = false;
        }
        else {
            self.likeButton.isHidden = false;
            self.unlikeButton.isHidden = true;
        }
    }
    
    @IBAction func performLikeAction(_ sender: Any) {
        location?.liked = !(location!.liked);
        toggleLikeButton();
    }
    
    @IBAction func updateLog(_ sender: Any) {
        if notesArea.text != nil{
            self.location?.notes = notesArea.text!;
        }
    }
    
    @IBAction func markAsVisited(_ sender: Any) {
        
        if location?.visited != nil {
            if location?.visited == "yes"{
                location?.visited = "no";
            }
            else {
                location?.visited = "yes";
            }
        }
        else {
            location?.visited = "yes";
        }
 
        if location?.visited == "yes" {
            visitedLabel.text = VISITED_MESSAGE;
        }
        else {
            visitedLabel.text = NOT_VISITED_MESSAGE;
        }
    }
    
    func handleGeo(){
        CLGeocoder().geocodeAddressString(location!.address!, completionHandler: {(placemarks, error) in
            if error != nil {
                
                if self.location?.longitude != nil && self.location?.latitude != nil {
                    
                    let coords = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.location!.latitude), longitude: CLLocationDegrees(self.location!.longitude));
                    let span = MKCoordinateSpan.init(latitudeDelta: 0.0025, longitudeDelta: 0.0025);
                    
                    //Locate and set region
                    let region = MKCoordinateRegion(center: coords, span: span);
                    
                    // Create and set Marker
                    let marker: MKPointAnnotation = MKPointAnnotation();
                    marker.coordinate = coords;
                    marker.title = self.location?.name;
                    self.map.addAnnotation(marker);
                    
                    self.map.setRegion(region, animated: true);
                }
                
            }
            else if placemarks!.count > 0 {
                // Get Placemarks
                let placemark = placemarks![0];
                let location = placemark.location;
                let coords = location?.coordinate;
                let span = MKCoordinateSpan.init(latitudeDelta: 0.0025, longitudeDelta: 0.0025);
                
                //Locate and set region
                let region = MKCoordinateRegion(center: coords!, span: span);
                
                // Create and set Marker
                let marker: MKPointAnnotation = MKPointAnnotation();
                marker.coordinate = coords!;
                marker.title = self.location?.name;
                self.map.addAnnotation(marker);
                
                self.map.setRegion(region, animated: true);
            }
            else{
                if self.location?.longitude != nil && self.location?.latitude != nil {
                    
                    let coords = CLLocationCoordinate2D(latitude: CLLocationDegrees(self.location!.latitude), longitude: CLLocationDegrees(self.location!.longitude));
                    let span = MKCoordinateSpan.init(latitudeDelta: 0.0025, longitudeDelta: 0.0025);
                    
                    //Locate and set region
                    let region = MKCoordinateRegion(center: coords, span: span);
                    
                    // Create and set Marker
                    let marker: MKPointAnnotation = MKPointAnnotation();
                    marker.coordinate = coords;
                    marker.title = self.location?.name;
                    self.map.addAnnotation(marker);
                    
                    self.map.setRegion(region, animated: true);
                }
            }
        })
    }
    
}

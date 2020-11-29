//
//  GeneratorViewController.swift
//  AdventureLog
//
//  Created by Zachary Cooper on 11/1/20.
//

import Foundation
import UIKit

class GeneratorViewController: UIViewController {
    
    var searchLocations: [Location]? = nil;
    var savedLocations: [Location]? = nil;
    
    @IBOutlet weak var haveVisitedSwitch: UISwitch!
    @IBOutlet weak var haveSavedSwitch: UISwitch!
    @IBAction func toggleSaved(_ sender: Any) {
        if haveSavedSwitch.isOn == false{
            haveVisitedSwitch.isOn = false;
        }
    }
    @IBAction func toggleVisited(_ sender: Any) {
        if haveSavedSwitch.isOn == false {
            haveVisitedSwitch.isOn = false;
        }
    }
    
    func findFood() -> Location? {
        if haveSavedSwitch.isOn  && savedLocations!.count > 0 {
            let whichArr = Int.random(in: 0...1);
            if haveVisitedSwitch.isOn {
                if whichArr == 0 {
                    let number = Int.random(in: 0...searchLocations!.count - 1);
                    return searchLocations![number];
                }
                else {
                    let number = Int.random(in: 0...savedLocations!.count - 1);
                    return savedLocations![number];
                }
            }
            else {
                var unvisitedPlaces:[Location] = [];
                for x in savedLocations! {
                    if x.visited == "no" {
                        unvisitedPlaces.append(x);
                    }
                }
                let whichArr = Int.random(in: 0...1);
                if whichArr == 0 {
                    let number = Int.random(in: 0...searchLocations!.count - 1);
                    return searchLocations![number];
                }
                else {
                    let number = Int.random(in: 0...unvisitedPlaces.count - 1);
                    return unvisitedPlaces[number];
                }
            }
        }
        else {
            if searchLocations!.count > 0 {
                let number = Int.random(in: 0...searchLocations!.count - 1);
                return searchLocations![number];
            }
            else {
                return nil
            }
        }
    }

    
    override func prepare(for seg: UIStoryboardSegue, sender: Any?) {
        if seg.identifier == "toDetailsFromGenerator" {
            if let vc = seg.destination as? LocationDetailsViewController {
                vc.location = findFood();
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

}

//
//  LocationList.swift
//  AdventureLog
//
//  Created by Zachary Cooper on 11/1/20.
//

import Foundation;

class LocationList {
    
    var Locations: [Location];
    
    init(){
        self.Locations = [Location]();
    }
    
    func getLocations() -> [Location]{
        return self.Locations;
    }
    
    func add(loc: Location){
        self.Locations.append(loc);
    }
    
    func delete(loc: Location){
        
        if self.Locations.contains(loc) {
            if let index = Locations.firstIndex(where: {$0.yelpBusinessId == loc.yelpBusinessId}){
                Locations.remove(at: index);
            }
        }
        
    }
    
    func update(loc: Location, yelpBusinessId: String){
        
        if self.Locations.count > 0{
            for x in 0...(self.Locations.count - 1) {
                if Locations[x].yelpBusinessId == yelpBusinessId {
                    self.Locations[x] = loc;
                }
            }
        }
        
    }
    
    func contains(loc: Location) -> Bool {
        
        for x in self.Locations{
            if x.yelpBusinessId == loc.yelpBusinessId {
                return true;
            }
        }
        
        return false;
    }
    
    func size() -> Int {
        return self.Locations.count;
    }
    
}

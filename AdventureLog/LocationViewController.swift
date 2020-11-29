//
//  ViewController.swift
//  AdventureLog
//
//  Created by Zachary Cooper on 10/31/20.
//

import UIKit
import CoreData
import CoreLocation

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    let YELP_API_AUTHORIZATION_HEADER = "Bearer qu3k-y909KY2xCG-a4TZfOloGUktuyWoHq9kyGukPaxzSEyCLyil6RIfElU0vk_rdHBptITc4lc5HNf45u3iLxINKUg3449qL0E8_PJKvkQGAbC9oNOreMJNBau9X3Yx";
    let YELP_API_ENDPOINT = "https://api.yelp.com/v3/businesses/search"; // MUST ADD "?" for params
    
    var CURRENT_LOCATION: CLLocation?;
    var locationManager:CLLocationManager = CLLocationManager();
    
    // TABLE MODE
    let EXPLORE_MODE = 0;
    let SAVED_MODE = 1;
    let SEARCH_BAR_MODE = 2;
    var TABLE_MODE:Int = 0; //Starts in explore
    // TABLE MODE
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if TABLE_MODE == EXPLORE_MODE{
//            print("Entries of searchLocations: " + String(searchLocations.size()));
            return searchLocations.size();
        }
        else {
//            print("Entries of savedLocations: " + String(savedLocations.size()));
            return savedLocations.size();
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell;
        
        if TABLE_MODE == EXPLORE_MODE{
//            print("Setting cells for searchLocations");
            let loc = searchLocations.getLocations()[indexPath.row];
            cell.loc = loc;
            cell.name.text = loc.name;
            cell.type.text = loc.type;
            cell.city.text = loc.city;
        }
        else {
//            print("Setting cells for savedLocations");
            let loc = savedLocations.getLocations()[indexPath.row];
            cell.loc = loc;
            cell.name.text = loc.name;
            cell.type.text = loc.type;
            cell.city.text = loc.city;
        }
        
        return cell;
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if TABLE_MODE == SAVED_MODE{
            return true;
        }
        else {
            return false;
            
        }
    
    }
    
    private func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if TABLE_MODE == SAVED_MODE {
            syncUnlike(loc: savedLocations.getLocations()[indexPath.row]);
            savedLocations.delete(loc: savedLocations.getLocations()[indexPath.row]);
            saveLikesToCoreData();
        }
        
        self.Table.reloadData();
    }
    
    func syncUnlike(loc: Location){
        
        loc.liked = false;
        self.savedLocations.update(loc: loc, yelpBusinessId: loc.yelpBusinessId!);
        self.searchLocations.update(loc: loc, yelpBusinessId: loc.yelpBusinessId!);
        saveLikesToCoreData();
        
    }
    
    @IBOutlet weak var Table: UITableView!
    
    @IBOutlet weak var tableModeSelector: UISegmentedControl!
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var searchView: UIView!
    
    @IBOutlet weak var savedTableView: UITableView!
    
    @IBOutlet weak var searchBar: UITextField!
    
    let savedManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    let searchManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext;
    
    var savedLocations = LocationList();
    var searchLocations = LocationList();
    var searchBarLocations = LocationList();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MOCK
//        let mocklocation = Location(context: searchManagedObjectContext);
//        mocklocation.setValue("Sippy Sips Coffee", forKey: "name");
//        mocklocation.setValue("500 E University Dr, Tempe AZ, 85281", forKey: "address");
//        mocklocation.setValue("Tempe", forKey: "city");
//        mocklocation.setValue("Coffee", forKey: "type");
//        mocklocation.setValue(33.4255, forKey: "latitude");
//        mocklocation.setValue(-111.9400, forKey: "longitude");
//        mocklocation.setValue(false, forKey: "liked");
//        mocklocation.setValue("yelp-123", forKey: "yelpBusinessId");

//        let mocklocation2 = Location(context: savedManagedObjectContext);
//        mocklocation2.setValue("Star Wars Coffee", forKey: "name");
//        mocklocation2.setValue("123 Ez Street, Tempe, AZ 12345", forKey: "address");
//        mocklocation2.setValue("Tempe", forKey: "city");
//        mocklocation2.setValue("Coffee", forKey: "type");
//        mocklocation2.setValue(40.7128, forKey: "latitude");
//        mocklocation2.setValue(-74.0060, forKey: "longitude");
//        mocklocation2.setValue(true, forKey: "liked");
//        mocklocation2.setValue("yelp-234", forKey: "yelpBusinessId");

//        searchLocations.add(loc: mocklocation);
        //MOCK
        
        locationManager.delegate = self;
        
        print("Requesting location authorization");
        self.locationManager.requestWhenInUseAuthorization();
        
        if !(locationManager.authorizationStatus == .notDetermined || locationManager.authorizationStatus == .restricted || locationManager.authorizationStatus == .denied) {
            CURRENT_LOCATION = getCurrentLocation();
            self.savedLocations.Locations = getLikesFromCoreData();
            callYelpApi();
            Table.reloadData();
        }
        
        savedTableView.delegate = self;
        savedTableView.dataSource = self;
        
        self.setUpExploreMode();
        
    }
    
    func runAppSetup(){
        print("Running app setup!");
        
        CURRENT_LOCATION = getCurrentLocation();
    
        self.savedLocations.Locations = getLikesFromCoreData();
        
        savedTableView.delegate = self;
        savedTableView.dataSource = self;
        
        self.setUpExploreMode();
        
        print("App setup done!");
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        switch status{
        case .restricted, .denied:
            print("You chose to disable location! This app will not work without location.");
            exit(0);
            break;
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized!");
            runAppSetup();
            callYelpApi();
            Table.reloadData();
            break;
        case .notDetermined:
            print("Asking again!");
            self.locationManager.requestWhenInUseAuthorization();
            break;
        default:
            print("Asking again!");
            self.locationManager.requestWhenInUseAuthorization();
            break;
        
        }
    }

    
    override func prepare(for seg: UIStoryboardSegue, sender: Any?) {
        
        if seg.identifier == "toGenerator" {
            
        }
        else if seg.identifier == "toDetailsFromRandomGeneratorView"{
            
        }
        else if seg.identifier == "toDetailsFromLocationView"{
            
            let selectedIndex: IndexPath = self.Table.indexPath(for: sender as! UITableViewCell)!
            
            var loc: Location;
            
            if TABLE_MODE == EXPLORE_MODE {
                loc = searchLocations.Locations[selectedIndex.row];
            }
            else if TABLE_MODE == SEARCH_BAR_MODE {
                loc = searchBarLocations.Locations[selectedIndex.row];
            }
            else {
                self.TABLE_MODE = EXPLORE_MODE;
                loc = savedLocations.Locations[selectedIndex.row];
            }
            
            if let vc: LocationDetailsViewController = seg.destination as? LocationDetailsViewController{
                vc.location = loc;
            }
            
        }
        
    }
    
    @IBAction func passback(seg: UIStoryboardSegue){
        if seg.source is GeneratorViewController {
            
            
        }
        else if seg.source is LocationDetailsViewController {
            if seg.destination is LocationViewController {
                let src = seg.source as! LocationDetailsViewController;
                let loc = src.location;
                
                if loc?.liked == true {
                    if savedLocations.contains(loc: loc!){
                        savedLocations.update(loc: loc!, yelpBusinessId: loc!.yelpBusinessId!)
                        Table.reloadData();
                    }
                    else {
                        savedLocations.add(loc: loc!);
                        Table.reloadData();
                    }
                }
                else {
                    if savedLocations.contains(loc: loc!) {
                        savedLocations.delete(loc: loc!);
                        Table.reloadData();
                    }
                }
                
                saveLikesToCoreData();
                
                self.setUpExploreMode();
                
            }
            else if seg.destination is GeneratorViewController {
                
            }
        }
    }
    
    func getLikesFromCoreData() -> [Location]{
        
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location");
        
        var results = ((try? savedManagedObjectContext.fetch(fetch)) as? [Location])
        
        if results != nil {
            results = filterResults(res: results!);
            print("Returned \(results!.count) results from core data!");
            return results!
        }
        else {
            print("Fetched No Results");
            return [];
        }
    }
    
    func saveLikesToCoreData() {
        
        let lastMode = TABLE_MODE;
        
        setUpSavedMode();
        
        do {
            try savedManagedObjectContext.save();
        }
        catch is Error {
            
            print("Failed to save to core data.");
            
        }
        
        if lastMode == EXPLORE_MODE{
            setUpExploreMode();
        }
        
    }
    
    func filterResults(res: [Location]) -> [Location] {
        var temp:[Location] = [];
        if res.count > 0 {
            for x in res {
                if x.liked == true{
                    temp.append(x);
                }
            }
            return temp;
        }
        else {
            return [];
        }
    }
    
    func setUpExploreMode(){
        savedTableView.delegate = nil;
        savedTableView.dataSource = nil;
        searchTableView.delegate = self;
        searchTableView.dataSource = self;
        
        self.tableModeSelector.selectedSegmentIndex = 0;
        self.searchView.isHidden = false;
        self.searchTableView.isHidden = false;
        self.savedTableView.isHidden = true;
        Table = searchTableView;
        self.Table.reloadData();
    }
    
    func setUpSavedMode(){
        savedTableView.delegate = self;
        savedTableView.dataSource = self;
        searchTableView.delegate = nil;
        searchTableView.dataSource = nil;
        
        self.tableModeSelector.selectedSegmentIndex = 1;
        self.searchView.isHidden = false;
        self.searchTableView.isHidden = true;
        self.savedTableView.isHidden = false;
        Table = savedTableView;
        self.Table.reloadData();
    }
    
    @IBAction func switchTableMode(_ sender: Any) {
        
        if TABLE_MODE == EXPLORE_MODE {
            self.searchTableView = self.Table
            self.TABLE_MODE = SAVED_MODE;
//            print("Table Mode: Saved Mode");
            setUpSavedMode();
        }
        else if TABLE_MODE == SEARCH_BAR_MODE {
            self.TABLE_MODE = EXPLORE_MODE;
            self.Table.reloadData();
        }
        else {
            self.savedTableView = Table;
            self.TABLE_MODE = EXPLORE_MODE;
//            print("Table Mode: Explore Mode");
            setUpExploreMode();
        }
        
    }
    
    @IBAction func editingEnded(_ sender: Any) {
        if searchBar.text?.count == 0 && TABLE_MODE == SEARCH_BAR_MODE{
            self.switchTableMode(self);
        }
        
        
    }
    
    @IBAction func search(_ sender: Any) {
        if searchBar.text?.count == 0 && TABLE_MODE == SEARCH_BAR_MODE{
            self.switchTableMode(self);
        }
        
    }
    
    func getCurrentLocation() -> CLLocation? {
        
        if self.locationManager.authorizationStatus == .authorizedWhenInUse {
            print("Location is authorized!");
            locationManager.startUpdatingLocation();
            print(locationManager.location!);
            return self.locationManager.location;
        }
        else if self.locationManager.authorizationStatus == .denied || self.locationManager.authorizationStatus == .restricted {
            print("Location is not authorized! This app will not work properly. Please run a full reset on the app to be prompted for location authorization again!");
            let alert = UIAlertController(title: "location is not authorized", message: "Please run a full reset on the app to be prompted for location authorization again!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in NSLog("The \"OK\" alert occured.")}))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            print("Location not found!");
        }
        
        return nil;
    }
    
    func getSearchString(term:String, size:Int) -> String {
        var searchString = YELP_API_ENDPOINT + "?";
        
        searchString += "term=" + term;
        searchString += "&latitude=" + String((CURRENT_LOCATION?.coordinate.latitude)!);
        searchString += "&longitude=" + String((CURRENT_LOCATION?.coordinate.longitude)!);
        searchString += "&radius=40000";
        
        if size <= 50{
            searchString += "&limit=" + String(size);
        }
        else {
            searchString += "&limit=30";
        }

        return searchString;
    }
    
    func callYelpApi() {
        
        if CURRENT_LOCATION == nil {
            if (locationManager.authorizationStatus == .denied || locationManager.authorizationStatus == .restricted) {
                print("Location is nil. Returning empty list of locations.");
            }
        }
        
        let searchStringFood = URL(string: getSearchString(term: "food", size:30));
        doApiCall(URL: searchStringFood!, type: "Restaurant");
        
        let searchStringCoffee = URL(string: getSearchString(term: "coffee", size:20));
        doApiCall(URL: searchStringCoffee!, type: "Coffee and Tea");

        let searchStringBar = URL(string: getSearchString(term: "bar", size:20));
        doApiCall(URL: searchStringBar!, type: "Bar and Restaurant");
        
    }
    
    func doApiCall(URL: URL, type: String) {
        var arr:[Location] = [];
        print("Making Api call with string: " + URL.absoluteString);
        
        var session = URLSession.shared;
        var request = URLRequest(url: URL);
        request.setValue("application/json", forHTTPHeaderField: "Accept");
        request.setValue(YELP_API_AUTHORIZATION_HEADER, forHTTPHeaderField: "Authorization");

        let apiCall = session.dataTask(with: request, completionHandler: { [self] (data, res, err) in
            
            if err != nil{
                print("Error gathering restaurant data")
            }
            else if let data = data {
            
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary;
                
                let list = json!["businesses"] as! NSArray;
                
                for x in list {
                    
                    let obj = x as! [String: Any];
                    print(obj["name"] as! String);
                    
                    
                    var loc = Location(context: self.searchManagedObjectContext);
                    loc.name = obj["name"] as? String;
                    loc.yelpBusinessId = obj["id"] as? String;
                    let location = obj["location"] as? [String : Any];
                    let city = location!["city"] as? String;
                    loc.city = city;
                    let address = location!["display_address"] as? [String];
                    
                    if address != nil {
                        var addString = "";
                        for x in address! {
                            let arr = Array(x);
                            let a = "" + String(arr[0]) + String(arr[1]) + String(arr[2]) + String(arr[3]);
                            
                            if !a.elementsEqual("Ste ") && !a.elementsEqual("ste ") {
                                addString += x + " ";
                            }
                        }
                        loc.address = addString
                    }
                    else {
                        loc.address = "Address not found";
                    }
                    
                    
                    let coords = obj["coordinates"] as! [String : NSNumber];
                    loc.latitude = (coords["latitude"])?.floatValue ?? 0;
                    loc.longitude = (coords["longitude"])?.floatValue ?? 0;
                    loc.notes = "";
                    loc.liked = false;
                    loc.visited = "no";
                    loc.type = type;
                    loc.photos = Data();
                    self.searchLocations.add(loc: loc);
                    
                }
                
                
            }
            
        }).resume();
    }
    
    func processObject(){
        
    }
    
}


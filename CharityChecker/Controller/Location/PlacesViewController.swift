//
//  PlacesViewController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-19.
//  Copyright © 2018 CharityDonate. All rights reserved.
//
import GooglePlaces
import GoogleMaps
import UIKit

class PlacesViewController: UIViewController {
   
    @IBOutlet weak var tableView: UITableView!

    
    // An array to hold the list of possible locations.
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var selected : Bool = false
    var uniquePlace : [GMSPlace] = []
    
    // Cell reuse id (cells that scroll out of view can be reused).
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for places in likelyPlaces{
            var unique : Bool = true
            uniquePlace.forEach { (place) in
                if places.placeID == place.placeID || places.name == place.name{
                    unique = false
                    return
                }
            }
            if unique == true{
                uniquePlace.append(places)
            }
        }
        
        // Register the table view cell class and its reuse id.
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        // This view controller provides delegate methods and row data for the table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let nav = parent as! UINavigationController
        let vc = nav.childViewControllers[2] as! MapController
        vc.selectedPlace = selectedPlace
        vc.selected = selected
        print("moved")
    }
}

// Respond when a user selects a place.
extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPlace = uniquePlace[indexPath.row]
        print(selectedPlace)
        selected = true
    }
}


// Populate the table with the list of most likely places.
extension PlacesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return uniquePlace.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        let collectionItem = uniquePlace[indexPath.row]
        
        print("crated")
        cell.textLabel?.text = collectionItem.name
         
        return cell
    }
    
    // Adjust cell height to only show the first five items in the table
    // (scrolling is disabled in IB).
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.tableView.frame.size.height/8
    }
    
    // Make table rows display at proper height if there are less than 5 items.
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == tableView.numberOfSections - 1) {
            return 1
        }
        return 0
    }
}



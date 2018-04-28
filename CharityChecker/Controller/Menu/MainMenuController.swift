//
//  MainMenuController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-20.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class MainMenuController: UIViewController {

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var GetQRCodeButton: CheckButton!
    @IBOutlet weak var changeParameterButton: CheckButton!
    @IBOutlet weak var addBoxButton: CheckButton!
    @IBOutlet weak var withdrawButton: CheckButton!
    @IBOutlet weak var scanButton: CheckButton!
    @IBOutlet weak var notificationView: UITableView!
    
    
    let notificationArray : [String] = [String]()
    
    var withdraw : Bool = false
    var type : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Check for NOTIFICATIONS
        print(type)
        if type == "Charity"{
            
        }else if type == "Operator"{
            
        }
        updateUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(_ sender: CheckButton) {
        if sender.tag == 0{
            performSegue(withIdentifier: "goToGetQRCode", sender: self)
        }
        else if sender.tag == 1{
            performSegue(withIdentifier: "goToChangeParameter", sender: self)
        }
        else if sender.tag == 2 && type != "Charity"{
            withdraw = false
            performSegue(withIdentifier: "goToQRReader", sender: self)
        }
        else if sender.tag == 2 && type == "Charity"{
            performSegue(withIdentifier: "goToCreateDonationBox", sender: self)
        }
        else if sender.tag == 3{
            withdraw = true
            performSegue(withIdentifier: "goToQRReader", sender: self)
        }
        else if sender.tag == 4{
            performSegue(withIdentifier: "scanNewBox", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToChangeParameter"{
            let destinationVC = segue.destination as! ChangeParameterController
            destinationVC.type = type
        }
        if segue.identifier == "goToQRReader"{
            let destinationVC = segue.destination as! QRReaderController
            destinationVC.type = type
            print(type!)
            if withdraw == true{
                destinationVC.add = false
            }else{
                destinationVC.add = true
            }
        }
    }
    
    func updateUI(){
        typeLabel.text = type
        if type == "Operator"{
            scanButton.isHidden = true
        }
        else if type == "Owner"{
            notificationView.isHidden = true
            withdrawButton.isHidden = true
            typeLabel.frame.origin.y += 100
            GetQRCodeButton.frame.origin.y += 20
            changeParameterButton.frame.origin.y += 20
            addBoxButton.frame.origin.y += 20
            scanButton.isHidden = true
        }
        else if type == "Charity"{
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        withdraw = false
    }
}


extension MainMenuController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = notificationArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationArray.count
    }
}

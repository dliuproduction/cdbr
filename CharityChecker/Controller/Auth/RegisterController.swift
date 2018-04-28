//
//  RegisterController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-19.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import BigInt
import web3swift

class RegisterController: UIViewController {

    var type : String!

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!


    @IBOutlet weak var firstField: UITextField!
    @IBOutlet weak var secondField: UITextField!
    @IBOutlet weak var thirdField: UITextField!
    
    @IBOutlet var charityLabels: [UILabel]!
    @IBOutlet var charityField: [UITextField]!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!

    
    var address : String?
    var latitude : CLLocationDegrees?
    var longitude : CLLocationDegrees?
    
    let operatorTypeArray = ["Charity","Charity-Authorized","Unaffiliated Collector"]
    var operatorType : String  = ""
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstField.delegate = self
        secondField.delegate = self
        thirdField.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        updateUI(type: type)
        view.sendSubview(toBack: imageView)
        addressLabel.adjustsFontSizeToFitWidth = true
        
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleRegister(_ sender: UIButton) {
        
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
      
        var ks : EthereumKeystoreV3?
        ks = keystoreManager?.walletForAddress((keystoreManager?.addresses![0])!) as! EthereumKeystoreV3
        
        if type == "Charity"{
            //TO DO: RegistrationKey & Name
            let registrationKey = UInt(firstField.text!)
            let name = secondField.text
            
            guard let sender = ks?.addresses?.first else {return}
            
            let web3Rinkeby = Web3.InfuraRinkebyWeb3()
            web3Rinkeby.addKeystoreManager(keystoreManager)
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(10000000)
            options.from = ks?.addresses?[0]
            options.value = 0
            print("arrived")
            
            let platform = web3Rinkeby.contract(jsonString, at: contractAddress, abiVersion: 2)
            
            let parameters = [name!, registrationKey!] as [AnyObject]
            
            let error = platform?.method("createCharity", parameters: parameters, options: options)?.send(password: "Whocares").error
            
            if error == nil{
                performSegue(withIdentifier: "goToMainMenu", sender: self)
            }else{
                print(error)
            }
        }
        else if type == "Operator"{
            //TO DO: Name & Telephone & Type
            let name = secondField.text
            let telephone = UInt(thirdField.text!)
            let type = operatorType
            
            guard let sender = ks?.addresses?.first else {return}
            
            let web3Rinkeby = Web3.InfuraRinkebyWeb3()
            web3Rinkeby.addKeystoreManager(keystoreManager)
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(10000000)
            options.from = ks?.addresses?[0]
            options.value = 0
         
            let platform = web3Rinkeby.contract(jsonString, at: contractAddress, abiVersion: 2)
            
            let parameters = [name!, telephone!, type] as [AnyObject]
            
            let error = platform?.method("createOperator", parameters: parameters, options: options)?.send(password: "Whocares").error
            
            if error == nil{
                 performSegue(withIdentifier: "goToMainMenu", sender: self)
            }else{
                print(error)
            }
        }
        else{
            //TO DO: Address & Name
            var coordinatesIsAddress : Bool
            if address != nil{
                coordinatesIsAddress = true
            }
            else{
                coordinatesIsAddress = false
            }

            let name = secondField.text
            let latitude = (self.latitude) as! Double
            let longitude = (self.longitude) as! Double
            
            guard let sender = ks?.addresses?.first else {return}
            
            let web3Rinkeby = Web3.InfuraRinkebyWeb3()
            web3Rinkeby.addKeystoreManager(keystoreManager)
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(10000000)
            options.from = ks?.addresses?[0]
            options.value = 0
            
            let platform = web3Rinkeby.contract(jsonString, at: contractAddress, abiVersion: 2)
            
            let parameters = [name!, String(latitude), String(longitude) ] as [AnyObject]
            
            let error = platform?.method("createOwner", parameters: parameters, options: options)?.send(password: "Whocares").error
            
            if error == nil{
                performSegue(withIdentifier: "goToMainMenu", sender: self)
            }else{
                print(error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if longitude != nil{
            addressLabel.text = "Google Coordinates:        longitude: \(longitude!),        latitude: \(latitude!)"
        }
        if address != nil{
            addressLabel.text = "Address: \(address!)"
        }
    }
    
    func updateUI(type : String){
        if type == "Charity"{
            firstLabel.text = "Registration Number:"
            charityLabels.forEach { (label) in
                label.isHidden = true
            }
            charityField.forEach { (textfield) in
                textfield.isHidden = true
            }
            addressLabel.isHidden = true
            pickerView.isHidden = true
            mapButton.isHidden = true
        }
        else if type == "Owner"{
            charityLabels.forEach { (label) in
                label.isHidden = true
            }
            charityField.forEach { (textfield) in
                textfield.isHidden = true
            }
            pickerView.isHidden = true
            firstField.isHidden = true
            
        }
        else if type == "Operator"{
            mapButton.isHidden = true
            addressLabel.isHidden = true
            firstLabel.isHidden = true
            firstField.isHidden = true
        }
         navigationItem.title = type
    }
    @IBAction func mapButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToMap", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMap"{
            address = nil
            longitude = nil
            latitude = nil
        }
        if segue.identifier == "goToMainMenu"{
            let destinationVC = segue.destination as! MainMenuController
            destinationVC.type = type
        }
    }
}

extension RegisterController : UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return operatorTypeArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return operatorTypeArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        operatorType = operatorTypeArray[row]
    }
}

extension RegisterController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//
//  StartUpController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-19.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class StartUpController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ownerButton: CheckButton!
    @IBOutlet weak var operatorButton: CheckButton!
    @IBOutlet weak var publicButton: CheckButton!
    @IBOutlet weak var charityButton: CheckButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var buttons: [CheckButton]!

    var type : String = ""
    var ks : EthereumKeystoreV3?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.adjustsFontSizeToFitWidth = true
        view.sendSubview(toBack: imageView)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")

        if keystoreManager?.addresses?.count == 0{
            ks = try! EthereumKeystoreV3.init(password: "Whocares")
            let keydata = try! JSONEncoder().encode(ks!.keystoreParams)
            FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keydata, attributes: nil)
            print(ks?.addresses?.first)
        }else{
            ks = keystoreManager?.walletForAddress((keystoreManager?.addresses![0])!) as! EthereumKeystoreV3
            print(keystoreManager?.addresses![0])
        }
        
        print(type)
        type = getType() 
        
        if type == "Public"{
            
        }else{
            performSegue(withIdentifier: "loggedIn", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonPressed(_ sender: CheckButton) {
        if sender.tag == 0{
            type = "Charity"
        }
        else if sender.tag == 1{
            type = "Owner"
        }
        else if sender.tag == 2{
            type = "Operator"
        }
        else if sender.tag == 3{
            type = "Public"
            performSegue(withIdentifier: "goToQRReader", sender: self)
        }
         performSegue(withIdentifier: "goToLogIn", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToLogIn"{
            let destinatioVC = segue.destination as? UINavigationController
            let loginVC = destinatioVC?.viewControllers.first as! LogInController
            loginVC.type = type
        }
        if segue.identifier == "loggedIn"{
            let destinationVC = segue.destination as! MainMenuController
            destinationVC.type = type
        }
        if segue.identifier == "goToQRReader"{
            let destinationVC = segue.destination as! QRReaderController
            destinationVC.type = type
        }
    }
    
    
    func getType() -> String{
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        
        if let keyAddress = keystoreManager!.addresses!.first{
            let web3Rinkeby = Web3.InfuraRinkebyWeb3()
            web3Rinkeby.addKeystoreManager(keystoreManager)
            var options = Web3Options.defaultOptions()
            options.gasLimit = BigUInt(10000000)
            options.from = keyAddress
            options.value = 0
            
            let platform = web3Rinkeby.contract(jsonString, at: contractAddress, abiVersion: 2)
            
            
            let parameter = [keyAddress] as [AnyObject]
            
            do {
                let operate = try platform!.method("operatorMap", parameters: parameter, options: options)!.call(options: options).dematerialize()
                print(operate)
                if operate["name"] as! String != ""{
                     return "Operator"
                }
            }catch{
                print(error)
            }
            do {
                let operate = try platform!.method("ownerMap", parameters: parameter, options: options)!.call(options: options).dematerialize()
                print(operate)
                if operate["name"] as! String != ""{
                    return "Owner"
                }
            }catch{
                print(error)
            }
            do {
                let operate = try platform!.method("charityMap", parameters: parameter, options: options)!.call(options: options).dematerialize()
                print(operate)
                if operate["name"] as! String != ""{
                    return "Charity"
                }
            }catch{
                print(error)
            }
        }
        return "Public"
    }
}

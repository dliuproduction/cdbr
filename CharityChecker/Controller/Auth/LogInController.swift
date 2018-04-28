//
//  LogInController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-19.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import web3swift
import BigInt

class LogInController: UIViewController{
    
    
    @IBOutlet weak var imageView: UIImageView!
    var type : String!
    let picker = UIImagePickerController()
    @IBOutlet weak var buttonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func imageIsPressed(_ sender: Any) {
        show(picker, sender: self)
    }
    
    @IBAction func handleSignUp(_ sender: Any) {
        if type == "Charity" || type == "Owner" || type == "Operator"{
            //QR DETECTOR
            var detector:CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            
            var ciImage:CIImage = CIImage(image:imageView.image!)!
            var qrCodeLink : String = ""
            
            let features = detector.features(in: ciImage)
            
            if features.count != 0{
                for feature in features as! [CIQRCodeFeature] {
                    qrCodeLink += feature.messageString!
                }
            }
            
            if qrCodeLink=="" {
                let alert = UIAlertController(title: "Change Picture", message: "Please change the picture to a QRPicture", preferredStyle: .alert)
                let action = UIAlertAction(title: "Understood", style: .default) { (action) in
                    
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
                return
            }
            
              print(qrCodeLink)
            
            let privateKey = Data.init(hex: qrCodeLink)
            
            let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            var keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
            let ks : EthereumKeystoreV3?
            
            do{
                ks = try EthereumKeystoreV3.init(privateKey: privateKey, password: "Whocares")
                let keydata = try! JSONEncoder().encode(ks!.keystoreParams)
                FileManager.default.createFile(atPath: userDir + "/keystore"+"/key.json", contents: keydata, attributes: nil)
                print(ks?.addresses?.first)
                
                if let keyAddress = ks?.addresses?.first{
                    let web3Rinkeby = Web3.InfuraRinkebyWeb3()
                    web3Rinkeby.addKeystoreManager(keystoreManager)
                    var options = Web3Options.defaultOptions()
                    options.gasLimit = BigUInt(10000000)
                    options.from = keyAddress
                    options.value = 0
            
                    let parameter = [keyAddress] as [AnyObject]
                    
                    let platform = web3Rinkeby.contract(jsonString, at: contractAddress, abiVersion: 2)
                    
                    do {
                        let operate = try platform!.method("operatorMap", parameters: parameter, options: options)!.call(options: options).dematerialize()
                        print(operate)
                        if operate["name"] as! String != ""{
                            self.type = "Operator"
                        }
                    }catch{
                        print(error)
                    }
                    do {
                        let operate = try platform!.method("ownerMap", parameters: parameter, options: options)!.call(options: options).dematerialize()
                        if operate["name"] as! String != ""{
                            self.type = "Owner"
                        }
                    }catch{
                        print(error)
                    }
                    do {
                        let operate = try platform!.method("charityMap", parameters: parameter, options: options)!.call(options: options).dematerialize()
                        if operate["name"] as! String != ""{
                            self.type = "Charity"
                        }
                    }
                }
                performSegue(withIdentifier: "goToMainMenu", sender: self)
            }
            catch{
                print(error)
            }
            
            
            
        }
    }
    
    @IBAction func registerButton(_ sender: Any) {
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRegister"{
            let destinationVC = segue.destination as? RegisterController
            destinationVC?.type = type
        }
        if segue.identifier == "goToMainMenu"{
            let destinationVC = segue.destination as! MainMenuController
            destinationVC.type = type
        }
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateUI(){
        navigationItem.title = type
        navigationController?.navigationBar.tintColor = UIColor.black
    }

}

extension LogInController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            imageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

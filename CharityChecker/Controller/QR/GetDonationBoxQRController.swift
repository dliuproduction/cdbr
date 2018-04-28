//
//  GetDonationBoxQRController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-21.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import web3swift
import BigInt
import QRCode

class GetDonationBoxQRController: UIViewController {

    @IBOutlet weak var qrCodeView: UIImageView!
    @IBOutlet weak var qrView: UIView!
    
    var moneyBoxAddress : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        
        let ks : EthereumKeystoreV3?
        
        ks = keystoreManager?.walletForAddress((keystoreManager?.addresses![0])!) as! EthereumKeystoreV3
        
        let web3Rinkeby = Web3.InfuraRinkebyWeb3()
        web3Rinkeby.addKeystoreManager(keystoreManager)
        var options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(10000000)
        options.from = ks?.addresses![0]
        options.value = 0
        
        print(keystoreManager?.addresses?.count)
        
        let platform = web3Rinkeby.contract(jsonString, at: contractAddress, abiVersion: 2)
        
        do{
            
            let plat = web3Rinkeby.contract(moneyBoxString)
            
            let intermediate = try plat?.deploy(bytecode: byteCode, options: options)?.send(password: "Whocares").value
            
            self.moneyBoxAddress = self.handle(web3Rinkeby: web3Rinkeby, intermediate: intermediate!)
            let parameter = ["","","",self.moneyBoxAddress!] as [AnyObject]
            
            let data = platform?.method("createDropBox", parameters: parameter, options: options)?.send(password: "Whocares").value
            
            var qrCode = QRCode.init(self.moneyBoxAddress!)
            qrCode?.size = self.qrCodeView.bounds.size
            self.qrCodeView.image = qrCode?.image
        }
        catch{
            print(error)
        }
    }

    func handle(web3Rinkeby: web3 ,intermediate:[String : String]) -> String{
        do{
            let hash = intermediate["txhash"]!
            
            var receipt = web3Rinkeby.eth.getTransactionReceipt(hash)
            
            var transaction = try receipt.dematerialize()
            
            while transaction.blockNumber == 0 {
                 receipt = web3Rinkeby.eth.getTransactionReceipt(hash)
                
                transaction = try receipt.dematerialize()
            }
            
            let moneyBoxAddress = transaction.contractAddress?.address
            return moneyBoxAddress!
            
        }catch{
            print(error)
        }
       
        return "FUCK"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveImage(_ sender: Any) {
       UIImageWriteToSavedPhotosAlbum(qrCodeView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
}

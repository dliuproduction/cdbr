//
//  GetQRCodeController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-20.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import BigInt
import web3swift
import QRCode

class GetQRCodeController: UIViewController {

    @IBOutlet weak var qrView: UIView!
    @IBOutlet weak var qrCodeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let userDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let keystoreManager = KeystoreManager.managerForPath(userDir + "/keystore")
        let ks : EthereumKeystoreV3
        ks = keystoreManager?.walletForAddress((keystoreManager?.addresses![0])!) as! EthereumKeystoreV3
        
        do{
            let privateKey = try ks.UNSAFE_getPrivateKeyData(password: "Whocares", account: ks.addresses!.first!).toHexString()
            print(privateKey)
            var qrCode = QRCode.init(privateKey)!
            print(qrCode)
            qrCode.size = CGSize(width: qrCodeView.bounds.size.width, height: qrCodeView.bounds.size.height)
            qrCodeView.image = qrCode.image
            qrCodeView.contentMode = .scaleAspectFit
        }catch{
            print(error)
            fatalError()
        }
    
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

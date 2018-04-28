//
//  QRReaderController.swift
//  CharityChecker
//
//  Created by Philip Tam on 2018-04-19.
//  Copyright © 2018 CharityDonate. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMaps
import web3swift
import BigInt

class QRReaderController: UIViewController{
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var dropBoxLocation : CLLocationCoordinate2D?
    var charityName : String?
    var qrCode : String?
    
    var updateField : String?
    var set = false
    var type : String?
    var add : Bool?
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        messageLabel.adjustsFontSizeToFitWidth = true
        
        showVideo()
       
    }
    
    
    func parameters(qrCode: String){
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
        print("here")
        
        let platform = web3Rinkeby.contract(jsonString, at: contractAddress, abiVersion: 2)
        let otherPlatform = web3Rinkeby.contract(moneyBoxString)
        
        if set == false{
            if type! == "Public"{
                let parameter = [qrCode] as [AnyObject]
                do{
                    let coordinates = try platform?.method("boxMap", parameters: parameter, options: options)?.call(options: options).dematerialize()
                    if coordinates != nil{
                        
                        let charity = coordinates!["charity"] as! String
                        
                        if charity == nil || charity == ""{
                           charityName = "Charity has not been set!"
                        }else{
                            charityName = charity
                        }
                        
                        let latitude = coordinates!["latitude"] as! String
                        let longitude = coordinates!["longitude"] as! String
                        
                        dropBoxLocation = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(latitude)!, longitude: CLLocationDegrees(longitude)!)
                    }else{
                        fatalError()
                    }
                }catch{
                    print(error)
                }
         
                let alert = UIAlertController(title: "Check Map", message: "Do you want to find the dropbox on a map and then donate?", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "Yes", style: .default) { (action) in
                    self.performSegue(withIdentifier: "goToCheckLocation", sender: self)
                }
                let incorrect = UIAlertAction(title: "No", style: .default) { (action) in
                    
                }
                alert.addAction(confirm)
                alert.addAction(incorrect)
                present(alert, animated: true, completion: nil)
            }
            else if (type! == "Charity" || type! == "Operator") && add == false{
              
                //SET PROPER PARAMS
                let parameter = [qrCode] as [AnyObject]
                do{
                    let withdraw = try platform!.method("withdraw", parameters: parameter, options: options)!.send(password: "Whocares").dematerialize()
                    print(withdraw)
                    
                }
                catch{
                    print(error)
                }
            }
            else if type! == "Operator" && add == true{
           
                let parameter = [qrCode] as [AnyObject]
                do{
                    let operate = try platform!.method("setOperator", parameters: parameter, options: options)!.send(password: "Whocares").dematerialize()
                    
                    print(operate)
//
//                    let otherContract = try otherPlatform?.method("setOperator", parameters: [], options: options)!.send(password: "Whocares").dematerialize()
                    
                    
                    done()
                }
                catch{
                    print(error)
                }
            }
            else if type! == "Owner"{
                
                let parameter = [qrCode] as [AnyObject]
                let ownerAddress = [keystoreManager?.addresses?.first?.address] as [AnyObject]
                do{
                    print(qrCode)
                    let coordinates = try platform?.method("ownerMap", parameters: ownerAddress , options: options)?.call(options: options).dematerialize()
                    
                    let owner = try platform!.method("setOwner", parameters: parameter, options: options)!.send(password: "Whocares").dematerialize()
                    
                    print(owner)
                    
                    let latitude = coordinates!["latitude"] as! String
                    let longitude = coordinates!["longitude"] as! String
            
                    let param = [qrCode, latitude, longitude] as [AnyObject]
                    
                    let own = try platform!.method("changeLocation", parameters: param, options: options)?.send(password: "Whocares").dematerialize()
                    
                    print("---------------------------\(own)")
                }
                catch{
                    print(error)
                }
                  done()
            }
        }
        else{
            if updateField == "Operator"{
                //Register Operator
            }else{
                //Register Owner
            }
        }
    }
    
    func done(){
        let alert = UIAlertController(title: "Box Added!", message: "The box has been linked to the \(type)", preferredStyle: .alert)
        let action = UIAlertAction(title: "Okay!", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCheckLocation"{
            let destinationVC = segue.destination as! PublicLocationController
            destinationVC.dropboxLocation = dropBoxLocation
            destinationVC.qrCode = qrCode
            destinationVC.charityName = charityName
        }
    }
    
    @IBAction func restartButtonPressed(_ sender: CheckButton) {
        self.captureSession?.startRunning()
    }
    
    @IBAction func dismissButton(_ sender: UIButton) {
        dismiss(animated: true) {
            self.captureSession?.stopRunning()
        }
    }
}


extension QRReaderController : AVCaptureMetadataOutputObjectsDelegate{
    func showVideo(){
        
        captureSession = AVCaptureSession()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("WHAT")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession!.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession!.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
            // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            // Start video capture.
            captureSession!.startRunning()
            view.bringSubview(toFront: topBar)
            view.bringSubview(toFront: messageLabel)
            
            qrCodeFrameView = UIView()
            
            if let qrCodeFrameView = qrCodeFrameView{
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
                qrCode = metadataObj.stringValue
                print(qrCode)
                captureSession?.stopRunning()
                parameters(qrCode: qrCode!)
            }
        }
    }

}

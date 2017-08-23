//
//  ViewController.swift
//  secure-save-photos
//
//  Created by Mason Macias on 8/23/17.
//  Copyright © 2017 griffinmacias. All rights reserved.
//

import UIKit
import AVFoundation
import KeychainSwift
import RNCryptor

class ViewController: UIViewController {
    var previewView: UIView?
    var imagePicker = UIImagePickerController()
    var captureSession: AVCaptureSession?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var error: NSError?
    var password: String?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func createView() {
        previewView = UIView(frame: view.frame)
        view.addSubview(previewView!)
    }
    
    func setupCamera() {
        let captureDevice = AVCaptureDevice.defaultDevice(
            withDeviceType: .builtInWideAngleCamera,
            mediaType: AVMediaTypeVideo,
            position: .front)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
        } catch {
            print(error)
            return
        }
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput?.isHighResolutionCaptureEnabled = true
        
        captureSession?.addOutput(capturePhotoOutput)
        
        
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        createView()
        previewView?.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()

    }
    
    func takePhoto() {
        guard let capturePhotoOutput = self.capturePhotoOutput else { return }
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func haveUserCreatePassword() {
        let alertController = UIAlertController(title: "Create Password", message: "", preferredStyle: .alert)
        alertController.addTextField { (textfield) in
            //
        }
        let submitAction = UIAlertAction(title: "submit", style: .default) { (action) in
            if let textField = alertController.textFields?[0] {
                self.password = textField.text
                self.snapPics()
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    func snapPics() {
        self.setupCamera()
        var counter = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
            print("timer ticking \(counter)")
            if counter < 10 {
                self.takePhoto()
            } else {
                timer.invalidate()
                
            }
            counter += 1
        }
    }
    @IBAction func snapPicsButtonTapped(_ sender: Any) {
        print("snapPicsButtonTapped!")
        haveUserCreatePassword()
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
                print("Error capturing photo: \(String(describing: error))")
                return
        }
        
        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        
        if let password = password {            
            let encryptedImage = RNCryptor.encrypt(data: imageData, withPassword: password)
            let keychain = KeychainSwift()
            keychain.set(encryptedImage, forKey: "image")
        }
    }
}


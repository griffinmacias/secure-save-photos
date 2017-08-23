//
//  ViewController.swift
//  secure-save-photos
//
//  Created by Mason Macias on 8/23/17.
//  Copyright © 2017 griffinmacias. All rights reserved.
//

import UIKit
import AVFoundation
class ViewController: UIViewController {
    var previewView: UIView?
    var imagePicker = UIImagePickerController()
    var captureSession: AVCaptureSession?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var error: NSError?
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
    @IBAction func snapPicsButtonTapped(_ sender: Any) {
        print("snapPicsButtonTapped!")
        setupCamera()
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

        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            print("Ok we got the image \(image.description)")
        }
    }
}


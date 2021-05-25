//
//  CustomCameraController.swift
//  PhotoCapture
//
//  Created by Nitin A on 19/04/20.
//  Copyright © 2020 Nitin A. All rights reserved.
//

import UIKit
import AVFoundation

class CustomCameraController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: - Variables
    lazy private var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy private var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "capture_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        return button
    }()
    
    private let photoOutput = AVCapturePhotoOutput()
    
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        openCamera()
    }
    
    
    // MARK: - Private Methods
    private func setupUI() {
        
        view.addSubviews(backButton, takePhotoButton)
        
        takePhotoButton.makeConstraints(top: nil, left: nil, right: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 15, width: 80, height: 80)
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        backButton.makeConstraints(top: view.safeAreaLayoutGuide.topAnchor, left: nil, right: view.rightAnchor, bottom: nil, topMargin: 15, leftMargin: 0, rightMargin: 10, bottomMargin: 0, width: 50, height: 50)
    }
    
    private func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
            
        case .denied:
            print("the user has denied previously to access the camera.")
            self.handleDismiss()
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.handleDismiss()
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    private func setupCaptureSession() {

    
        let captureSession = AVCaptureSession()
        
        if let captureDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch let error {
                print("Failed to set input device with error: \(error)")
            }
            
            if captureSession.canAddOutput(photoOutput) {
                captureSession.addOutput(photoOutput)
            }
            
//            let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            cameraLayer.frame = self.view.frame
//            cameraLayer.videoGravity = .resizeAspectFill
//            //self.view.layer.addSublayer(cameraLayer)
            
            //Добавляем слой для камеры
            let scannerOverlayPreviewLayer              = ScannerOverlayPreviewLayer(session: captureSession)
            scannerOverlayPreviewLayer.frame            = self.view.bounds
            scannerOverlayPreviewLayer.maskSize         = CGSize(width: 200, height: 200)
            scannerOverlayPreviewLayer.videoGravity     = .resizeAspectFill
            self.view.layer.addSublayer(scannerOverlayPreviewLayer)
            
            //Указываем сканируемую область
            let metadataOutput = AVCaptureMetadataOutput()
            scannerOverlayPreviewLayer.metadataOutputRectConverted(fromLayerRect: scannerOverlayPreviewLayer.rectOfInterest)
            captureSession.addOutput(metadataOutput)
            captureSession.commitConfiguration()
            
//            let size = 300
//            let screenWidth = self.view.frame.size.width
//            let xPos = (CGFloat(screenWidth) / CGFloat(2)) - (CGFloat(size) / CGFloat(2))
            //let scanRect = CGRect(x: Int(xPos), y: 150, width: size, height: size)
            
//            var x = scanRect.origin.x/480
//            var y = scanRect.origin.y/640
//            var width = scanRect.width/480
//            var height = scanRect.height/640
            //var scanRectTransformed = CGRect(x, y, width, height)
            //var scanRectTransformed = CGRect(x: x, y: y, width: width, height: height)

            //captureMetadataOutput.rectOfInterest = scanRectTransformed
            
//            captureSession.startRunning()
            
            captureSession.startRunning()
//            let scanRect = CGRect(x: 0, y: 0, width: 100, height: 100)
//            let rectOfInterest = scannerOverlayPreviewLayer.metadataOutputRectConverted(fromLayerRect: scanRect)
//            metadataOutput.rectOfInterest = rectOfInterest
        
            //metadataOutput.rectOfInterest = scannerOverlayPreviewLayer.metadataOutputRectConverted(fromLayerRect: scannerOverlayPreviewLayer.rectOfInterest)
           // metadataOutput.rectOfInterest = scannerOverlayPreviewLayer.rectOfInterest
            
            self.setupUI()
        }
        
//        Добавляем слой для камеры
//        let scannerOverlayPreviewLayer              = ScannerOverlayPreviewLayer(session: captureSession)
//          scannerOverlayPreviewLayer.frame            = self.view.bounds
//          scannerOverlayPreviewLayer.maskSize         = CGSize(width: 200, height: 200)
//          scannerOverlayPreviewLayer.videoGravity     = .resizeAspectFill
//          self.view.layer.addSublayer(scannerOverlayPreviewLayer)
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        let size = 300
        let screenWidth = self.view.frame.size.width
        let xPos = (CGFloat(screenWidth) / CGFloat(2)) - (CGFloat(size) / CGFloat(2))
        let outputRect = CGRect(x: Int(xPos), y: 150, width: size, height: size)
        
        let previewImage = UIImage(data: imageData)?.cropped(rect: outputRect)
        
        let photoPreviewContainer = PhotoPreviewView(frame: self.view.frame)
        photoPreviewContainer.photoImageView.image = previewImage
        self.view.addSubviews(photoPreviewContainer)
    }
    
    private func cropToPreviewLayer(originalImage: UIImage) -> UIImage {
        //let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
        
        let size = 300
        let screenWidth = self.view.frame.size.width
        let xPos = (CGFloat(screenWidth) / CGFloat(2)) - (CGFloat(size) / CGFloat(2))
        let outputRect = CGRect(x: Int(xPos), y: 150, width: size, height: size)
        
        var cgImage = originalImage.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let cropRect = CGRect(x: outputRect.origin.x * width, y: outputRect.origin.y * height, width: outputRect.size.width * width, height: outputRect.size.height * height)
        
        cgImage = cgImage.cropping(to: cropRect)!
        let croppedUIImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: originalImage.imageOrientation)
        
        return croppedUIImage
    }
    
    func cropImage1(image: UIImage, rect: CGRect) -> UIImage {
        let cgImage = image.cgImage! // better to write "guard" in realm app
        let croppedCGImage = cgImage.cropping(to: rect)
        return UIImage(cgImage: croppedCGImage!)
    }
}

//Расширение для обрезки
extension UIImage {
    func cropped(rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage else { return nil }

        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()

        context?.translateBy(x: 0.0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(cgImage, in: CGRect(x: rect.minX, y: rect.minY, width: self.size.width, height: self.size.height), byTiling: false)


        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return croppedImage
    }
}

//
//  BioFaceViewController.swift
//  
//
//  Created by Simao Coutinho on 20/03/2024.
//

import UIKit
import AVFoundation

class BioFaceViewController: UIViewController {
    
    @IBOutlet weak var buttonImageView: UIImageView!
    @IBOutlet weak var captureButton: UIButton!
    
    var frontFacingCamera: AVCaptureDevice?
    var backFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
        
    var stillImageOutput: AVCapturePhotoOutput!
    var stillImage: UIImage?
        
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
        
    let captureSession = AVCaptureSession()
    
    private var imageResultListener: ImageResultListener?
    private var serviceType: ServiceType = .makeRegistration
    private var completion: BioFaceResponse?
    
    init(serviceType: ServiceType, imageResultListener: ImageResultListener, completion: @escaping BioFaceResponse) {
        self.serviceType = serviceType
        self.completion = completion
        self.imageResultListener = imageResultListener
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder aDecoder: NSCoder) {
        self.imageResultListener = nil
        self.completion = nil
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
    }

    @IBAction func takePictureClicked(_ sender: UIButton) {
        // Set photo settings
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
                
        stillImageOutput.isHighResolutionCaptureEnabled = true
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    private func configure() {
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
            
        // Get the front and back-facing camera for taking photos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
            
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
            
        currentDevice = frontFacingCamera
            
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
                return
        }
            
        // Configure the session with the output for capturing still images
        stillImageOutput = AVCapturePhotoOutput()
            
        // Configure the session with the input and the output devices
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
            
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
            
        // Bring the camera button to front
        view.bringSubviewToFront(buttonImageView)
        view.bringSubviewToFront(captureButton)
        captureSession.startRunning()
            
    }
}

extension BioFaceViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }
        
        // Get the image from the photo buffer
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        guard let image = UIImage(data: imageData) else { return }
        
        guard let completion = self.completion else { return }
        
        stillImage = image
        imageResultListener?.onImageResult(from: serviceType, with: image, completion: completion)
    }
}

//
//  BioFaceViewController.swift
//  
//
//  Created by Simao Coutinho on 20/03/2024.
//

import UIKit
import AVFoundation

class BioFaceViewController: UIViewController {
    
    @IBOutlet fileprivate weak var buttonImageView: UIImageView!
    @IBOutlet fileprivate weak var captureButton: UIButton!
    @IBOutlet fileprivate weak var mainView: UIView!
    @IBOutlet fileprivate weak var btnCancel: UIButton!
    @IBOutlet weak var ProgressView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var frontFacingCamera: AVCaptureDevice?
    var backFacingCamera: AVCaptureDevice?
    let captureDevice = AVCaptureDevice.default(for: .video)
        
    var stillImageOutput: AVCapturePhotoOutput!
    var stillImage: UIImage?
        
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
        
    let captureSession = AVCaptureSession()
    
    private var imageResultListener: ImageResultListener?
    private var serviceType: ServiceType = .makeRegistration
    private var completion: BioFaceResponse?
    
    init() {
            super.init(nibName: "BioFaceViewController", bundle: Bundle.module)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    
    public func setData(serviceType: ServiceType, imageResultListener: ImageResultListener, completion: @escaping BioFaceResponse) {
        self.serviceType = serviceType
        self.completion = completion
        self.imageResultListener = imageResultListener
    }
    
    public func setProgress(progress: Float, total: Float) {
        ProgressView.isHidden = false
        if progress == 0 {
            progressBar.progress = 0
        } else {
            progressBar.progress = progress / total
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
    }

    @IBAction func takePictureClicked(_ sender: UIButton) {
        // Set photo settings
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        // Configure photo settings
        photoSettings.flashMode = .auto
                
        stillImageOutput.photoSettingsForSceneMonitoring = photoSettings
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    private func configure() {
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
            
        // Get the front and back-facing camera for taking photos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
            
        guard let frontCamera = deviceDiscoverySession.devices.first else {
                print("Front camera not available.")
                return
            }
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: frontCamera)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        // Configure the session with the output for capturing still images
        stillImageOutput = AVCapturePhotoOutput()
            
        // Configure the session with the input and the output devices
        captureSession.addOutput(stillImageOutput)
            
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        mainView.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
            
        // Bring the camera button to front
        view.bringSubviewToFront(buttonImageView)
        view.bringSubviewToFront(captureButton)
        view.bringSubviewToFront(btnCancel)
        view.bringSubviewToFront(ProgressView)
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

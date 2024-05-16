
import Foundation
import UIKit

public class Facing {
    public static var apiToken: String?
    public static let sharedHandler: Facing = Facing()
    
    public var ENDPOINT_COMPLIANCE = true
    public var ENDPOINT_LIVENESS = true
    public var ENDPOINT_DICA = true
    public var ENDPOINT_CDTA = true
    public var ENDPOINT_SMAD = true
    
    
    private var vc : FacingViewController? = nil
    
    private let url = "https://visteamlab.isr.uc.pt/facing/v2/api/"
    private let secureDataKey = "GENERAL_BIOMETRIC_DATA_EXTR"
    
    private var livenessOptions : [Int] = []
    
    private var newTemplate : [Float] = []
    
    public init() {}
    
    public func makeRegistration(viewController: UIViewController, livenessOptions: [Int] = LivenessOptions().getDefaults(), completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else {
            return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        self.livenessOptions = livenessOptions
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .makeRegistration, imageResultListener: self, completion: completion)
        viewController.present(vc, animated: true, completion: nil)
        
    }
    
    public func addCard(viewController: UIViewController, completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        vc?.frontCameraCurrent = false
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .addCard, imageResultListener: self, completion: completion)
        viewController.present(vc, animated: true, completion: nil)
        
    }
    
    public func verifyUser(viewController: UIViewController, livenessOptions: [Int] = LivenessOptions().getDefaults(), completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        self.livenessOptions = livenessOptions
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .verifyUser, imageResultListener: self, completion: completion)
        viewController.present(vc, animated: true, completion: nil)
        
    }
}

extension Facing : ImageResultListener {
    private func makeCallToServerFor(_ endpoints: [FacingEndpoint], counter: Int, completion: @escaping FacingResponse) {
        vc?.setProgress(progress: Float(counter), total: Float(endpoints.count))
        
        let currentEndpoint = endpoints[counter]
        
        switch currentEndpoint.endpoint {
        case FacingEndpoint.EXTRACT :
            self.fetchFromServer(with: currentEndpoint.endpoint, parameters: currentEndpoint.parameters, progress: Float(counter), totalProgress: Float(endpoints.count)) { extractStatus, response, extractError in
                guard extractStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(extractStatus, nil, extractError)
                    return
                }
                
                guard let template = response?.data else {
                    self.vc?.dismiss(animated: true)
                    completion(extractStatus, nil, extractError)
                    return
                }
                
                if (counter + 1) < endpoints.count {
                    self.newTemplate = template
                    self.makeCallToServerFor(endpoints, counter: counter + 1, completion: completion)
                } else {
                    SecureData().saveFloatArrayToKeychain(floatArray: template, forKey: self.secureDataKey)
                    
                    self.vc?.dismiss(animated: true)
                    completion(.succeeded, nil, nil)
                }
            }
        case FacingEndpoint.COMPARE:
            guard let currentTemplate = SecureData().retrieveFloatArrayFromKeychain(forKey: self.secureDataKey) else {
                self.vc?.dismiss(animated: true)
                completion(.failed, nil, _error(for: .invalidTemplateFromSecureKey))
                return
            }
            
            let serverConnection = ServerConnection()
            serverConnection.makeCompareVerification(templateA: self.newTemplate,templateB: currentTemplate) { status, response, error in
                self.vc?.setProgress(progress: Float(counter), total: Float(endpoints.count))
                print("Compare Response: \(String(describing: response))")
                self.vc?.dismiss(animated: true)
                completion(status, response, error)
            }
        default :
            self.fetchFromServer(with: currentEndpoint.endpoint, parameters: currentEndpoint.parameters, progress: Float(counter), totalProgress: Float(endpoints.count)) { complianceStatus, _, complianceError in
                guard complianceStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(complianceStatus, nil, complianceError)
                    return
                }
                
                if (counter + 1) < endpoints.count {
                    self.makeCallToServerFor(endpoints, counter: counter + 1, completion: completion)
                }
            }
        }
    }
    
    
    func onImageResult(from: ServiceType, with: UIImage, completion: @escaping FacingResponse) {
        switch from {
        case .makeRegistration:
            let sessionId = UUID().uuidString
            let parameters = ["session_id": sessionId]
            
            
            var endpoints : [FacingEndpoint] = [
                FacingEndpoint(endpoint: FacingEndpoint.UPLOAD_IMAGE, parameters: parameters)
            ]
            
            if ENDPOINT_COMPLIANCE {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.COMPLIANCE, parameters: parameters)
                )
            }
            if ENDPOINT_LIVENESS {
                let parametersWithOptions: [String : Any] = [
                    "session_id": sessionId,
                    "requirements": self.livenessOptions
                ]
                
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.LIVENESS, parameters: parametersWithOptions)
                )
            }
            
            endpoints.append(
                FacingEndpoint(endpoint: FacingEndpoint.EXTRACT, parameters: parameters)
            )
            
            vc?.setProgress(progress: 0, total: Float(endpoints.count))
            
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: sessionId) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                
                self.makeCallToServerFor(endpoints, counter: 1, completion: completion)
            }
        case .addCard:
            let sessionId = UUID().uuidString
            let parameters = ["session_id": sessionId]
            
            var endpoints : [FacingEndpoint] = [
                FacingEndpoint(endpoint: FacingEndpoint.UPLOAD_IMAGE, parameters: parameters)
            ]
            
            if ENDPOINT_DICA {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.DICA, parameters: parameters)
                )
            }
            
            if ENDPOINT_CDTA {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.CDTA, parameters: parameters)
                )
            }
            
            if ENDPOINT_SMAD {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.SMAD, parameters: parameters)
                )
            }
            
            endpoints.append(
                FacingEndpoint(endpoint: FacingEndpoint.EXTRACT, parameters: parameters)
            )
            
            vc?.setProgress(progress: 0, total: Float(endpoints.count))
            
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: sessionId) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.makeCallToServerFor(endpoints, counter: 1, completion: completion)
            }
        case .verifyUser:
            var counter : Float = 3
            if ENDPOINT_COMPLIANCE {
                counter += 1
            }
            
            if ENDPOINT_LIVENESS {
                counter += 1
            }
            
            let sessionId = UUID().uuidString
            let parameters = ["session_id": sessionId]
            
            var endpoints : [FacingEndpoint] = [
                FacingEndpoint(endpoint: FacingEndpoint.UPLOAD_IMAGE, parameters: parameters)
            ]
            
            if ENDPOINT_COMPLIANCE {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.COMPLIANCE, parameters: parameters)
                )
            }
            if ENDPOINT_LIVENESS {
                let parametersWithOptions: [String : Any] = [
                    "session_id": sessionId,
                    "requirements": self.livenessOptions
                ]
                
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.LIVENESS, parameters: parametersWithOptions)
                )
            }
            
            endpoints.append(
                FacingEndpoint(endpoint: FacingEndpoint.EXTRACT, parameters: parameters)
            )
            endpoints.append(
                FacingEndpoint(endpoint: FacingEndpoint.COMPARE, parameters: parameters)
            )
            
            vc?.setProgress(progress: 0, total: Float(endpoints.count))
            
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: sessionId) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.makeCallToServerFor(endpoints, counter: 1, completion: completion)
            }
        }
    }
    
    private func fetchFromServer(with url: String, parameters: [String : Any], progress: Float, totalProgress: Float, completion: @escaping (FacingStatus, ExtractResponse?, NSError?) -> Void) {
        let serverConnection = ServerConnection()
        
        serverConnection.makeGetConnection(url: url,parameters: parameters) { status, response, error in
            self.vc?.setProgress(progress: progress, total: totalProgress)
            print("\(url) Response: \(String(describing: response))")
            completion(status, response?.data, error)
        }
    }
}

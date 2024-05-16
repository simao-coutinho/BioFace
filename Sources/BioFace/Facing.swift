
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
    
    private let secureDataKey = "GENERAL_BIOMETRIC_DATA_EXTR"
    
    private var icaoOptions : [Int] = []
    
    private var newTemplate : [Float] = []
    private let serverConnection = ServerConnection()
    
    public init() {}
    
    public func makeRegistration(viewController: UIViewController, icaoOptions: [Int] = IcaoOptions().getDefaults(), completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else {
            return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        self.icaoOptions = icaoOptions
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .makeRegistration, imageResultListener: self, completion: completion)
        
        ServerConnection.url = "https://visteamlab.isr.uc.pt/facing/v2/api/"
        ServerConnection.apiToken = Facing.apiToken
        
        if ServerConnection.url == nil {
            serverConnection.getUrlAndApiToken { status, _, error in
                switch status {
                case .succeeded:
                    ServerConnection.apiToken = Facing.apiToken
                    viewController.present(vc, animated: true, completion: nil)
                default:
                    completion(.failed, nil, error)
                }
            }
        } else {
            viewController.present(vc, animated: true, completion: nil)
        }
    }
    
    public func addCard(viewController: UIViewController, completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        vc?.frontCameraCurrent = false
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .addCard, imageResultListener: self, completion: completion)
        
        ServerConnection.url = "https://visteamlab.isr.uc.pt/facing/v2/api/"
        ServerConnection.apiToken = Facing.apiToken
        
        if ServerConnection.url == nil {
            serverConnection.getUrlAndApiToken { status, _, error in
                switch status {
                case .succeeded:
                    ServerConnection.apiToken = Facing.apiToken
                    viewController.present(vc, animated: true, completion: nil)
                default:
                    completion(.failed, nil, error)
                }
            }
        } else {
            viewController.present(vc, animated: true, completion: nil)
        }
        
    }
    
    public func verifyUser(viewController: UIViewController, icaoOptions: [Int] = IcaoOptions().getDefaults(), completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        self.icaoOptions = icaoOptions
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .verifyUser, imageResultListener: self, completion: completion)
        
        ServerConnection.url = "https://visteamlab.isr.uc.pt/facing/v2/api/"
        ServerConnection.apiToken = Facing.apiToken
        
        if ServerConnection.url == nil {
            serverConnection.getUrlAndApiToken { status, _, error in
                switch status {
                case .succeeded:
                    ServerConnection.apiToken = Facing.apiToken
                    viewController.present(vc, animated: true, completion: nil)
                default:
                    completion(.failed, nil, error)
                }
            }
        } else {
            viewController.present(vc, animated: true, completion: nil)
        }
    }
}

extension Facing : ImageResultListener {
    
    private func makeCallToServerFor(_ endpoints: [FacingEndpoint], counter: Int, completion: @escaping FacingResponse) {
        vc?.setProgress(progress: Float(counter), total: Float(endpoints.count))
        
        let currentEndpoint = endpoints[counter]
        
        switch currentEndpoint.endpoint {
        case FacingEndpoint.EXTRACT :
            serverConnection.makeGetConnection(url: currentEndpoint.endpoint,parameters: currentEndpoint.parameters) { status, response, error in
                self.vc?.setProgress(progress: Float(counter), total: Float(endpoints.count))
                guard status == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(.failed, nil, error)
                    return
                }
                
                guard let template = response?.data?.data else {
                    self.vc?.dismiss(animated: true)
                    completion(.failed, nil, error)
                    return
                }
                
                if response?.data?.verdict == 0 {
                    self.vc?.dismiss(animated: true)
                    completion(.failed, nil, nil)
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
            
            serverConnection.makeCompareVerification(templateA: self.newTemplate,templateB: currentTemplate) { status, response, error in
                self.vc?.setProgress(progress: Float(counter), total: Float(endpoints.count))
                print("Compare Response: \(String(describing: response))")
                self.vc?.dismiss(animated: true)
                
                if response?.data?.verdict == 0 {
                    completion(.failed, nil, nil)
                    return
                }
                
                completion(status, response, error)
            }
        default :
            serverConnection.makeGetConnection(url: currentEndpoint.endpoint,parameters: currentEndpoint.parameters) { status, response, error in
                self.vc?.setProgress(progress: Float(counter), total: Float(endpoints.count))
                guard status == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(.failed, nil, error)
                    return
                }
                
                if response?.data?.verdict == 0 {
                    if currentEndpoint.endpoint == FacingEndpoint.COMPLIANCE, let blocks = response?.data?.blocks {
                        for block in blocks {
                            if block.verdict == 0 {
                                let alert = UIAlertController(title: "", message: IcaoOptions().getMessage(icaoOption: block.name ?? ""), preferredStyle: .alert)
                                self.vc?.present(alert, animated: true, completion: nil)
                                
                                let when = DispatchTime.now() + 3
                                DispatchQueue.main.asyncAfter(deadline: when){
                                    alert.dismiss(animated: true, completion: nil)
                                }
                                
                                self.vc?.hideProgress()
                                return
                            }
                        }
                    } else {
                        self.vc?.dismiss(animated: true)
                        completion(.failed, nil, nil)
                        return
                    }
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
            
            print("SESSION_ID: \(sessionId)")
            
            
            var endpoints : [FacingEndpoint] = [
                FacingEndpoint(endpoint: FacingEndpoint.UPLOAD_IMAGE, parameters: parameters)
            ]
            
            if ENDPOINT_COMPLIANCE {
                let parametersWithOptions: [String : Any] = [
                    "session_id": sessionId,
                    "requirements": self.icaoOptions
                ]
                
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.COMPLIANCE, parameters: parametersWithOptions)
                )
            }
            if ENDPOINT_LIVENESS {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.LIVENESS, parameters: parameters)
                )
            }
            
            endpoints.append(
                FacingEndpoint(endpoint: FacingEndpoint.EXTRACT, parameters: parameters)
            )
            
            vc?.setProgress(progress: 0, total: Float(endpoints.count))
            
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
                let parametersWithOptions: [String : Any] = [
                    "session_id": sessionId,
                    "requirements": self.icaoOptions
                ]
                
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.COMPLIANCE, parameters: parametersWithOptions)
                )
            }
            if ENDPOINT_LIVENESS {
                
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.LIVENESS, parameters: parameters)
                )
            }
            
            endpoints.append(
                FacingEndpoint(endpoint: FacingEndpoint.EXTRACT, parameters: parameters)
            )
            endpoints.append(
                FacingEndpoint(endpoint: FacingEndpoint.COMPARE, parameters: parameters)
            )
            
            vc?.setProgress(progress: 0, total: Float(endpoints.count))
            
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
}

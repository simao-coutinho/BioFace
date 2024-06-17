
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
    private var cardTemplateId: String = ""
    
    private var newTemplate : [Float] = []
    private let serverConnection = ServerConnection()
    private var functionality : ServiceType = .makeRegistration
    private var firstTime = true
    
    public init() {}
    
    public func makeRegistration(viewController: UIViewController, icaoOptions: [Int] = IcaoOptions().getRegistrationDefaults(), completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else {
            return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        self.icaoOptions = icaoOptions
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .makeRegistration, imageResultListener: self, completion: completion)
        
        viewController.present(vc, animated: true, completion: nil)
    }
    
    public func addCard(viewController: UIViewController, cardTemplateId: String = "", completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        let currentTemplate = SecureData().retrieveFloatArrayFromKeychain(forKey: self.secureDataKey)
        
        if (currentTemplate == nil || currentTemplate == []) {
            completion(.failed, nil, _error(for: .invalidTemplateFromSecureKey))
            return
        }
        
        vc = FacingViewController.init()
        vc?.frontCameraCurrent = false
        functionality = .addCard
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .addCard, imageResultListener: self, completion: completion)
        
        viewController.present(vc, animated: true, completion: nil)
    }
    
    public func verifyUser(viewController: UIViewController, icaoOptions: [Int] = IcaoOptions().getVerificationDefaults(), completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        let currentTemplate = SecureData().retrieveFloatArrayFromKeychain(forKey: self.secureDataKey)
        
        if (currentTemplate == nil || currentTemplate == []) {
            completion(.failed, nil, _error(for: .invalidTemplateFromSecureKey))
            return
        }
        
        vc = FacingViewController.init()
        self.icaoOptions = icaoOptions
        functionality = .verifyUser
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .verifyUser, imageResultListener: self, completion: completion)
        
        viewController.present(vc, animated: true, completion: nil)
    }
    
    public func invalidateUser(completion: @escaping FacingResponse) {
        SecureData().saveFloatArrayToKeychain(floatArray: [], forKey: self.secureDataKey)
        completion(.succeeded, nil, nil)
        
    }
}

extension Facing : ImageResultListener {
    
    private func checkVerdictFor(_ response: Response?) -> Bool {
        return response?.data?.verdict == 1
    }
    
    
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
                
                if !self.checkVerdictFor(response) {
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
                
                if !self.checkVerdictFor(response) {
                    let error = IcaoOptions().getMessage(icaoOption: response?.data?.name ?? "")
                    
                    self.vc?.dismiss(animated: true)
                    completion(.failed, nil, _error(for: .veredictNotValid, apiErrorCode: error))
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
                
                if !self.checkVerdictFor(response), let blocks = response?.data?.blocks {
                    if currentEndpoint.endpoint == FacingEndpoint.COMPLIANCE {
                        for block in blocks {
                            if block.verdict == 0 {
                                if self.functionality == .makeRegistration {
                                    self.vc?.alertLabel.text = IcaoOptions().getMessage(icaoOption: block.name ?? "")
                                    self.vc?.alertView.isHidden = false
                                    
                                    let when = DispatchTime.now() + 3
                                    DispatchQueue.main.asyncAfter(deadline: when){
                                        self.vc?.alertView.isHidden = true
                                    }
                                    
                                    self.vc?.hideProgress()
                                    self.vc?.startTimer()
                                    return
                                } else {
                                    let error = IcaoOptions().getMessage(icaoOption: block.name ?? "")
                                    
                                    self.vc?.dismiss(animated: true)
                                    completion(.failed, nil, _error(for: .veredictNotValid, apiErrorCode: error))
                                    return
                                }
                            }
                        }
                    } else {
                        for block in blocks {
                            if block.verdict == 0 {
                                let error = IcaoOptions().getMessage(icaoOption: block.name ?? "")
                                
                                self.vc?.dismiss(animated: true)
                                completion(.failed, nil, _error(for: .veredictNotValid, apiErrorCode: error))
                                return
                            }
                        }
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
            
            if firstTime && ENDPOINT_LIVENESS {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.LIVENESS, parameters: parameters)
                )
                firstTime = false
            }
            
            if ENDPOINT_COMPLIANCE {
                let parametersWithOptions: [String : Any] = [
                    "session_id": sessionId,
                    "requirements": "[\(self.icaoOptions.map { option in String(option) }.joined(separator: ","))]"
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
            
            print("SESSION_ID: \(sessionId)")
            
            var endpoints : [FacingEndpoint] = [
                FacingEndpoint(endpoint: FacingEndpoint.UPLOAD_IMAGE, parameters: parameters)
            ]
            
            if ENDPOINT_DICA {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.DICA, parameters: parameters)
                )
            }
            
            if ENDPOINT_CDTA {
                let cdtaParameters = [
                    "session_id": sessionId,
                    "template_id": self.cardTemplateId
                ]
                
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.CDTA, parameters: cdtaParameters)
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
        case .verifyUser:
            let sessionId = UUID().uuidString
            let parameters = ["session_id": sessionId]
            
            print("SESSION_ID: \(sessionId)")
            
            var endpoints : [FacingEndpoint] = [
                FacingEndpoint(endpoint: FacingEndpoint.UPLOAD_IMAGE, parameters: parameters)
            ]
            
            if ENDPOINT_LIVENESS {
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.LIVENESS, parameters: parameters)
                )
            }
            
            if ENDPOINT_COMPLIANCE {
                let parametersWithOptions: [String : Any] = [
                    "session_id": sessionId,
                    "requirements": "[\(self.icaoOptions.map { option in String(option) }.joined(separator: ","))]"
                ]
                
                endpoints.append(
                    FacingEndpoint(endpoint: FacingEndpoint.COMPLIANCE, parameters: parametersWithOptions)
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


import Foundation
import UIKit

public class Facing {
    public static var apiToken: String?
    public static let sharedHandler: Facing = Facing()
    
    private var vc : FacingViewController? = nil
    
    private let url = "https://visteamlab.isr.uc.pt/facing/v2/api/"
    private let secureDataKey = "GENERAL_BIOMETRIC_DATA_EXTR"

    public init() {}
    
    public func makeRegistration(viewController: UIViewController, completion: @escaping FacingResponse) {
        let defaults = UserDefaults.standard
        var sessionId = defaults.string(forKey: "SESSION_ID")
        if sessionId == nil {
            sessionId = UUID().uuidString
            defaults.set(sessionId, forKey: "SESSION_ID")
        }
        
        guard let sessionId = sessionId else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        guard Facing.apiToken != nil else {
            return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        guard sessionId.data(using: .utf8, allowLossyConversion: false) != nil else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        vc = FacingViewController.init()
        
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
    
    public func verifyUser(viewController: UIViewController, completion: @escaping FacingResponse) {
        guard Facing.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        
        vc = FacingViewController.init()
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .verifyUser, imageResultListener: self, completion: completion)
        viewController.present(vc, animated: true, completion: nil)
        
    }
}

extension Facing : ImageResultListener {
    func onImageResult(from: ServiceType, with: UIImage, completion: @escaping FacingResponse) {
        vc?.setProgress(progress: 0, total: 4)
        switch from {
        case .makeRegistration:
            let defaults = UserDefaults.standard
            guard let sessionId = defaults.string(forKey: "SESSION_ID") else { return }
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: sessionId) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.vc?.setProgress(progress: 1, total: 4)
                    
                self.fetchFromServer(with: "compliance", sessionId: sessionId, progress: 2, totalProgress: 4) { complianceStatus, _, complianceError in
                    guard complianceStatus == .succeeded else {
                        self.vc?.dismiss(animated: true)
                        completion(complianceStatus, nil, complianceError)
                        return
                    }
                        
                    self.fetchFromServer(with: "liveness", sessionId: sessionId, progress: 3, totalProgress: 4) { livenessStatus, _, livenessError in
                        guard livenessStatus == .succeeded else {
                            self.vc?.dismiss(animated: true)
                            completion(livenessStatus, nil, livenessError)
                            return
                        }
                            
                        self.fetchFromServer(with: "extract", sessionId: sessionId, progress: 4, totalProgress: 4) { extractStatus, response, extractError in
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
                            
                            SecureData().saveFloatArrayToKeychain(floatArray: template, forKey: self.secureDataKey)
                            
                            self.vc?.dismiss(animated: true)
                            completion(.succeeded, nil, nil)
                        }
                    }
                }
            }
        case .addCard:
            let sessionId = UUID().uuidString
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: sessionId) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.vc?.setProgress(progress: 1, total: 6)
                    
                self.fetchFromServer(with: "dica", sessionId: sessionId, progress: 2, totalProgress: 6) { complianceStatus, _, complianceError in
                    guard complianceStatus == .succeeded else {
                        self.vc?.dismiss(animated: true)
                        completion(complianceStatus, nil, complianceError)
                        return
                    }
                        
                    self.fetchFromServer(with: "cdta", sessionId: sessionId, progress: 3, totalProgress: 6) { livenessStatus, _, livenessError in
                        guard livenessStatus == .succeeded else {
                            self.vc?.dismiss(animated: true)
                            completion(livenessStatus, nil, livenessError)
                            return
                        }
                            
                        self.fetchFromServer(with: "smad", sessionId: sessionId, progress: 4, totalProgress: 6) { extractStatus, _, extractError in
                            guard extractStatus == .succeeded else {
                                self.vc?.dismiss(animated: true)
                                completion(extractStatus, nil, extractError)
                                return
                            }
                            
                            self.fetchFromServer(with: "extract", sessionId: sessionId, progress: 5, totalProgress: 6) { extractStatus, response, extractError in
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
                                
                                guard let currentTemplate = SecureData().loadFromKeychain(forKey: self.secureDataKey) else {
                                    self.vc?.dismiss(animated: true)
                                    completion(.failed, nil, _error(for: .invalidTemplateFromSecureKey))
                                    return
                                }
                                
                                let dataExtr = Data(buffer: UnsafeBufferPointer(start: template, count: template.count))
                                
                                let parameters: [String: Data] = [
                                    "templateA" : dataExtr,
                                    "templateB" : currentTemplate
                                ]
                                
                                /*serverConnection.makePostConnection(url: "compare",parameters: parameters) { status, response, error in
                                    self.vc?.setProgress(progress: 6, total: 6)
                                    print("Compare Response: \(String(describing: response))")
                                    self.vc?.dismiss(animated: true)
                                    completion(.succeeded, nil, nil)
                            
                                }*/
                            }
                        }
                    }
                }
            }
        case .verifyUser:
            let sessionId = UUID().uuidString
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: sessionId) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    self.vc?.dismiss(animated: true)
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.vc?.setProgress(progress: 1, total: 5)
                    
                self.fetchFromServer(with: "compliance", sessionId: sessionId, progress: 2, totalProgress: 5) { complianceStatus, _, complianceError in
                    guard complianceStatus == .succeeded else {
                        self.vc?.dismiss(animated: true)
                        completion(complianceStatus, nil, complianceError)
                        return
                    }
                        
                    self.fetchFromServer(with: "liveness", sessionId: sessionId, progress: 3, totalProgress: 5) { livenessStatus, _, livenessError in
                        guard livenessStatus == .succeeded else {
                            self.vc?.dismiss(animated: true)
                            completion(livenessStatus, nil, livenessError)
                            return
                        }
                            
                        self.fetchFromServer(with: "extract", sessionId: sessionId, progress: 4, totalProgress: 5) { extractStatus, response, extractError in
                            guard extractStatus == .succeeded else {
                                self.vc?.dismiss(animated: true)
                                completion(extractStatus, nil, extractError)
                                return
                            }
                            

                            guard let template = response?.data else {
                                self.vc?.dismiss(animated: true)
                                completion(extractStatus, nil, _error(for: .invalidTemplateFromServer))
                                return
                            }
                            
                            guard let currentTemplate = SecureData().retrieveFloatArrayFromKeychain(forKey: self.secureDataKey) else {
                                self.vc?.dismiss(animated: true)
                                completion(.failed, nil, _error(for: .invalidTemplateFromSecureKey))
                                return
                            }
                            
                            let parameters: [String: [Float]] = [
                                "templateA" : template,
                                "templateB" : currentTemplate
                            ]
                            
                            serverConnection.makeCompareVerification(templateA: "compare",templateB: parameters) { status, response, error in
                                self.vc?.setProgress(progress: 6, total: 6)
                                print("Compare Response: \(String(describing: response))")
                                self.vc?.dismiss(animated: true)
                                completion(.succeeded, nil, nil)
                        
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func fetchFromServer(with url: String, sessionId: String, progress: Float, totalProgress: Float, completion: @escaping (FacingStatus, ExtractResponse?, NSError?) -> Void) {
        let serverConnection = ServerConnection()
        serverConnection.makeGetConnection(url: url,sessionId: sessionId) { status, response, error in
            self.vc?.setProgress(progress: progress, total: totalProgress)
            print("\(url) Response: \(String(describing: response))")
            completion(status, response?.data, error)
        }
    }
}

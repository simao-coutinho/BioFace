
import Foundation
import UIKit

public class BioFace {
    public static var apiToken: String?
    public static var sessionId: String?
    public static let sharedHandler: BioFace = BioFace()
    
    private var vc : BioFaceViewController? = nil
    
    private let url = "https://visteamlab.isr.uc.pt/facing/v2/api/"

    public init() {}
    
    public func makeRegistration(_ sessionId: String, viewController: UIViewController, completion: @escaping BioFaceResponse) {
        BioFace.sessionId = sessionId
        guard BioFace.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }	
        guard sessionId.data(using: .utf8, allowLossyConversion: false) != nil else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        vc = BioFaceViewController.init()
        
        guard let vc = vc else { return completion(.failed, nil, _error(for:.invalidApiTokenErrorCode))}
        
        vc.setData(serviceType: .makeRegistration, imageResultListener: self, completion: completion)
        viewController.present(vc, animated: true, completion: nil)
        
    }
}

extension BioFace : ImageResultListener {
    func onImageResult(from: ServiceType, with: UIImage, completion: @escaping BioFaceResponse) {
        vc?.setProgress(progress: 0, total: 4)
        switch from {
        case .makeRegistration:
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: nil) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.vc?.setProgress(progress: 1, total: 4)
                    
                self.fetchFromServer(with: "compliance", sessionId: nil, progress: 2) { complianceStatus, _, complianceError in
                    guard complianceStatus == .succeeded else {
                        completion(complianceStatus, nil, complianceError)
                        return
                    }
                        
                    self.fetchFromServer(with: "liveness", sessionId: nil, progress: 3) { livenessStatus, _, livenessError in
                        guard livenessStatus == .succeeded else {
                            completion(livenessStatus, nil, livenessError)
                            return
                        }
                            
                        self.fetchFromServer(with: "extract", sessionId: nil, progress: 4) { extractStatus, _, extractError in
                            guard extractStatus == .succeeded else {
                                completion(extractStatus, nil, extractError)
                                return
                            }
                                
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
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.vc?.setProgress(progress: 1, total: 4)
                    
                self.fetchFromServer(with: "dica", sessionId: sessionId, progress: 2) { complianceStatus, _, complianceError in
                    guard complianceStatus == .succeeded else {
                        completion(complianceStatus, nil, complianceError)
                        return
                    }
                        
                    self.fetchFromServer(with: "cdta", sessionId: sessionId, progress: 3) { livenessStatus, _, livenessError in
                        guard livenessStatus == .succeeded else {
                            completion(livenessStatus, nil, livenessError)
                            return
                        }
                            
                        self.fetchFromServer(with: "smad", sessionId: sessionId, progress: 4) { extractStatus, _, extractError in
                            guard extractStatus == .succeeded else {
                                completion(extractStatus, nil, extractError)
                                return
                            }
                            
                            self.fetchFromServer(with: "extract", sessionId: sessionId, progress: 4) { extractStatus, _, extractError in
                                guard extractStatus == .succeeded else {
                                    completion(extractStatus, nil, extractError)
                                    return
                                }
                                    
                                self.fetchFromServer(with: "compare", sessionId: sessionId, progress: 4) { extractStatus, _, extractError in
                                    guard extractStatus == .succeeded else {
                                        completion(extractStatus, nil, extractError)
                                        return
                                    }
                                        
                                    self.vc?.dismiss(animated: true)
                                    completion(.succeeded, nil, nil)
                                }
                            }
                        }
                    }
                }
            }
        case .verifyUser:
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with, sessionId: nil) { uploadStatus, _, uploadError in
                guard uploadStatus == .succeeded else {
                    completion(uploadStatus, nil, uploadError)
                    return
                }
                self.vc?.setProgress(progress: 1, total: 4)
                    
                self.fetchFromServer(with: "compliance", sessionId: nil, progress: 2) { complianceStatus, _, complianceError in
                    guard complianceStatus == .succeeded else {
                        completion(complianceStatus, nil, complianceError)
                        return
                    }
                        
                    self.fetchFromServer(with: "liveness", sessionId: nil, progress: 3) { livenessStatus, _, livenessError in
                        guard livenessStatus == .succeeded else {
                            completion(livenessStatus, nil, livenessError)
                            return
                        }
                            
                        self.fetchFromServer(with: "extract", sessionId: nil, progress: 4) { extractStatus, _, extractError in
                            guard extractStatus == .succeeded else {
                                completion(extractStatus, nil, extractError)
                                return
                            }
                                
                            self.fetchFromServer(with: "compare", sessionId: nil, progress: 4) { extractStatus, _, extractError in
                                guard extractStatus == .succeeded else {
                                    completion(extractStatus, nil, extractError)
                                    return
                                }
                                    
                                self.vc?.dismiss(animated: true)
                                completion(.succeeded, nil, nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func fetchFromServer(with url: String, sessionId: String?, progress: Float, completion: @escaping (BioFaceStatus, Any?, NSError?) -> Void) {
        let serverConnection = ServerConnection()
        serverConnection.makeGetConnection(url: url,sessionId: sessionId) { status, response, error in
            self.vc?.setProgress(progress: progress, total: 4)
            print("\(url) Response: \(String(describing: response))")
            completion(status, response, error)
        }
    }
}


import Foundation
import UIKit

public class BioFace {
    public static var apiToken: String?
    public static var sessionId: String?
    public static let sharedHandler: BioFace = BioFace()
    
    private let url = "https://visteamlab.isr.uc.pt/facing/v2/api/"

    public init() {}
    
    public func makeRegistration(_ sessionId: String, completion: @escaping BioFaceResponse) {
        BioFace.sessionId = sessionId
        guard BioFace.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        guard sessionId.data(using: .utf8, allowLossyConversion: false) != nil else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        let viewController = BioFaceViewController.init()
        
        viewController.setData(serviceType: .makeRegistration, imageResultListener: self, completion: completion)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rootViewController.present(viewController, animated: true, completion: nil)
            }
    }
}

extension BioFace : ImageResultListener {
    func onImageResult(from: ServiceType, with: UIImage, completion: @escaping BioFaceResponse) {
        switch from {
        case .makeRegistration:
            let serverConnection = ServerConnection()
            serverConnection.makeImageUpload(with: with) { status, response, error in
                switch status {
                case .succeeded:
                    serverConnection.makeGetConnection(url: "compliance") { status, response, error in
                        switch status {
                        case .succeeded:
                            serverConnection.makeGetConnection(url: "liveness") { status, response, error in
                                switch status {
                                case .succeeded:
                                    serverConnection.makeGetConnection(url: "extract") { status, response, error in
                                        switch status {
                                            case .succeeded:
                                                completion(.succeeded, nil, nil)
                                            case .canceled:
                                                completion(.canceled, nil, error)
                                            case .failed:
                                                completion(.failed, nil, error)
                                        }
                                    }
                                case .canceled:
                                    completion(.canceled, nil, error)
                                case .failed:
                                    completion(.failed, nil, error)
                                }
                            }
                            
                        case .canceled:
                            completion(.canceled, nil, error)
                        case .failed:
                            completion(.failed, nil, error)
                        }
                    }
                case .canceled:
                    completion(.canceled, nil, error)
                case .failed:
                    completion(.failed, nil, error)
                }
                completion(.succeeded, nil, nil)
            }
        case .addCart:
            completion(.succeeded, nil, nil)
        case .verifyUser:
            completion(.succeeded, nil, nil)
        }
    }
}

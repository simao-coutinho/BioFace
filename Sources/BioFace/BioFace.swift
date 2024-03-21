import Alamofire
import Foundation
import UIKit

public class BioFace {
    public static var apiToken: String?
    public static let sharedHandler: BioFace = BioFace()
    public private(set) var sessionId = ""
    
    private let url = "https://visteamlab.isr.uc.pt/facing/v2/api/"

    public init() {}
    
    public func registerUser(_ mSessionId: String) {
        sessionId = mSessionId
    }
    
    public func makeRegistration(completion: @escaping BioFaceResponse) {
        guard BioFace.apiToken != nil else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        guard sessionId.data(using: .utf8, allowLossyConversion: false) != nil else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        let viewController = BioFaceViewController(serviceType: .makeRegistration, imageResultListener: self, completion: completion)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
                rootViewController.present(viewController, animated: true, completion: nil)
            }
    }
    
    // (status, paymentIntent, error) in
    
    public func uploadImage(_ file: Data,filename : String, completion: @escaping BioFaceResponse) {
        guard let apiToken = BioFace.apiToken else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        guard let sessionIdData = sessionId.data(using: .utf8, allowLossyConversion: false) else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
            
        }
        guard let collectionNameData = "teste anm".data(using: .utf8, allowLossyConversion: false) else { return }
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data",
            "authorization": "Bearer " + apiToken
        ]

        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(sessionIdData, withName: "session_id")
                multipartFormData.append(collectionNameData, withName: "collection_name")
                multipartFormData.append(file, withName: "collection" , fileName: filename, mimeType: "image/jpg")
        },
            to: url + "collect", method: .post , headers: headers).responseDecodable(of: Response.self) { response in
                completion(.succeeded, nil, nil)
            }
    }
}

extension BioFace : ImageResultListener {
    func onImageResult(from: ServiceType, with: UIImage, completion: @escaping BioFaceResponse) {
        guard let apiToken = BioFace.apiToken else { return completion(.failed, nil, _error(for: .invalidApiTokenErrorCode)) }
        guard let sessionIdData = sessionId.data(using: .utf8, allowLossyConversion: false) else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        
        switch from {
        case .makeRegistration:
            completion(.succeeded, nil, nil)
        case .addCart:
            completion(.succeeded, nil, nil)
        case .verifyUser:
            completion(.succeeded, nil, nil)
        }
    }
}

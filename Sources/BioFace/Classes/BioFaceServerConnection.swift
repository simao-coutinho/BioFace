//
//  File.swift
//  
//
//  Created by Simao Coutinho on 21/03/2024.
//

import Foundation
import Alamofire
import UIKit

class ServerConnection {
    
    private let url = "https://visteamlab.isr.uc.pt/facing/v2/api/"
    
    private func getHeaders() -> HTTPHeaders? {
        guard let apiToken = BioFace.apiToken else { return nil}
        
        let headers: HTTPHeaders = [
            "authorization": "Bearer " + apiToken
        ]
        
        return headers
    }
    
    func makeImageUpload(with image: UIImage,sessionId: String?, completion: @escaping BioFaceResponse) {
        guard let headers = getHeaders() else { return }
        
        let mSessionId = sessionId ?? BioFace.sessionId
        
        guard let sessionIdData = mSessionId?.data(using: .utf8, allowLossyConversion: false) else {
            return completion(.failed, nil, _error(for: .invalidSessionIdErrorCode))
        }
        guard let collectionNameData = "collection".data(using: .utf8, allowLossyConversion: false) else { return }
        
        guard let file = image.jpegData(compressionQuality: 75) else { return }
        
        AF.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(sessionIdData, withName: "session_id")
                multipartFormData.append(file, withName: "collection" , fileName: "collection.jpg", mimeType: "image/jpg")
        },
            to: url + "collect", method: .post , headers: headers).responseDecodable(of: Response.self) { response in
                completion(.succeeded, response.value, nil)
            }
    }
    
    func makeGetConnection(url: String, sessionId: String?, completion: @escaping BioFaceResponse) {
        guard let headers = getHeaders() else { return }
        
        let parameters = "?session_id=\(sessionId ?? BioFace.sessionId ?? "")"
        
        AF.request(self.url + url + parameters, method: .get, headers: headers).responseString { response in
            completion(.succeeded, Response(success: true, message: response.value), nil)
        }
    }
}
